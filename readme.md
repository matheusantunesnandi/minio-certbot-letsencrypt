# Minio com Certbot/Let's Encrypt

## Via HTTP
Usar '--http-01-port 9002' altera a porta de escuta do challenge, mas quando o Let's Encrypt tentar acessar, usará a porta 80 sempre.

O objetivo desse parâmetro é usar uma porta diferente caso no mesmo host a porta 80 esteja sendo usada.
Caso necessite outra porta como a 9002 escolhida por mim, será necessário uma das alternativas abaixo:

- Usar um proxy reverso no Apache, NGINX ou outro para que redirecione determinada requisição em tal domínio para tal serviço:porta interno.
- Usar outro host na mesma rede (Pública ou interna) e redirecionar a requisição para o IP:80 do host do Minio/Storage

## Via DNS (Com a provedora DigitalOcean)
Primeiramente deve ser criada um TOKEN de API com permissão total (CRUD) para o grupo de permissões chamado "domínios". Não são necessárias outras permissões.

Salvar esse TOKEN e atualizar no script correspondente (2).