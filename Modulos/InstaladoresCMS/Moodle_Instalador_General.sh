#!/bin/bash -e

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de Moodle para CentOS 6, CentOS 7, Debian 9 y Debian 10
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
# Argumento 12: Compatibilidad con IPv6

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
## @brief Funcion que realiza la instalacion de las dependencias de php para Moodle
## @param $1 El sistema operativo donde se desea instalar Moodle : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalaci[on de Moodle
## @param $3 Servidor web con el que se realiza la instalacion : 'Apache' o 'Nginx'
## @param $4 Nombre de dominio del sitio
## @param $5 Ruta donde se instalara Moodle
## @param $6 Compatibilidad con IPv6
##
install_dep(){
	# $1=SO; $2=DBM; $3=WEB_SERVER; $4=DOMAIN_NAME; $5=PATH_INSTALL; $6=IPv6
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
			php7.3-xml php7.3-zip php7.3-curl php7.3-xmlrpc unzip zip -y"
			$cmd
			log_errors $? "Instalacion de PHP en Moodle: $cmd"
			if [[ $2 == 'MySQL' ]]; then
				cmd="apt install php7.3-mysql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Moodle: $cmd"
			else
				cmd="apt install php7.3-pgsql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Moodle: $cmd"
			fi
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				log_errors $? "Instalacion de libapache2-mod-php7.3: "
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6" "moodle"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			[[ $3 == "Apache" ]] && PHP="php"
			[[ $3 == "Nginx" ]] && PHP="php-fpm"
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			cmd="yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y"
			$cmd
			log_errors 0 "Instalacion de dependencias Moodle: $cmd"
			cmd="yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y"
			$cmd
			log_errors 0 "Instalacion de dependencias Moodle: $cmd"
			cmd="yum install yum-utils -y"
			$cmd
			log_errors $? "Instalacion de dependencias Moodle: $cmd"
			cmd="yum-config-manager --enable remi-php73 -y"
			$cmd
			log_errors $? "Instalacion de dependencias Moodle: $cmd"
			cmd="yum install wget $PHP php-mcrypt php-cli php-curl php-gd php-pdo \
			php-xml php-mbstring php-intl php-zip php-xmlrpc unzip zip -y"
			$cmd
			log_errors $? "Instalacion de dependencias Moodle: $cmd"
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
			log_errors $? "Instalacion de PHP7.3-$2: "
			if [[ $3 == 'Apache' ]]; then
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6" "moodle"
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
	rm moosh_moodle38_2019121900.zip
	cd moosh
	ln -s $PWD/moosh.php /usr/local/bin/moosh
	# Se deshabilita inicio de sesión de usuarios invitados
	/usr/local/bin/moosh -n config-set guestloginbutton 0
	cd ..
}

## @fn install_moodle()
## @brief Funcion que realiza la instalacion de Moodle
## @param $1 Nombre de la base de datos para Moodle
## @param $2 Usuario de la base de datos para Moodle
## @param $3 Servidor de la base de datos (host)
## @param $4 Puerto al que se conecta el manejador de base de datos
## @param $5 Ruta del directorio raiz donde se instalara Moodle
## @param $6 Url de Moodle
## @param $7 Manejador de la base de datos  ['MySQL'|'PostgreSQL']
## @param $8 Version de Moodle
## @param $9 Email de administrador
## @param ${10} Ruta del directorio donde fue ejecutado el script main.sh
## @param ${11} Nombre de usuario con el que se ejecuta el servidor web
##
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
	tar xzf $moodleName.tgz
	rm $moodleName.tgz
	mv moodle $6
	cd $6
	#clear
	chown ${11}:${11} . -R
	mkdir ../moodledata
	chown ${11}:${11} ../moodledata -R

	while true; do
		read -sp "Ingresa el password de la base de datos del usuario '$2' para Moodle: " dbpass; echo -e "\n"
		if [[ -n $dbpass ]]; then
			if [[ $7 == "PostgreSQL" ]]; then
				su postgres -c "PGPASSWORD="$dbpass" psql -h $3 -p $4 -d $1 -U $2 -c '\q'"
			else
				mysql -h $3 -P $4 -u $2 --password=$dbpass $1 -e "\q"
			fi
			[[ $? == '0' ]] && break
		fi
	done

	read -p "Ingresa el nombre completo del sitio ['$6' por defecto]: " fullname
	if [ -z "$fullname" ]; then fullname="$6"; fi
	while true; do
		read -p "Ingresa el nombre corto del sitio: " shortname
		[[ -n $shortname ]] && break
	done
	while true; do
		read -p "Ingresa el nombre para el administrador de Moodle: " adminuser
		[[ -n $adminuser ]] && break
	done

	while true; do
		read -sp "Ingresa el password para el '$adminuser' de Moodle: " adminpass; echo -e "\n"
		if [[ -n $adminpass ]]; then
			read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
			[[ "$adminpass" == "$userPass2" ]] && userPass2="" && break
			echo -e "No coinciden!\n"
		fi
	done

	/usr/bin/php7.3 --version  2> /dev/null
	if [ $? == 0 ]; then
		BIN_PHP="php7.3"
	else
		BIN_PHP="php"
	fi

	cmd="sudo -u ${11} /usr/bin/$BIN_PHP admin/cli/install.php  --dbname=$1 --dbuser=$2 --dbhost=$3 --dbport=$4 --dbtype=$dbtype --dbpass=$dbpass --fullname="$fullname" --shortname="$shortname" --adminuser="$adminuser" --adminpass="$adminpass" --adminemail=$9 --wwwroot=https://$6 --non-interactive --agree-license"
	$cmd

	modulos_configuraciones

	echo "Estoy en: $PWD"
	# Permisos de carpetas y archivos de dir: moodledata
	find ../moodledata -type f -exec chmod 600 {} +
	log_errors $? "Permisos en archivos de directorio moodledata: 600"
	find ../moodledata -type d -exec chmod 700 {} +
	log_errors $? "Permisos en carpetas de directorio moodledata: 700"
	chown ${11}:${11} ../moodledata/ -R

	# Permisos de carpetas y archivos
	find . -type f -exec chmod 644 {} +
	log_errors $? "Permisos en archivos: 644"
	find . -type d -exec chmod 755 {} +
	log_errors $? "Permisos en carpetas: 755"
	chown $USER:$USER . -R

	jq -c -n --arg title "$fullname" --arg moodle_admin "$adminuser" --arg moodle_admin_pass "$adminpass" \
	'{Title: $title, moodle_admin:$moodle_admin, moodle_admin_pass:$moodle_admin_pass}' \
	> ${10}/moodleInfo.json
}

echo "===============================================" | tee -a $LOG
echo "     Inicia la instalacion de Moodle $6 " | tee -a $LOG
echo "===============================================" | tee -a $LOG

TEMP_PATH="$(su $SUDO_USER -c "pwd")"

mkdir -p "$5"

install_dep "$8" "$9" "${10}" "$7" "$5" "${12}"

WEB_USER=$(grep -o "^www-data" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^apache" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^httpd" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^nginx" /etc/passwd)

cd $5
install_moodle "$1" "$2" "$3" "$4" "$5" "$7" "$9" "$6" "${11}" "$TEMP_PATH" \
"$WEB_USER"
