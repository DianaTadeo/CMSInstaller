#!/bin/bash -e

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de Joomla para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Usuario de la Base de Datos
# Argumento 3: Servidor de la base de Datos (localhost, ip, etc.)
# Argumento 4: Puerto de la Base de Datos
# Argumento 5: Ruta de instalacion de Moodle
# Argumento 6: Version de Moodle
# Argumento 7: url de Moodle
# Argumento 8: SO
# Argumento 9: Manejador de DB ['MySQL'|'PostgreSQL']
# Argumento 10: Web server ['Apache'|'Nginx']
# Argumento 11: Email para notificaciones


LOG="`pwd`/Modulos/Log/CMS_Instalacion.log"

## @fn log_errors()
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

## @fn install_dep()
## @brief Funcion que realiza la instalacion de las dependencias de php para Joomla
## @param $1 El sistema operativo donde se desea instalar Joomla : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalaci[on de Joomla
##
install_dep(){
	# $1=SO; $2=DBM; $3=WEB_SERVER; $4=DOMAIN_NAME; $5=PATH_INSTALL
	case $1 in
		'Debian 9' | 'Debian 10')
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"; else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			cmd="apt install php7.3 php7.3-common \
			php7.3-gd php7.3-json php7.3-mbstring php7.3-intl \
			php7.3-xml php7.3-zip php7.3-curl unzip zip -y"
			$cmd
			log_errors $? "Instalacion de PHP en Joomla: $cmd"
			if [[ $2 == 'MySQL' ]]; then
				cmd="apt install php7.3-mysql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Joomla: $cmd"
			else
				cmd="apt install php7.3-pgsql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Joomla: $cmd"
			fi
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				log_errors $? "Instalacion de libapache2-mod-php7.3: "
				virtual_host_apache "$1" "$4" "$5"
			else
				site_default_nginx "Debian"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			cmd="yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			cmd="yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			cmd="yum install yum-utils -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			cmd="yum-config-manager --enable remi-php73 -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			cmd="yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
			log_errors $? "Instalacion de PHP7.3-$2: "
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

## @fn virtual_host_apache()
## @brief Funcion que realiza la configuracion del sitio, la configuracion con https y se permite .htaccess para Drupal
## @param $1 El sistema operativo donde se esta instalando Drupal : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Nombre de dominio del sitio
## @param $3 Ruta donde se instalara Drupal
##
virtual_host_apache(){
# $1=SO; $2=DomainName; $3=PathInstall
	if [[ $1 =~ CentOS.* ]]; then
		[ -z "$(which openssl)" ] && yum install openssl -y
		log_errors 0 "Instalacion de $(openssl version): "
		yum install mod_ssl -y
		SISTEMA="/etc/httpd/sites-available/$2.conf"
		SECURITY_CONF="/etc/httpd/conf.d/security.conf"
	else
		[ -z "$(which openssl)" ] && apt install openssl -y
		log_errors 0 "Instalacion de $(openssl version): "
		SISTEMA="/etc/apache2/sites-available/$2.conf"
		SECURITY_CONF="/etc/apache2/conf-enabled/security.conf"
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
		./Modulos/InstaladoresCMS/openssl_req.exp "$KEY" "$CSR" "$2" "temporal@email.com"
		#openssl req -new -key $KEY -out $CSR
		openssl x509 -req -days 365 -in $CSR -signkey $KEY -out $CRT
	fi
	FINGERPRINT=$(openssl x509 -pubkey < $CRT | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)
	log_errors 0 "Se obtiene 'fingerprint' del certificado actual: $FINGERPRINT"
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

		Header set Public-Key-Pins \"pin-sha256=\\\"$FINGERPRINT\\\"; max-age=2592000; includeSubDomains\"

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
			log_errors $? "Enlace en /var/www/html/$2: "
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
}

site_default_nginx(){
	echo "site_default_nginx: TODO"
}


modulos_configuraciones(){
	chown $USER:$USER ../moodledata/temp -R
	wget https://moodle.org/plugins/download.php/20823/moosh_moodle38_2019121900.zip
	unzip moosh_moodle38_2019121900.zip
	cd moosh
	ln -s $PWD/moosh.php /usr/local/bin/moosh
	# Se deshabilita inicio de sesión de usuarios invitados
	/usr/local/bin/moosh config-set guestloginbutton 0
}

## @fn install_moodle()
## @brief Funcion que realiza la instalacion de Joomla
## @param $1 Nombre de la base de  para Moodle
## @param $2 Usuario de la base de datos para Moodle
## @param $3 Servidor de la base de datos (host)
## @param $4 Puerto al que se conecta el manejador de base de datos
## @param $5 Ruta del directorio raiz donde se instalara Moodle
## @param $6 Url de Moodle
## @param $7 Manejador de la base de datos  ['MySQL'|'PostgreSQL']
## @param $8 Version de Moodle
## @param $9 Email de administrador
## @param ${10} Ruta del directorio donde fue ejecutado el script main.sh
install_moodle(){
	if [[ $7 == 'MySQL' ]]; then
		dbtype='mariadb'
	else
		dbtype='pgsql'
	fi
	moodleVersion=$(echo $8 | cut -d"." -f1,2 | sed "s/\.//")
	if [[ $8 =~ .*\+ ]]; then
		moodleName="moodle-latest-$moodleVersion"
	else
		moodleName="moodle-$8"
	fi
	wget "https://download.moodle.org/download.php/direct/stable$moodleVersion/$moodleName.tgz"
	tar xzvf $moodleName.tgz
	rm $moodleName.tgz
	mv moodle $6
	cd $6
	#clear
	chown www-data:www-data . -R
	mkdir ../moodledata
	chown www-data:www-data ../moodledata -R
	read -sp "Ingresa el password de la base de datos del usuario '$2' para Moodle: " dbpass; echo -e "\n"
	read -p "Ingresa el nombre completo del sitio ['$6' por defecto]: " fullname
	if [ -z "$fullname" ]; then fullname="$6"; fi
	read -p "Ingresa el nombre corto del sitio: " shortname
	read -p "Ingresa el nombre para el administrador de Moodle: " adminuser
	read -sp "Ingresa el password para el '$adminuser' de Moodle: " adminpass; echo -e "\n"
	cmd="sudo -u www-data /usr/bin/php7.3 admin/cli/install.php  --dbname=$1 --dbuser=$2 --dbhost=$3 --dbport=$4 --dbtype=$dbtype --dbpass=$dbpass --fullname="$fullname" --shortname="$shortname" --adminuser="$adminuser" --adminpass="$adminpass" --adminemail=$9 --wwwroot=https://$6 --non-interactive --agree-license"
	$cmd

	modulos_configuraciones
	#sudo -u www-data /usr/bin/php admin/cli/install_database.php

	jq -c -n --arg title "$fullname" --arg moodle_admin "$adminuser" --arg moodle_admin_pass "$adminpass" \
	'{Title: $title, moodle_admin:$moodle_admin, moodle_admin_pass:$moodle_admin_pass}' \
	> ${10}/moodleInfo.json
}

echo "==============================================="
echo "     Inicia la instalacion de Moodle"
echo "==============================================="

TEMP_PATH="$(su $SUDO_USER -c "pwd")"

mkdir -p "$5"

install_dep "$8" "$9" "${10}" "$7" "$5"

cd $5
install_moodle "$1" "$2" "$3" "$4" "$5" "$7" "$9" "$6" "${11}" "$TEMP_PATH"
