#!/bin/bash
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script Main de instalador y configurador de CMS seguros en Debian 9, 10 y CentOS 6, 7
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
		echo "[`date +"%F %X"`] : $2 : [ERROR]" >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : $2 : [OK]" 	>> $LOG
	fi
}

# $1=SO ; $2=WEB_SERVER ;
SO="$1"
WEB_SERVER="$2"

if [[ $WEB_SERVER == "Apache" ]]; then
	if [[ "$SO" =~ Debian.* ]]; then
		WEB_SERVER_CONF="/etc/apache2/apache2.conf"
		SECURITY_CONF="/etc/apache2/conf-enabled/security.conf"
	else
		WEB_SERVER_CONF="/etc/httpd/conf/httpd.conf"
		SECURITY_CONF="/etc/httpd/conf.d/security.conf"
	fi

	sed -i "s/\(TraceEnable\s*\)on/\1off/" $SECURITY_CONF
	log_errors $? "Se deshabilitan metodos HTTP: "
	sed -i "s/\(ServerTokens\s*\).*/\1Prod/" $SECURITY_CONF
	#ServerTokens Prod
	log_errors $? "ServerTokens Prod: "

	sed -i "s/\(ServerSignature\s*\).*/\1Off/" $SECURITY_CONF
	#ServerSignature On -> ServerSignature Off
	log_errors $? "ServerSignature Off: "

	sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/s/\(.*Options\s*\).*/\1-Indexes +FollowSymlinks/' $WEB_SERVER_CONF
	log_errors $? "Se deshabilita listado de directorios: "

	sed -i 's/#*\(Header set X-Content-Type-Options:\s*\).*/\1"nosniff"/' $SECURITY_CONF
	log_errors $? "Header set X-Content-Type-Options: \"nosniff\": "

	sed -i 's/#*\(Header set X-Frame-Options:\s*\).*/\1"sameorigin"/' $SECURITY_CONF
	log_errors $? "Header set X-Frame-Options: \"sameorigin\": "

	echo "Header set X-XSS-Protection \"1;  mode=block\"" >> $SECURITY_CONF
	log_errors $? "Header set X-XSS-Protection \"1;  mode=block\": "

	echo 'Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"' >> $SECURITY_CONF
	log_errors $? "Header always set Strict-Transport-Security \"max-age=63072000; includeSubdomains: "
	# Apache>=2.2.4
	echo 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure' >> $SECURITY_CONF
	log_errors $? 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure: '
	# Apache<2.2.4-
	#echo "Header set Set-Cookie HttpOnly;Secure" >> $SECURITY_CONF

	echo "Header set Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval';\"" >> $SECURITY_CONF
	log_errors $? "Header set Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval';\": "

	echo "Header set Referrer-Policy \"strict-origin-when-cross-origin\"" >> $SECURITY_CONF
	log_errors $? "Header set Referrer-Policy \"strict-origin-when-cross-origin\": "

	echo "Header set Expect-CT 'enforce, max-age=43200'" >> $SECURITY_CONF
	log_errors $? "Header set Expect-CT 'enforce, max-age=43200': "

	echo "Header set X-Permitted-Cross-Domain-Policies \"none\"" >> $SECURITY_CONF
	log_errors $? "Header set X-Permitted-Cross-Domain-Policies \"none\": "

	echo "ErrorDocument 301 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 400 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 401 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 403 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 404 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 405 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 408 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 500 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 501 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 502 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 503 /index.html" >> $SECURITY_CONF
	echo "ErrorDocument 504 /index.html" >> $SECURITY_CONF

	log_errors $? "Redireccion de codigos de estado al sitio principal: "

	echo '<FilesMatch "(README|robots|INSTALL|UP(D|GR)A(T|D)E|CHANGELOG|LICENSE|COPYING|CONTRIBUTING|TRADEMARK|EXAMPLE|PULL_REQUEST_TEMPLATE)(.*)$|(.*config|version|info|xmlrpc)(\.php)$|(.*\.(bak|conf|dist|fla|in[ci]|log|orig|sh|sql|t(ar.*|ar\.gz|gz)|z(.*|ip)|~)$)">
			Require all denied
	</FilesMatch>' >> $SECURITY_CONF
	log_errors $? "Se restringe el acceso a los archivos publicos: "
	if [[ "$SO" =~ Debian.* ]]; then
		systemctl restart apache2
		log_errors $? "Se reinicia apache2 "
	else
		apachectl -k restart
		log_errors $? "Se reinicia apache2 "
	fi
else  # Nginx
	if [[ "$SO" =~ Debian.* ]]; then
		WEB_SERVER_CONF=""
		SECURITY_CONF=""
	else
		WEB_SERVER_CONF=""
		SECURITY_CONF=""
	fi
fi
