#!/bin/bash
#######################################################
#Instalador de joomla para CentOS 6, 7 , Debian 9 y 10#
#######################################################


# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Usuario de la Base de Datos
# Argumento 3: Servidor de la base de Datos (localhost, ip, etc.)
# Argumento 4: Puerto de la Base de Datos
# Argumento 5: Ruta de instalacion de joomla
# Argumento 6: Version de Joomla
# Argumento 7: SO
# Argumento 8: Manejador de DB ['MySQL'|'PostgreSQL']
echo "==============================================="
echo "     Inicia la instalacion de $2 $3"
echo "==============================================="

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


install_composer(){
	wget https://getcomposer.org/installer
	mv installer composer-setup.php
	php composer-setup.php
	rm composer-setup.php
	mv composer.phar /usr/bin/composer
	echo "Instalando composer ###########################################"
	su $SUDO_USER -c "composer global require consolidation/cgr"
	echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc
	. ~/.bashrc
	echo "Para instalar drush se requiere ingresar la contraseña del usuario '$SUDO_USER'"
	su $SUDO_USER -c 'echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc'
	composer require nesbot/carbon
}

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
	joomla site:create --use-webroot-dir --mysql-login=$2:$passDB --mysql-database=$1 --mysql-host=$3 --mysql-port=$4 $site
}
install_dep "$7" "$8"
install_composer
install_joomla "$1" "$2" "$3" "$4" "$5" "$6" 
