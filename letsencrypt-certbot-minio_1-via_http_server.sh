DOMAIN="dominiodoseustorage.com.br"
MINIO_CERT_DIR="/etc/minio/certs"
CERTBOT_LIVE_DIR="/etc/letsencrypt/live/$DOMAIN-0001"
LOG_FILE="/var/log/minio-renew-cert.log"

# Renovar o certificado usando Certbot
# Usar '--http-01-port 9002' altera a porta de escuta do challenge, mas quando o Let's Encrypt tentar acessar, usará a porta 80 sempre.
# Isso só serve para possibilitar subir o servidor em caso de porta sendo usada, mas em contjunto com proxy-reverso ou NAT e redirecionamento de outros hosts na linha de frente desse IP púlico, domínio.
# https://eff-certbot.readthedocs.io/en/stable/using.html#manual
sudo certbot certonly --standalone -d $DOMAIN --non-interactive --renew-by-default --agree-tos >> $LOG_FILE 2>&1

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