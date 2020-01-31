#!/bin/bash -e
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de Wordpress para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Servidor de base de datos (localhost, ip, etc..) seguido de puerto ej. localhost:2020
# Argumento 3: Usuario de la Base de Datos
# Argumento 4: Ruta de Instalacion de Wordpress
# Argumento 5: Url de Wordpress
# Argumento 6: Correo de notificaciones
# Argumento 7: 'PostgreSQL' | 'MySQL'
# Argumento 8: 'Nginx' |'Apache'
# Argumento 9: 'CentOS 6'| 'CentOS 7' | 'Debian 9' | 'Debian 10'
# Argumento 10: Version de Wordpress seleccionado

# Se devuelve un archivo json con la informacion y credenciales
# de la instalacion de Wordpress

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
## @brief Funcion que realiza la instalacion de las dependencias de php para Wordpress
## @param $1 El sistema operativo donde se desea instalar Wordpress : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalacion de Wordpress
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
			php7.3-gd php7.3-json php7.3-mbstring \
			php7.3-xml php7.3-zip unzip zip -y"
			$cmd
			log_errors $? "Instalacion de PHP en Wordpress: $cmd"
			if [[ $2 == 'MySQL' ]]; then
				cmd="apt install php7.3-mysql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Wordpress: $cmd"
			else
				cmd="apt install php7.3-pgsql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Wordpress: $cmd"
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
			log_errors $? "Instalacion de dependencias Wordpress: $cmd"
			cmd="yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y"
			$cmd
			log_errors $? "Instalacion de dependencias Wordpress: $cmd"
			cmd="yum install yum-utils -y"
			$cmd
			log_errors $? "Instalacion de dependencias Wordpress: $cmd"
			cmd="yum-config-manager --enable remi-php73 -y"
			$cmd
			log_errors $? "Instalacion de dependencias Wordpress: $cmd"
			cmd="yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y"
			$cmd
			log_errors $? "Instalacion de dependencias Wordpress: $cmd"
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
			log_errors $? "Instalacion de PHP7.3-$2: "
			if [[ $3 == 'Apache' ]]; then
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

## @fn install_WP()
## @brief Funcion que realiza la instalacion de Wordpress
## @param $1 Nombre de la base de datos para Wordpress
## @param $2 Servidor de la base de datos seguido del puerto (host:port)
## @param $3 Usuario de la base de datos para Wordpress
## @param $4 Ruta del directorio raiz donde se instalara Wordpress
## @param $5 Manejador de la base de datos 'MySQL' o 'PostgreSQL'
## @param $6 Tipo de Servidor Web 'Apache' o 'Nginx'
## @param $7 El sistema operativo donde se desea instalar Wordpress : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
##
install_WP(){
	#$1=DBName $2=DBHost:port $3=DBUser $4=WPDirRoot $5=DBManager $6=WebServer $7=OS
	# $8=DomainName; $9=WPVersion
	clear
	echo "==============================================="
	echo "	Se inicia la instalacion de Wordpress"
	echo "==============================================="

	read -sp "Ingresa el password del usuario '$3' de la base de datos: " dbpass; echo -e "\n"
	mkdir -p $4
	cd $4
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod u+x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	wp --allow-root core download --path="$8" --version="$9"
	cd $8
	#apt install php-mysql -y
	#wp --allow-root core config --dbhost=$2 --dbname=$1 --dbuser=$3 --dbpass=$dbpass
	echo "====Instalacion con cli terminada"
	if [[ $5 == 'PostgreSQL' ]]; then
		echo "==========Se configura PostgreSQL para WordPress"
		#apt install php-pgsql -y
		wget https://downloads.wordpress.org/plugin/wppg.1.0.1.zip
		unzip wppg.1.0.1.zip
		#cd $4
		mv wppg ./wp-content/plugins/
		rm wppg.1.0.1.zip
		cp ./wp-content/plugins/wppg/pg4wp/db.php ./wp-content/
		mv ./wp-config-sample.php ./wp-config.php
		#ls .
		sed -i "s/wp-content\/pg4wp/wp-content\/plugins\/wppg\/pg4wp/" ./wp-content/db.php
		sed -i "s/database_name_here/$1/" ./wp-config.php
		sed -i "s/username_here/$3/" ./wp-config.php
		sed -i "s/password_here/$dbpass/" ./wp-config.php
		sed -i "s/localhost/$2/" ./wp-config.php
	else
		wp --allow-root core config --dbhost=$2 --dbname=$1 --dbuser=$3 --dbpass=$dbpass
	fi
	chmod 644 wp-config.php
	chown -R www-data:www-data $4
	if [[ $6 == 'Apache' ]]; then
		if [[ $7 == 'Debian 9' ]] || [[ $7 == 'Debian 10' ]]; then
			systemctl restart apache2
		else
			systemctl restart httpd
		fi
	else
		systemctl restart nginx
	fi
}

## @fn configure_WP()
## @brief Funcion que realiza la configuracion de Wordpress
## @param $1 Url donde se encontrara Wordpress
## @param $2 correo para el administrador de Wordpress
##
## Lo que sea
configure_WP(){
	# $1=Url $2=mail
	# $3=TEMP_PATH
	echo "==============================================="
	echo "   Se inicia la configuracion de Wordpress"
	echo "==============================================="

	read -p "Ingresa el titulo de la pagina ['$1' por defecto]: " title
	if [ -z "$title" ]; then title="$1"; fi
	read -p "Ingresa un nombre de usuario para ser administrador: " wp_admin
	read -sp "Ingresa el password para '$wp_admin': " wp_pass; echo -e "\n"
	wp --allow-root core install --url=$1 --title=$title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$2
	wp --allow-root plugin install simple-login-captcha --activate
	echo "==============================================="
	echo "     Wordpress se instalo correctamente"
	echo "==============================================="

	jq -c -n --arg title "$title" --arg wp_admin "$wp_admin" --arg wp_pass "$wp_pass" \
	'{Title: $title, wp_admin:$wp_admin, wp_admin_pass:$wp_pass}' \
	> $3/wpInfo.json
}

echo "==============================================="
echo "     Inicia la instalacion de Wordpress"
echo "==============================================="

TEMP_PATH="$(su $SUDO_USER -c "pwd")"

mkdir -p $PATH_INSTALL

install_dep "$9" "$7" "$8" "$5" "$4"
install_WP "$1" "$2" "$3" "$4" "$7" "$8" "$9" "$5" "${10}"
configure_WP "$5" "$6" "$TEMP_PATH"
