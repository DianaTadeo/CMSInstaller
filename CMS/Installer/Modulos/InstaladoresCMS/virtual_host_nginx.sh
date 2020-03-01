#!/bin/bash
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script que realiza la configuracion del sitio y la configuracion con https de Nginx para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: El sistema operativo donde se esta configurando el sitio: 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
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

# $1=SO; $2=DomainName; $3=PathInstall; $4=IPv6; $5=CMS
if [[ $1 =~ CentOS.* ]]; then
	sed -i 's/;\(cgi.fix_pathinfo=\)1/\10/' /etc/php.ini
	sed -i 's/expose_php = On/expose_php = Off/' /etc/php.ini
	[ -z "$(which openssl)" ] && yum install openssl -y
	log_errors 0 "Instalacion de $(openssl version): "
	yum install mod_ssl -y
	ROOT_PATH="/usr/share/nginx/html"
	WEB_USER=$(grep -o "^www-data" /etc/passwd)
	[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^apache" /etc/passwd)
	[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^httpd" /etc/passwd)
	[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^nginx" /etc/passwd)
	PHP="php-fpm"
	PHP_SOCK="/run/$PHP/$PHP.sock"
	[[ $1 == 'CentOS 6' ]] && PHP_SOCK="/var/run/$PHP/$PHP.sock"
	FASTCGI="include fastcgi.conf;"
	[[ $5 = "moodle" ]] && PARAM_EXTRAS="fastcgi_split_path_info  ^(.+\.php)(.*)\$; fastcgi_param PATH_INFO \$fastcgi_path_info; fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;"

	sed -i "s%listen = .*%listen = $PHP_SOCK%" /etc/php-fpm.d/www.conf
	sed -i "s%;\(listen.owner = \)nobody%\1$WEB_USER%" /etc/php-fpm.d/www.conf
	sed -i "s%;\(listen.group = \)nobody%\1$WEB_USER%" /etc/php-fpm.d/www.conf
	sed -i "s%;\(listen.mode = .*\)%\1%" /etc/php-fpm.d/www.conf
	sed -i "s/user nginx;/user $WEB_USER;/" /etc/nginx/nginx.conf
	chown -Rf $WEB_USER:$WEB_USER /var/lib/nginx
	[[ $1 == 'CentOS 7' ]] && systemctl enable $PHP
	[[ $1 == 'CentOS 6' ]] && chkconfig $PHP on
	service $PHP restart
	setenforce 0
	[[ $1 == 'CentOS 7' ]] && sed -i '/^\s\+server\s\+{/i 		include /etc/nginx/sites-enabled/*.conf;' /etc/nginx/nginx.conf
	[[ $1 == 'CentOS 6' ]] && sed -i '/^[\s]*http\s\+{/a include /etc/nginx/sites-enabled/*.conf;' /etc/nginx/nginx.conf

else
	sed -i 's/;\(cgi.fix_pathinfo=\)1/\10/' /etc/php/7.3/fpm/php.ini
	sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.3/fpm/php.ini
	[ -z "$(which openssl)" ] && apt install openssl -y
	log_errors 0 "Instalacion de $(openssl version): "
	ROOT_PATH="/var/www/html"
	PHP="php7.3-fpm"
	PHP_SOCK="/run/php/$PHP.sock"
	FASTCGI="include snippets/fastcgi-php.conf;"
	systemctl enable $PHP
	systemctl restart $PHP
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
	# Se ajusta script de expect a CentOS
	if [[ $1 =~ CentOS.* ]]; then
		sed -i "s/AU/XX/" ./Modulos/InstaladoresCMS/openssl_req.exp
		sed -i "s/Some-State//" ./Modulos/InstaladoresCMS/openssl_req.exp
		sed -i 's/\(Locality Name (eg, city) \)\\\[\\\]/\1\\\[Default City\\\]/' ./Modulos/InstaladoresCMS/openssl_req.exp
		sed -i "s/Internet Widgits Pty Ltd/Default Company Ltd/" ./Modulos/InstaladoresCMS/openssl_req.exp
		sed -i "s/e.g. server FQDN or YOUR name/eg, your name or your server's hostname/" ./Modulos/InstaladoresCMS/openssl_req.exp
	fi
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

if [[ $5 == "drupal" ]]; then
	DATA="location ~ \..*/.*\.php\$ {
				 return 403;
			}

			location ~ ^/sites/.*/private/ {
				 return 403;
			}

			location ~ ^/sites/[^/]+/files/.*\.php\$ {
				 deny all;
			}

		 location ~* ^/.well-known/ {
				 allow all;
			}

			location ~ (^|/)\. {
					return 403;
			}

			location / {
					try_files \$uri /index.php?\$query_string;
					autoindex off;
			}

			location @rewrite {
					rewrite ^/(.*)\$ /index.php?q=\$1;
			}

			location ~ /vendor/.*\.php\$ {
					deny all;
					return 404;
			}

			location ~ '\.php\$|^/update.php' {
					fastcgi_split_path_info ^(.+?\.php)(|/.*)\$;
					$FASTCGI
					fastcgi_intercept_errors on;
					fastcgi_pass unix:$PHP_SOCK;
			}

			location ~ ^/sites/.*/files/styles/ {
					try_files \$uri @rewrite;
			}

			location ~ ^(/[a-z\-]+)?/system/files/ {
					try_files \$uri /index.php?\$query_string;
		 }

			location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)\$ {
					try_files \$uri @rewrite;
					expires max;
					log_not_found off;
			}
			if (\$request_uri ~* \"^(.*/)index\.php(.*)\") {
					return 307 \$1\$2;
			}
"
else
	PHP_LOC="location ~ \.php\$ {"
	[[ $5 == 'joomla' ]] && FASTCGI="include /etc/nginx/fastcgi.conf;" && ADMIN_LOC="location = /administrator { return 302 https://$2/administrator/;	}"
	[[ $5 == 'moodle' ]] && PHP_LOC="location ~ [^/]\.php(/|\$) {"
	DATA="location / {
		try_files \$uri \$uri/ /index.php?\$args / =404;
		autoindex off;
	}

	#location ~* /.*((ht|README|robots|INSTALL|UP(D|GR)A(T|D)E|CHANGELOG|LICENSE|COPYING|CONTRIBUTING|TRADEMARK|EXAMPLE|PULL_REQUEST_TEMPLATE)(.*)\$|(.*config|version|info|xmlrpc)(\.php)\$|(.*\.(bak|conf|dist|fla|in[ci]|log|orig|sh|sql|t(ar|ar\.gz|gz)|z(.*|ip)|~)\$)){
	#		deny all;
	#		error_page 403 http://$2;
	#}
	$ADMIN_LOC
	$PHP_LOC
		$FASTCGI
		fastcgi_intercept_errors on;
		fastcgi_pass unix:$PHP_SOCK;
		$PARAM_EXTRAS
	}
"
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

	ssl on;
	ssl_certificate $CRT;
	ssl_certificate_key $KEY;

	add_header Public-Key-Pins \"pin-sha256=\\\"$FINGERPRINT\\\"; max-age=2592000; includeSubDomains\";

	$DATA

	access_log /var/log/nginx/$2-access.log;
	error_log /var/log/nginx/$2-error.log;

	error_page 301 =200 https://$2/;
	error_page 400 =200 https://$2/;
	error_page 401 =200 https://$2/;
	error_page 403 =200 https://$2/;
	error_page 404 =200 https://$2/;
	error_page 405 =200 https://$2/;
	error_page 408 =200 https://$2/;
	error_page 500 =200 https://$2/;
	error_page 501 =200 https://$2/;
	error_page 502 =200 https://$2/;
	error_page 503 =200 https://$2/;
	error_page 504 =200 https://$2/;

}" |  tee $SISTEMA

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
