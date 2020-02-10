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
			[[ $3 == "Apache" ]] && PHP="php7.3"
			[[ $3 == "Nginx" ]] && PHP="php7.3-fpm"
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"; else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			cmd="apt install $PHP php7.3-common \
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
				bash ./Modulos/InstaladoresCMS/virtual_host_apache "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx "$1" "$4" "$5"
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
				bash ./Modulos/InstaladoresCMS/virtual_host_apache "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx "$1" "$4" "$5"
			fi
			;;
	esac
}

## @fn modulos_configuraciones()
## @brief Funcion que realiza la configuración adicional para deshabilitar usuarios invitados
##
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
