#!/bin/bash

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
# Argumento 5: Ruta de instalacion de joomla
# Argumento 6: Version de Joomla
# Argumento 7: SO
# Argumento 8: Manejador de DB ['MySQL'|'PostgreSQL']

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
	# $1=SO; $2=DBM
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
			;;
	esac
}


## @fn install_moodle()
## @brief Funcion que realiza la instalacion de Joomla
## @param $1 Nombre de la base de  para Moodle
## @param $2 Usuario de la base de datos para Moodle 
## @param $3 Servidor de la base de datos (host)
## @param $4 Puerto al que se conecta el manejador de base de datos
## @param $5 Ruta del directorio raiz donde se instalara Moodle
## @param $6 Manejador de la base de datos  ['MySQL'|'PostgreSQL']
##
install_moodle(){
	if [[ $6 == 'MySQL' ]]; then 
		dbtype='mariadb'
	else
		dbtype='postgresql'
	fi
	wget https://download.moodle.org/download.php/direct/stable38/moodle-latest-38.zip
	unzip moodle-latest-38.zip
	cd moodle
	clear
	echo "Ingresa el password de la base de datos de Joomla"
	read dbpass
	echo "Ingresa el nombre completo del sitio"
	read fullname
	echo "Ingresa el nombre corto del sitio"
	read shortname
	echo "Ingresa el nombre para el administrador de Moodle"
	read admin
	echo "Ingresa el password para el administrador de Moodle"
	read -s adminpass
	echo "Ingresa el mail del administrador de Moodle"
	read mail 
	cmd="sudo -u www-data /usr/bin/php7.3 admin/cli/install.php  --dbname=$1 --dbuser=$2 --dbhost=$3 --dbport=$4 --data-root=$5 --dbtype=m$dbtype --dbpass=$dbpass  --fullname=$fullname --shortname=$shortname --adminuser=$admin --adminpass=$adminpass --adminmail=$mail --non-interactive --agree-license"
	$cmd
	sudo -u www-data /usr/bin/php admin/cli/install_database.php
}
