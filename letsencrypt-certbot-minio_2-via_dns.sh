#!/bin/bash

DOMAIN="dominiodoseustorage.com.br"
MINIO_CERT_DIR="/etc/minio/certs"
CERTBOT_LIVE_DIR="/etc/letsencrypt/live/$DOMAIN-0001"
LOG_FILE="/var/log/minio-renew-cert.log"

# Configurar o TOKEN do API no sistema:
# Substitua pelo seu token
# Precisa de permissão total CRUD sobre domínios. Outras permissões não precisa.
DNS_API_TOKEN="dop_v1_xxx"

mkdir -p /root/.secrets/certbot/
echo "dns_digitalocean_token = $DNS_API_TOKEN" > /root/.secrets/certbot/digitalocean.ini
chmod 500 /root/.secrets/certbot/digitalocean.ini

# Talvez seja necessário instalar o plugin de acordo com provedor de DNS:
# https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins
# sudo apt install python3-certbot-dns-digitalocean

# Renovar o certificado usando Certbot com o plugin da DigitalOcean
sudo certbot certonly --dns-digitalocean --dns-digitalocean-credentials ~/.secrets/certbot/digitalocean.ini -d "$DOMAIN" --non-interactive --renew-by-default --agree-tos >> "$LOG_FILE" 2>&1

# Verificar se o certificado foi renovado
if [ -f "$CERTBOT_LIVE_DIR/fullchain.pem" ] && [ -f "$CERTBOT_LIVE_DIR/privkey.pem" ]; then
	echo "Certificado renovado com sucesso. Copiando arquivos para $MINIO_CERT_DIR..." >> $LOG_FILE

	# Criar diretório de certificados do MinIO, se necessário
	sudo mkdir -p "$MINIO_CERT_DIR"

	# Copiar os certificados para o diretório do MinIO
	sudo cp "$CERTBOT_LIVE_DIR/fullchain.pem" "$MINIO_CERT_DIR/public.crt"
	sudo cp "$CERTBOT_LIVE_DIR/privkey.pem" "$MINIO_CERT_DIR/private.key"

	# Ajustar permissões para o MinIO acessar os arquivos
	sudo chmod 770 "$MINIO_CERT_DIR/public.crt" "$MINIO_CERT_DIR/private.key"
	sudo chown -R minio-user:minio-user "$MINIO_CERT_DIR"

	echo "Certificados copiados e permissões ajustadas." >> $LOG_FILE

	# Reiniciar o MinIO para carregar o novo certificado
	echo "Reiniciando o MinIO para aplicar os novos certificados..." >> $LOG_FILE
	sudo systemctl restart minio >> $LOG_FILE 2>&1
else
	echo "Falha ao renovar o certificado ou localizar os arquivos. Verifique o Certbot." >> $LOG_FILE
	exit 1
fi

echo "Renovação concluída em $(date)." >> $LOG_FILE