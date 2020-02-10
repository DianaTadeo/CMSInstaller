#!/bin/bash
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script que realiza la configuracion del sitio y la configuracion con https de Nginx para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: El sistema operativo donde se esta instalando Drupal : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
# Argumento 2: Nombre de dominio del sitio
# Argumento 3: Ruta donde se instalara Drupal
# Argumento 4: Soporte para IPv6

LOG="`pwd`/Modulos/Log/CMS_Instalacion.log"

## @fn log_errors()
## @param $1 Salida de error
## @param $2 Mensaje de error o acierto
##
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : [ERROR] : $2 " >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2 " 	>> $LOG
	fi
}

# $1=SO; $2=DomainName; $3=PathInstall; $4=IPv6
sed -i 's/;\(cgi.fix_pathinfo=\)1/\10/' /etc/php/7.3/fpm/php.ini
if [[ $1 =~ CentOS.* ]]; then
	[ -z "$(which openssl)" ] && yum install openssl -y
	log_errors 0 "Instalacion de $(openssl version): "
	yum install mod_ssl -y
	ROOT_PATH="/var/www"
	service php7.3-fpm restart
else
	[ -z "$(which openssl)" ] && apt install openssl -y
	log_errors 0 "Instalacion de $(openssl version): "
	ROOT_PATH="/var/www/html"
	systemctl restart php7.3-fpm
fi
mkdir -p  /etc/nginx/sites-available/  /etc/nginx/sites-enabled/
SISTEMA="/etc/nginx/sites-available/$2.conf"
SECURITY_CONF="/etc/nginx/conf.d/security.conf"

if [[ $2 =~ [^www.]* ]]; then SERVERNAME="www.$2"; else SERVERNAME=$(echo $2 | cut -f1 -d'.' --complement); fi

read -p "Tienes un certificado de seguridad para tu sitio? [N/s]: " RESP_HTTPS
if [ -z "$RESP_HTTPS" ]; then RESP_HTTPS="N"; fi
if [[ $RESP =~ s|S ]]; then
	while true; do
		read -p "Indica la ruta donde se encuentra el archivo .crt:" CRT
		[ -f "$CRT" ] && break
	done
	while true; do
		read -p "Indica la ruta donde se encuentra el archivo .key:" KEY
		[ -f "$KEY" ] && break
	done
	while true; do
		read -p "Indica la ruta donde se encuentra el archivo .csr:" CSR
		[ -f "$CSR" ] && break
	done
else
	echo "Se generará un certificado autofirmado."
	echo "NOTA: Una vez que tengas un certificado firmado por una CA reconocida, debes reemplazar\
	los archivos de configuración correspondientes."
	KEY="/root/$2.key"; CSR="/root/$2.csr"; CRT="/root/$2.crt"
	openssl genrsa -out $KEY 2048
	./Modulos/InstaladoresCMS/openssl_req.exp "$KEY" "$CSR" "$2" "temporal@email.com"
	#openssl req -new -key $KEY -out $CSR
	openssl x509 -req -days 365 -in $CSR -signkey $KEY -out $CRT
fi
FINGERPRINT=$(openssl x509 -pubkey < $CRT | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)
log_errors 0 "Se obtiene 'fingerprint' del certificado actual: $FINGERPRINT"
if [[ $IPv6 == "Yes" ]]; then
	$IPv6_HTTP="listen [::]:80;"
	$IPv6_HTTPS="listen [::]:443 ssl http2;"
fi
echo "
proxy_cookie_path / \"/; HTTPOnly; Secure\";
server {
	listen 80;
	$IPv6_HTTP

	server_name $2 $SERVERNAME;

	location / {
		return 301 https://$2\$request_uri;
	}
}
server {
	listen 443 ssl;
	$IPv6_HTTPS

	server_name $2 $SERVERNAME;
	root  $ROOT_PATH/$2;
	index index.php index.html index.htm;

	# SSL
	ssl on;
	ssl_certificate $CRT;
	ssl_certificate_key $KEY;

	add_header Public-Key-Pins \"pin-sha256=\\\"$FINGERPRINT\\\"; max-age=2592000; includeSubDomains\";

	location / {
		try_files \$uri \$uri/ /index.php?\$args / =404;
		autoindex off;
	}

	#location ~* /.*((README|robots|INSTALL|UP(D|GR)A(T|D)E|CHANGELOG|LICENSE|COPYING|CONTRIBUTING|TRADEMARK|EXAMPLE|PULL_REQUEST_TEMPLATE)(.*)\$|(.*config|version|info|xmlrpc)(\.php)\$|(.*\.(bak|conf|dist|fla|in[ci]|log|orig|sh|sql|t(ar.*|ar\.gz|gz)|z(.*|ip)|~)\$)){
	#		deny all;
	#		error_page 403 http://$2;
	#}

	location ~ \.php\$ {
		include snippets/fastcgi-php.conf;
		fastcgi_intercept_errors on;
		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
	}
	access_log /var/log/nginx/$2-access.log;
	error_log /var/log/nginx/$2-error.log;

}" |  tee $SISTEMA

echo "Arg 3= $3"
echo "ln -s $3/$2 $ROOT_PATH/$2"
echo "root path: $ROOT_PATH"

if [[ ! $3 =~ $ROOT_PATH/? ]]; then
	ln -s $3/$2 $ROOT_PATH/$2
	log_errors $? "Enlace en $ROOT_PATH/$2"
fi

ln -s /etc/nginx/sites-available/$2.conf /etc/nginx/sites-enabled/$2.conf
log_errors $? "Se habilita sitio $2.conf"

if [[ $1 = 'CentOS 6' ]]; then
	service nginx restart
	log_errors $? "Se reinicia servicio Nginx: service nginx restart "
else
	systemctl restart nginx
	log_errors $? "Se reinicia servicio Nginx: systemctl restart nginx "
fi
hostname -I | xargs printf "%s $2 $SERVERNAME\n" >> /etc/hosts
log_errors $? "Se agrega $2 a /etc/hosts"
