#!/bin/bash -e
##############################################################
# Script para la instalacion de OJS en Debian 9 y 10 y 	 #
# CentOS 6 y 7                                               #
##############################################################

# Argumento 1: Sistema Operativo
# Argumento 2: Versión de OJS a instalar
# Argumento 3: Manejador de BD
# Argumento 4: Nombre de la Base de Datos
# Argumento 5: Servidor de base de datos (localhost, ip, etc..)
# Argumento 6: Puerto de servidor de base de datos
# Argumento 7: Usuario de la Base de Datos
# Argumento 8: Ruta de Instalacion de OJS
# Argumento 9: Url de OJS
# Argumento 10: Correo de notificaciones
# Argumento 11: Web Server

# Se devuelve un archivo json con la informacion y credenciales
# de la instalacion de OJS

#Requisitos
install_dep(){
	# $1=SO; $2=DBM; $3=WEB_SERVER; $4=DOMAIN_NAME; $5=PATH_INSTALL
	case $1 in
		'Debian 9' | 'Debian 10')
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"; else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			apt install php7.3 php7.3-common \
			php7.3-gd php7.3-json php7.3-mbstring \
			php7.3-xml php7.3-zip unzip zip -y
			if [[ $2 == 'MySQL' ]]; then apt install php7.3-mysqli -y; systemctl restart mysql.service;
		else apt install php7.3-pgsql -y; systemctl restart postgresql.service;  fi
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				#site_default_apache "Debian"
				virtual_host_apache "$1" "$4" "$5"
			else
				site_default_nginx "Debian"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y
			yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y
			yum install yum-utils -y
			yum-config-manager --enable remi-php73 -y
			yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql php-mysqli -y; else yum install php-pgsql -y; fi
			if [[ $3 == 'Apache' ]]; then
#				yum install libapache2-mod-php -y
#				a2enmod rewrite;
				site_default_apache "CentOS"
				virtual_host_apache "$1" "$4" "$5"
			else
				site_default_nginx "CentOS"
			fi
			;;
	esac
}

virtual_host_apache(){
# $1=SO; $2=DomainName; $3=PathInstall
	if [[ $1 =~ CentOS.* ]]; then
		[ -z "$(which openssl)" ] && yum install openssl -y
		yum install mod_ssl -y
		SISTEMA="/etc/httpd/sites-available/$2.conf"
	else
		[ -z "$(which openssl)" ] && apt install openssl -y
		SISTEMA="/etc/apache2/sites-available/$2.conf"
	fi
	if [[ $2 =~ [^www.]* ]]; then SERVERNAME="www.$2"; else SERVERNAME=$2; fi

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
		openssl req -new -key $KEY -out $CSR
		openssl x509 -req -days 365 -in $CSR -signkey $KEY -out $CRT
	fi
	echo "
	<VirtualHost *:80>
			ServerName $SERVERNAME
			Redirect / https://$2
			ServerAlias $2
		</VirtualHost>

	<VirtualHost _default_:443>
		ServerName $SERVERNAME
		ServerAlias $2

		SSLEngine On
		SSLCertificateFile $CRT
		SSLCertificateKeyFile $KEY

		DocumentRoot /var/www/html/$2
		<Directory /var/www/html/$2>
				AllowOverride All
				Require all granted
		</Directory>

		ErrorLog /var/log/apache2/error.log
		CustomLog /var/log/apache2/access.log combined
		#ErrorLog /var/www/html/$2/error.log
		#CustomLog /var/www/html/$2/requests.log combined

	</VirtualHost>" |  tee $SISTEMA
		if [ $3 != "/var/www/html" ] && [ $3 != "/var/www/html/" ]; then
			ln -s $3/$2 /var/www/html/$2
		fi

		if [[ $1 =~ Debian.* ]]; then
			cd /etc/apache2/sites-available/
			a2ensite $2.conf
			a2enmod rewrite
			a2enmod ssl
			cd -
			systemctl restart apache2
		else
			ln -s /etc/httpd/sites-available/$2.conf  /etc/httpd/sites-enabled/$2.conf
			setenforce 0
			if [[ $1 = 'CentOS 6' ]]; then
				service httpd restart
			else
				systemctl restart httpd
			fi
		fi
}

site_default_nginx(){
	echo "site_default_nginx: TODO"
}
# Verifica existencia de git, composer, drush
existencia(){
	# $1=$SO
	if [ $(which git) ]; then
			echo $(git version)
	else
			if [[ $1 = 'CentOS 6' ]] || [[ $1 == 'CentOS 7' ]]; then
				yum install git -y
			else
				apt install git -y
			fi
	fi
}


# Se hace respaldo del sitio
backup(){
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush archive-dump --root=$1 --destination=$1.tar.gz -v --overwrite"
}

# Módulos
modulos_configuraciones(){
	if [[ $1 =~ ^2.* ]]; then
		# Se incluye captcha en inicio de sesión
		sed -i 's/;*\(.*captcha\s*=\s*\).*/\1on/' config.inc.php
		sed -i 's/;*\(.*captcha_on_register\s*=\s*\).*/\1on/' config.inc.php
		sed -i 's/;*\(.*captcha_on_comments\s*=\s*\).*/\1on/' config.inc.php
	else
		# Se incluye captcha en inicio de sesión
		echo "Para habilitar CAPTCHA en esta versión de OJS es necesario contar con \
		una cuenta de Google."
		read -p "Continuar con la configuración del CAPTCHA [S\n]: " RESP
		if [ -z "$RESP" ]; then RESP="S"; fi
		if [[ $RESP =~ s|S ]]; then
			echo -e "A continuación se muestran las instrucciones para obtener el par de claves \
			(pública y privada) necesarias para la configuración.\n\
			Inicia sesión en el siguiente sitio con tu cuenta de Google y rellena el formulario: \
			https://www.google.com/u/2/recaptcha/admin/create\n
			NOTA: Se recomienda utilizar reCAPTCHA v2 por compatibilidad con OJS.\n\
			Una vez que el par de llaves se generó. Procede a copiarlas en el script cuando \
			se te soliciten."
			while true; do
				echo "Primer clave"
				read -p "Public key:" reCAPTCHA_PUB_KEY
				[ -n "$reCAPTCHA_pub_key" ] && break
			done
			while true; do
				echo "Segunda clave"
				read -p "Public key:" reCAPTCHA_PRIV_KEY
				[ -n "$reCAPTCHA_pub_key" ] && break
			done
			sed -i 's/;*\(.*allow_url_fopen\s*=\s*\).*/\1on/' config.inc.php config.TEMPLATE.inc.php
			sed -i 's/;*\(.*recaptcha\s*=\s*\).*/\1on/' config.inc.php
			sed -i "s/;*\(.*recaptcha_public_key\s*=\s*\).*/\1$reCAPTCHA_pub_key/" config.inc.php
			sed -i "s/;*\(.*recaptcha_private_key\s*=\s*\).*/\1$reCAPTCHA_priv_key/" config.inc.php
			sed -i 's/;*\(.*captcha_on_register\s*=\s*\).*/\1on/' config.inc.php
			sed -i 's/;*\(.*captcha_on_comments\s*=\s*\).*/\1on/' config.inc.php
		else
			echo "Deberás configurar el CAPTCHA de forma manual."
		fi
	fi
		# Se deshabilita creación de cuentas de forma pública

		# Se deshabilita comentarios de los usuarios públicos

}


ojs_installer(){
	# $1=CMS_VERSION; $2=DBM; $3=DB_USER; $4=DB_IP; $5=DB_PORT; $6=DB_NAME;
	# $7=DOMAIN_NAME; $8=EMAIL_NOTIFICATION; $9=DB_EXISTS; ${10}=TEMP_PATH
	if [[ $2 == 'MySQL' ]]; then DBM="mysqli"; else DBM="postgres"; fi
	existencia
	echo "Instalando ojs ######################################################"

	wget pkp.sfu.ca/ojs/download/ojs-$1.tar.gz
	tar -xzvf ojs-$1.tar.gz
	rm ojs-$1.tar.gz
	mv ojs-$1 $7

	mkdir /var/www/files
	chown www-data:www-data -R /var/www/files/

	cd $7

	chgrp -R www-data cache public config.inc.php
	chmod -R ug+w cache public config.inc.php


	read -sp "Ingresa la contraseña del usuario '$3' de la BD: " DB_PASS; echo -e "\n"
	read -p "Ingresa el usuario para configurar OJS: " CMS_USER
	read -sp "Ingresa la contraseña del usuario '$CMS_USER' para configurar OJS: " CMS_PASS; echo -e "\n"
	read -p "Ingresa el nombre que tendrá el sitio ['$7' por defecto]: " SITE_NAME
	if [ -z "$SITE_NAME" ]; then SITE_NAME="$7"; fi

	# Se cambia puerto de servidor de BD por el seleccionado en el formulario o en la instalación
	sed -i "s/;\(.*port.*=\s*\).*/\1$5/" config.inc.php

	adminUsername="adminUsername=$CMS_USER"
	adminPassword="adminPassword=$CMS_PASS"
	adminPassword2="adminPassword2=$CMS_PASS"
	adminEmail="adminEmail=$8"
	filesDir="filesDir=/var/www/files"
	databaseDriver="databaseDriver=$DBM"
	databaseHost="databaseHost=$4"
	databaseUsername="databaseUsername=$3"
	databasePassword="databasePassword=$DB_PASS"
	databaseName="databaseName=$6"
	oaiRepositoryId="oaiRepositoryId=$SITE_NAME"

	if [[ $1 =~ ^2.* ]]; then
		DATA="installing=1&locale=en_US&additionalLocales%5B%5D=es_ES&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8&encryption=sha1&createDatabase=0&enableBeacon=0"
	else
		DATA="installing=0&locale=en_US&additionalLocales%5B%5D=es_ES&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8&createDatabase=0&enableBeacon=0"
	fi
	curl \
	--data $DATA \
	--data-urlencode "$adminUsername" --data-urlencode "$adminPassword" \
	--data-urlencode "$adminPassword2" --data-urlencode "$adminEmail" \
	--data-urlencode "$filesDir" --data-urlencode "$databaseDriver" \
	--data-urlencode "$databaseHost" --data-urlencode "$databaseUsername" \
	--data-urlencode "$databasePassword" --data-urlencode "$databaseName" \
	--data-urlencode "$oaiRepositoryId" \
	"localhost/$7/index.php/index/install/install" --trace-ascii - > /dev/null

	modulos_configuraciones "$1"
	cd -
	jq -c -n --arg title "$SITE_NAME" --arg ojs_admin "$CMS_USER" --arg ojs_admin_pass "$CMS_PASS" \
	'{Title: $title, ojs_admin:$ojs_admin, ojs_admin_pass:$ojs_admin_pass}' \
	> ${10}/ojsInfo.json
}

SO=$1
OJS_VERSION=$2
DBM=$3
DB_NAME=$4
DB_IP=$5
DB_PORT=$6
DB_USER=$7
PATH_INSTALL=$8
DOMAIN_NAME=$9
EMAIL_NOTIFICATION=${10}
WEB_SERVER=${11}
DB_EXISTS=${12}
mkdir -p $PATH_INSTALL
chown $SUDO_USER:$SUDO_USER -R $PATH_INSTALL
install_dep "$SO" "$DBM" "$WEB_SERVER" "$DOMAIN_NAME" "$PATH_INSTALL"
chown $SUDO_USER:$SUDO_USER $PATH_INSTALL
TEMP_PATH="$(su $SUDO_USER -c "pwd")"
cd $PATH_INSTALL
ojs_installer "$OJS_VERSION" "$DBM" "$DB_USER" "$DB_IP" "$DB_PORT"\
									"$DB_NAME" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION" "$DB_EXISTS"\
									"$TEMP_PATH"
cd -
