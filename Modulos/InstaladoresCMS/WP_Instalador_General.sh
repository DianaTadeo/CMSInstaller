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
# Se devuelve un archivo json con la informacion y credenciales 
# de la instalacion de Wordpress


## @fn install_dep()
## @brief Funcion que realiza la instalacion de las dependencias de php para Wordpress
## @param $1 El sistema operativo donde se desea instalar Wordpress : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalacion de Wordpress
##
install_dep(){
	# $1=SO; $2=DBM
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
			if [[ $2 == 'MySQL' ]]; then apt install php7.3-mysql -y;
			else apt install php7.3-pgsql -y; fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y
			yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y
			yum install yum-utils -y
			yum-config-manager --enable remi-php73 -y
			yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
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
	clear
	echo "==============================================="
	echo "	Se inicia la instalacion de Wordpress"
	echo "==============================================="

	echo "Ingresa el password del usuario de la base de datos: "
	read -s dbpass
	mkdir $4
	cd $4
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod u+x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	wp --allow-root core download
	apt-get install php-mysql -y
	#wp --allow-root core config --dbhost=$2 --dbname=$1 --dbuser=$3 --dbpass=$dbpass
	echo "====Instalacion con cli terminada"
	if [[ $5 == 'PostgreSQL' ]]; then
		echo "==========Se configura PostgreSQL para WordPress"
		apt-get install php-pgsql -y
		wget https://downloads.wordpress.org/plugin/wppg.1.0.1.zip
		unzip wppg.1.0.1.zip
		cd $4
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
		if [[ $7 == 'Debian 9' | $7 == 'Debian 10' ]]; then
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
	echo "==============================================="
	echo "   Se inicia la configuracion de Wordpress"
	echo "==============================================="

	echo "Ingresa el titulo de la pagina"
	read -s title
	echo "Ingresa un nombre de usuario para ser administrador"
	read -s wp_admin
	echo "Ingresa el password para este usuario"
	read -s wp_pass
	wp --allow-root core install --url=$1 --title=$title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$2
	wp --allow-root plugin install simple-login-captcha --activate
	echo "==============================================="
	echo "     Wordpress se instalo correctamente"
	echo "==============================================="
	echo "{\"Title\": $title, \"wp_admin\": $wp_admin, \"wp_admin_pass\": $wp_pass }"> wpInfo.json
}

install_dep "$9" "$7"
install_WP "$1" "$2" "$3" "$4" "$7" "$8" "$9"
configure_WP "$5" "$6"
