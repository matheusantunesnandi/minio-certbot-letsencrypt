# Português:

## Minio com Certbot/Let's Encrypt

### Via HTTP

Usar '--http-01-port 9002' altera a porta de escuta do challenge, mas quando o Let's Encrypt tentar acessar, usará a porta 80 sempre. O objetivo desse parâmetro é usar uma porta diferente caso no mesmo host a porta 80 esteja sendo usada. Caso necessite outra porta como a 9002 escolhida por mim, será necessário uma das alternativas abaixo:

* Usar um proxy reverso no Apache, NGINX ou outro para que redirecione determinada requisição em tal domínio para tal serviço:porta interno.
* Usar outro host na mesma rede (Pública ou interna) e redirecionar a requisição para o IP:80 do host do Minio/Storage.

### Via DNS (Com a provedora DigitalOcean)

Primeiramente deve ser criada um TOKEN de API com permissão total (CRUD) para o grupo de permissões chamado "domínios". Não são necessárias outras permissões. Salvar esse TOKEN e atualizar no script correspondente (2).

# English

## Minio with Certbot/Let's Encrypt

### With HTTP

Using '--http-01-port 9002' changes the listening port of the challenge, but when Let's Encrypt tries to access, it will always use port 80. The purpose of this parameter is to use a different port if port 80 is being used on the same host. If you need another port like 9002 chosen by me, one of the alternatives below will be necessary:

* Use a reverse proxy on Apache, NGINX or other to redirect a certain request on that domain to that internal service:port.
* Use another host on the same network (Public or internal) and redirect the request to the IP:80 of the Minio/Storage host.

### With DNS (With DigitalOcean provider)

First, an API TOKEN must be created with full permission (CRUD) for the permission group called "domains". No other permissions are required. Save this TOKEN and update it in the corresponding script (2).
