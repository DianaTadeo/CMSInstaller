#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script que realiza las configuraciones de seguridad para el servidor web elegido en Debian 9, 10 y CentOS 6, 7
## @version 1.0
##

LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"

## @fn log_errors()
## Funcion para creacion de bitacora de errores
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

# $1=SO ; $2=WEB_SERVER ; $3=DOMAIN_NAME
SO="$1"
WEB_SERVER="$2"

echo "=========================================================" | tee -a $LOG
echo "     Configuraciones Web de seguridad para $WEB_SERVER" | tee -a $LOG
echo "=========================================================" | tee -a $LOG

if [[ $WEB_SERVER == "Apache" ]]; then
	if [[ "$SO" =~ Debian.* ]]; then
		WEB_SERVER_CONF="/etc/apache2/apache2.conf"
		SECURITY_CONF="/etc/apache2/conf-enabled/security.conf"
		sed -i 's/#//' /etc/apache2/sites-available/$3.conf
	else
		WEB_SERVER_CONF="/etc/httpd/conf/httpd.conf"
		SECURITY_CONF="/etc/httpd/conf.d/security.conf"
		sed -i 's/#//' /etc/httpd/sites-available/$3.conf
	fi
	if [[ -e $SECURITY_CONF ]]; then
		sed -i "s/\(TraceEnable\s*\)on/\1off/" $SECURITY_CONF
		log_errors $? "Se deshabilitan metodos HTTP excepto: GET, HEAD, POST"
		sed -i "s/\(ServerTokens\s*\).*/\1Prod/" $SECURITY_CONF
		#ServerTokens Prod
		log_errors $? "ServerTokens Prod"

		sed -i "s/\(ServerSignature\s*\).*/\1Off/" $SECURITY_CONF
		#ServerSignature On -> ServerSignature Off
		log_errors $? "ServerSignature Off"

		sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/s/\(.*Options\s*\).*/\1-Indexes +FollowSymlinks/' $WEB_SERVER_CONF
		log_errors $? "Se deshabilita listado de directorios: "

		sed -i 's/#*\(Header set X-Content-Type-Options:\s*\).*/\1"nosniff"/' $SECURITY_CONF
		log_errors $? "Header set X-Content-Type-Options: \"nosniff\": "

		sed -i 's/#*\(Header set X-Frame-Options:\s*\).*/\1"sameorigin"/' $SECURITY_CONF
		log_errors $? "Header set X-Frame-Options: \"sameorigin\": "
	else
		SECURITY_CONF=$WEB_SERVER_CONF
		echo "ServerSignature Off" >> $SECURITY_CONF
		log_errors $? "ServerSignature Off"
		echo "ServerTokens Prod" >> $SECURITY_CONF
		log_errors $? "ServerTokens Prod"

		sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/\(.*Options\s*\).*/\1-Indexes +FollowSymlinks/' $WEB_SERVER_CONF
		log_errors $? "Se deshabilita listado de directorios"

		echo -e "<Location />\n\t<LimitExcept GET HEAD POST>\n\t\torder deny,allow\n\t\tdeny from all\n\t</LimitExcept>\n</Location>" >> $SECURITY_CONF # Otra opción
		echo "TraceEnable Off" >> $SECURITY_CONF
		log_errors $? "Se deshabilitan metodos HTTP excepto: GET, HEAD, POST"

		echo "LoadModule headers_module modules/mod_headers.so" >> $SECURITY_CONF
		echo "Header set X-Content-Type-Options nosniff" >> $SECURITY_CONF
		log_errors $? "Header set X-Content-Type-Options nosniff "

		echo "Header set X-Frame-Options sameorigin" >> $SECURITY_CONF
		log_errors $? "Header set X-Frame-Options sameorigin"

	fi
	echo "Header set X-XSS-Protection \"1;  mode=block\"" >> $SECURITY_CONF
	log_errors $? "Header set X-XSS-Protection \"1;  mode=block\": "

	echo 'Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"' >> $SECURITY_CONF
	log_errors $? "Header always set Strict-Transport-Security \"max-age=63072000; includeSubdomains: "
	# Apache>=2.2.4
	echo 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure' >> $SECURITY_CONF
	log_errors $? 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure'
	# Apache<2.2.4-
	#echo "Header set Set-Cookie HttpOnly;Secure" >> $SECURITY_CONF

	echo "Header set Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval' ajax.googleapis.com;\"" >> $SECURITY_CONF
	log_errors $? "Header set Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval' ajax.googleapis.com;\""

	echo "Header set Referrer-Policy \"strict-origin-when-cross-origin\"" >> $SECURITY_CONF
	log_errors $? "Header set Referrer-Policy \"strict-origin-when-cross-origin\": "

	echo "Header set Expect-CT 'enforce, max-age=43200'" >> $SECURITY_CONF
	log_errors $? "Header set Expect-CT 'enforce, max-age=43200': "

	echo "Header set X-Permitted-Cross-Domain-Policies \"none\"" >> $SECURITY_CONF
	log_errors $? "Header set X-Permitted-Cross-Domain-Policies \"none\": "

	echo "ErrorDocument 301 /" >> $SECURITY_CONF
	echo "ErrorDocument 400 /" >> $SECURITY_CONF
	echo "ErrorDocument 401 /" >> $SECURITY_CONF
	echo "ErrorDocument 403 /" >> $SECURITY_CONF
	echo "ErrorDocument 404 /" >> $SECURITY_CONF
	echo "ErrorDocument 405 /" >> $SECURITY_CONF
	echo "ErrorDocument 408 /" >> $SECURITY_CONF
	echo "ErrorDocument 500 /" >> $SECURITY_CONF
	echo "ErrorDocument 501 /" >> $SECURITY_CONF
	echo "ErrorDocument 502 /" >> $SECURITY_CONF
	echo "ErrorDocument 503 /" >> $SECURITY_CONF
	echo "ErrorDocument 504 /" >> $SECURITY_CONF

	log_errors $? "Redireccion de codigos de estado al sitio principal"

	echo '<FilesMatch "(?i)(README|robots|INSTALL|UP(D|GR)A(T|D)E|CHANGELOG|LICENSE|COPYING|CONTRIBUTING|TRADEMARK|EXAMPLE|PULL_REQUEST_TEMPLATE)(.*)$|(.*config|version|info|xmlrpc)(\.php)$|(.*\.(bak|conf|dist|fla|in[ci]|log|orig|sh|sql|t(ar.*|ar\.gz|gz)|z(.*|ip)|~)$)">
			Require all denied
	</FilesMatch>' >> $SECURITY_CONF
	log_errors $? "Se restringe el acceso a los archivos publicos: "
	if [[ "$SO" =~ Debian.* ]]; then
		systemctl restart apache2
		log_errors $? "Se reinicia apache2 "
	else
		service httpd restart
		log_errors $? "Se reinicia apache2 "
	fi
else  # Nginx
	if [[ "$SO" =~ Debian.* ]]; then
		WEB_SERVER_CONF="/etc/nginx/nginx.conf"
		SECURITY_CONF="/etc/nginx/conf.d/security.conf"
		sed -i 's/#//' /etc/nginx/sites-available/$3.conf
	else
		yum install nginx-extras -y
		WEB_SERVER_CONF="/etc/nginx/nginx.conf"
		SECURITY_CONF="/etc/nginx/conf.d/security.conf"
		sed -i 's/#//' /etc/nginx/sites-available/$3.conf
	fi

	sed -i "s/\(\s*\)#\?\(\s\)\(server_tokens\s*\).*/\1\2\3off;/" $WEB_SERVER_CONF
	log_errors $? "server_tokens off;"

	echo 'add_header Allow "GET, POST, HEAD" always;' >> $SECURITY_CONF
	echo -e 'server {\nif ( $request_method !~ ^(GET|POST|HEAD)$ ) {\nreturn 405;\n}\n}' >> $SECURITY_CONF
	log_errors $? "Se deshabilitan metodos HTTP excepto: GET, HEAD, POST"
	sed -i '/^\s\+server_tokens off;/i 		more_clear_headers Server;' $WEB_SERVER_CONF
	log_errors $? "ServerSignature Off -> more_clear_headers Server"

	sed -i '/^\s\+try_files $uri $uri\/ =404;/a 		autoindex off;' /etc/nginx/sites-available/default # Se aplica para todos
	log_errors $? "Se deshabilita listado de directorios"

	echo "add_header X-Content-Type-Options nosniff;" >> $SECURITY_CONF
	log_errors $? "add_header X-Content-Type-Options nosniff;"

	echo "add_header X-Frame-Options SAMEORIGIN;" >> $SECURITY_CONF
	log_errors $? "add_header X-Frame-Options SAMEORIGIN;"

	echo 'add_header X-XSS-Protection "1;  mode=block";' >> $SECURITY_CONF
	log_errors $? 'add_header X-XSS-Protection "1;  mode=block";'

	echo 'add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";' >> $SECURITY_CONF
	log_errors $? 'add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";'
	echo 'proxy_cookie_path / "/; HTTPOnly; Secure";' >> /etc/nginx/sites-available/default # Se aplica para todos

	echo "add_header Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval'\";" >> $SECURITY_CONF
	log_errors $? "add_header Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval'\";"

	echo "add_header Referrer-Policy \"strict-origin-when-cross-origin\";" >> $SECURITY_CONF
	log_errors $? "add_header Referrer-Policy \"strict-origin-when-cross-origin\""

	echo "add_header Expect-CT 'enforce, max-age=43200';" >> $SECURITY_CONF
	log_errors $? "add_header Expect-CT 'enforce, max-age=43200';"

	echo "add_header X-Permitted-Cross-Domain-Policies none;" >> $SECURITY_CONF
	log_errors $? "add_header X-Permitted-Cross-Domain-Policies none;"

	echo "error_page 301 =200 /;" >> $SECURITY_CONF
	echo "error_page 400 =200 /;" >> $SECURITY_CONF
	echo "error_page 401 =200 /;" >> $SECURITY_CONF
	echo "error_page 403 =200 /;" >> $SECURITY_CONF
	echo "error_page 404 =200 /;" >> $SECURITY_CONF
	echo "error_page 405 =200 /;" >> $SECURITY_CONF
	echo "error_page 408 =200 /;" >> $SECURITY_CONF
	echo "error_page 500 =200 /;" >> $SECURITY_CONF
	echo "error_page 501 =200 /;" >> $SECURITY_CONF
	echo "error_page 502 =200 /;" >> $SECURITY_CONF
	echo "error_page 503 =200 /;" >> $SECURITY_CONF
	echo "error_page 504 =200 /;" >> $SECURITY_CONF

	log_errors $? "Redireccion de codigos de estado al sitio principal"

	# Se aplica a todos
	sed -i '/server_name _;/a location ~* \/.*\(\(ht|README|robots|INSTALL|UP\(D|GR\)A\(T|D\)E|CHANGELOG|LICENSE|COPYING|CONTRIBUTING|TRADEMARK|EXAMPLE|PULL_REQUEST_TEMPLATE\)\(.*\)$|\(.*config|version|info|xmlrpc\)\(\\.php)$|\(.*\\.\(bak|conf|dist|fla|in[ci]|log|orig|sh|sql|t\(ar.*|ar\\.gz|gz\)|z\(.*|ip\)|~\)$\)\){\n\tdeny all;\n\terror_page 403 \/;\n}' /etc/nginx/sites-available/default
	log_errors $? "Se restringe el acceso a los archivos publicos"
	if [[ "$SO" =~ Debian.* ]]; then
		systemctl restart nginx
		log_errors $? "Se reinicia nginx "
	else
		service nginx restart
		log_errors $? "Se reinicia nginx"
	fi
fi
