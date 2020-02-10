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
		echo "[`date +"%F %X"`] : [ERROR] : $2 " >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2 " 	>> $LOG
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
			[[ $3 == "Apache" ]] && PHP="php7.3"
			[[ $3 == "Nginx" ]] && PHP="php7.3-fpm"
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"; else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			cmd="apt install $PHP php7.3-common \
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
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5"
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
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5"
			fi
			;;
	esac
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
	#clear
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
	log_errors $? "Descarga de WordPress version=$9"
	cd $8
	if [[ $5 == 'PostgreSQL' ]]; then
		echo "==========Se configura PostgreSQL para WordPress"
		apt install php7.3-mysql -y
		cd wp-content
		git clone https://github.com/kevinoid/postgresql-for-wordpress.git
		mv postgresql-for-wordpress/pg4wp pg4wp
		log_errors $? "Configuración de PostgreSQL con WordPress"
		rm -rf postgresql-for-wordpress
		cp pg4wp/db.php db.php

		cp ../wp-config-sample.php ../wp-config.php
		sed -i "s/database_name_here/$1/" ../wp-config.php
		log_errors $? "Nombre de base de datos: $1"
		sed -i "s/username_here/$3/" ../wp-config.php
		log_errors $? "Nombre de usuario: $3"
		sed -i "s/password_here/$dbpass/" ../wp-config.php
		sed -i "s/localhost/$(echo $2 | cut -f1 -d':')/" ../wp-config.php
		log_errors $? "Host de base de datos: $(echo $2 | cut -f1 -d':')"
		chmod 644 ../wp-config.php

	else
		wp --allow-root core config --dbhost=$2 --dbname=$1 --dbuser=$3 --dbpass=$dbpass
		log_errors $? "Configuración de WordPress con MySQL: Host:$2, DBName=$1, DBUser=$3"
		chmod 644 wp-config.php
	fi

	if [[ $6 == 'Apache' ]]; then

		if [[ $7 == 'Debian 9' ]] || [[ $7 == 'Debian 10' ]]; then
			chown -R www-data:www-data $4
			systemctl restart apache2
		else
			chown -R apache:apache $4
			systemctl restart httpd
		fi
	else
		#chown -R nginx:nginx $4
		chown -R www-data:www-data $4
		systemctl restart nginx
	fi
}

## @fn configure_WP()
## @brief Funcion que realiza la configuracion de Wordpress
## @param $1 Url donde se encontrara Wordpress
## @param $2 correo para el administrador de Wordpress
##
configure_WP(){
	# $1=Url $2=mail
	# $3=TEMP_PATH $4=DBM
	echo "==============================================="
	echo "   Se inicia la configuracion de Wordpress"
	echo "==============================================="

	read -p "Ingresa el titulo de la pagina ['$1' por defecto]: " title
	if [ -z "$title" ]; then title="$1"; fi
	read -p "Ingresa un nombre de usuario para ser administrador: " wp_admin
	read -sp "Ingresa el password para '$wp_admin': " wp_pass; echo -e "\n"
	if [[ $4 == "MySQL" ]]; then
		wp --allow-root core install --url=$1 --title=$title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$2
		log_errors $? "Instalación de WP con MySQL"
		wp --allow-root plugin install simple-login-captcha --activate
		log_errors $? "Instalación de captcha en login"
	else
		weblog_title="weblog_title=$title"
		user_name="user_name=$wp_admin"
		admin_password="admin_password=$wp_pass"
		admin_password2="admin_password2=$wp_pass"
		admin_email="admin_email=$2"
		DATA="pw_weak=on&language=&Submit=Install+WordPress"

		curl -k \
		--data $DATA \
		--data-urlencode "$weblog_title" --data-urlencode "$user_name" \
		--data-urlencode "$admin_password" --data-urlencode "$admin_password2" \
		--data-urlencode "$admin_email" \
		"https://$1/wp-admin/install.php?step=2" --trace-ascii - > /dev/null
		log_errors $? "Instalación de WP con PostgreSQL"

		wp --allow-root plugin install wp-math-captcha
		sed -i "s/\(\s*'login_form'\s*=>\s*\)false,/\1true,/" plugins/wp-math-captcha/wp-math-captcha.php
		wp --allow-root plugin activate wp-math-captcha
		log_errors $? "Instalación de captcha en login"
	fi
	cd ../
	find . -type f -exec chmod 644 {} +
	log_errors $? "Permisos en archivos: 644"
	find . -type d -exec chmod 755 {} +
	log_errors $? "Permisos en carpetas: 755"
	chmod 600 wp-config.php

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

mkdir -p $4
install_dep "$9" "$7" "$8" "$5" "$4"
install_WP "$1" "$2" "$3" "$4" "$7" "$8" "$9" "$5" "${10}"
configure_WP "$5" "$6" "$TEMP_PATH" "$7"
