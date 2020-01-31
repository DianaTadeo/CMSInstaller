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

## @fn install_composer()
## @brief Funcion que realiza la instalacion de composer
## 
## Composer es necesario para poder instalar Joomla de forma remota (Por linea de comando)
install_composer(){
	wget https://getcomposer.org/installer
	mv installer composer-setup.php
	php composer-setup.php
	rm composer-setup.php
	mv composer.phar /usr/bin/composer
	echo "============ Instalando composer =============="
	su $SUDO_USER -c "composer global require consolidation/cgr"
	echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc
	. ~/.bashrc
	echo "Para instalar drush se requiere ingresar la contraseña del usuario '$SUDO_USER'"
	su $SUDO_USER -c 'echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc'
	cmd="composer require nesbot/carbon"
	$cmd
	log_errors() $? "Instalacion de composer $cmd"
}

## @fn install_joomla()
## @brief Funcion que realiza la instalacion de Joomla
## @param $1 Nombre de la base de  para Joomla
## @param $2 Usuario de la base de datos para Joomla 
## @param $3 Servidor de la base de datos (host)
## @param $4 Puerto al que se conecta el manejador de base de datos
## @param $5 Ruta del directorio raiz donde se instalara Joomla
## @param $6 Version de Joomla que se desea instalar
##
install_joomla(){
	# $1=dbname $2=dbuser $3=dbhost $4=dbport $5=ruta $6=version
	composer global require joomlatools/console
	#export PATH="$PATH:~/.composer/vendor/bin"
	export PATH=$PATH:~/.config/composer/vendor/bin/
	clear
	echo "Ingresa el password de la base de datos de Joomla"
	read passDB
	echo "Ingresa el nombre del sitio"
	read site
	cmd="joomla site:create --use-webroot-dir --mysql-login=$2:$passDB --mysql-database=$1 --mysql-host=$3 --mysql-port=$4 $site"
	$cmd
	log_errors() $? "Instalacion de joomla $cmd"
}

echo "==============================================="
echo "     Inicia la instalacion de Joomla"
echo "==============================================="
install_dep "$7" "$8"
install_composer
install_joomla "$1" "$2" "$3" "$4" "$5" "$6" 
