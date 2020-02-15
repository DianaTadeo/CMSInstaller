#!/bin/bash
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script que realiza la configuracion del sitio la configuracion con https de Apache para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: El sistema operativo donde se esta instalando Drupal : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
# Argumento 2: Nombre de dominio del sitio
# Argumento 3: Ruta donde se instalara Drupal

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

# $1=SO; $2=DomainName; $3=PathInstall
if [[ $1 =~ CentOS.* ]]; then
	[ -z "$(which openssl)" ] && yum install openssl -y
	log_errors 0 "Instalacion de $(openssl version): "
	yum install mod_ssl -y
	mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled
	echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
	SISTEMA="/etc/httpd/sites-available/$2.conf"
	SECURITY_CONF="/etc/httpd/conf.d/security.conf"
	ROOT_PATH="/var/www"
	[[ $1 == "CentOS 7" ]] && ROOT_PATH="/var/www/html"
	WEB_SERVER="httpd"
else
	[ -z "$(which openssl)" ] && apt install openssl -y
	log_errors 0 "Instalacion de $(openssl version): "
	SISTEMA="/etc/apache2/sites-available/$2.conf"
	SECURITY_CONF="/etc/apache2/conf-enabled/security.conf"
	ROOT_PATH="/var/www/html"
	WEB_SERVER="apache2"
fi
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
echo "
<VirtualHost *:80>
		ServerName $SERVERNAME
		Redirect / https://$2/
		ServerAlias $2
	</VirtualHost>

<VirtualHost _default_:443>
	ServerName $SERVERNAME
	ServerAlias $2

	SSLEngine On
	SSLCertificateFile $CRT
	SSLCertificateKeyFile $KEY

	Header set Public-Key-Pins \"pin-sha256=\\\"$FINGERPRINT\\\"; max-age=2592000; includeSubDomains\"

	DocumentRoot $ROOT_PATH/$2
	<Directory $ROOT_PATH/$2>
			AllowOverride All
			Require all granted
	</Directory>
	#<FilesMatch \"(?i)(README|robots|INSTALL|UP(D|GR)A(T|D)E|CHANGELOG|LICENSE|COPYING|CONTRIBUTING|TRADEMARK|EXAMPLE|PULL_REQUEST_TEMPLATE)(.*)\$|(.*config|version|info|xmlrpc)(\.php)\$|(.*\.(bak|conf|dist|fla|in[ci]|log|orig|sh|sql|t(ar.*|ar\.gz|gz)|z(.*|ip)|~)\$)\">
	#		Require all denied
	#</FilesMatch>
	ErrorLog /var/log/$WEB_SERVER/$2-error.log
	CustomLog /var/log/$WEB_SERVER/$2-requests.log combined

</VirtualHost>" |  tee $SISTEMA
if [[ ! $3 =~ $ROOT_PATH/? ]]; then
	ln -s $3/$2 $ROOT_PATH/$2
	log_errors $? "Enlace en $ROOT_PATH/$2: "
fi

if [[ $1 =~ Debian.* ]]; then
	cd /etc/apache2/sites-available/
	a2ensite $2.conf
	log_errors $? "Se habilita sitio $2.conf "
	a2enmod rewrite
	log_errors $? "Se habilita modulo de Apache: a2enmod rewrite"
	a2enmod ssl
	log_errors $? "Se habilita modulo de Apache: a2enmod ssl"
	a2enmod headers
	log_errors $? "Se habilita modulos headers: a2enmod headers"
	cd -
	systemctl restart apache2
	log_errors $? "Se reinicia servicio Apache: systemctl restart apache2"
else
	ln -s /etc/httpd/sites-available/$2.conf  /etc/httpd/sites-enabled/$2.conf
	setenforce 0
	log_errors $? "Se habilita sitio $2.conf "
	if [[ $1 = 'CentOS 6' ]]; then
		service httpd restart
		log_errors $? "Se reinicia servicio HTTPD: service httpd restart "
	else
		systemctl restart httpd
		log_errors $? "Se reinicia servicio HTTPD: systemctl restart httpd "
	fi
fi
hostname -I | xargs printf "%s $2 $SERVERNAME\n" >> /etc/hosts
log_errors $? "Se agrega $2 a /etc/hosts"
