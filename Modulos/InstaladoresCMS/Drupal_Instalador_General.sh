#!/bin/bash -e
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de Drupal para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: Sistema Operativo
# Argumento 2: Versión de Drupal a instalar
# Argumento 3: Manejador de BD
# Argumento 4: Nombre de la Base de Datos
# Argumento 5: Servidor de base de datos (localhost, ip, etc..)
# Argumento 6: Puerto de servidor de base de datos
# Argumento 7: Usuario de la Base de Datos
# Argumento 8: Ruta de Instalacion de Drupal
# Argumento 9: Url de Drupal
# Argumento 10: Correo de notificaciones
# Argumento 11: Web Server
# Argumento 12: Existencia de BD
# Argumento 13: Compatibilidad con IPv6


# Se devuelve un archivo json con la informacion y credenciales
# de la instalacion de Drupal

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
## @brief Funcion que realiza la instalacion de las dependencias de php para Drupal
## @param $1 El sistema operativo donde se desea instalar Drupal : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalacion de Drupal
## @param $3 Servidor web con el que se realiza la instalacion : 'Apache' o 'Nginx'
## @param $4 Nombre de dominio del sitio
## @param $5 Ruta donde se instalara Drupal
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
			apt install $PHP php7.3-common \
			php7.3-gd php7.3-json php7.3-mbstring \
			php7.3-xml php7.3-zip unzip zip -y
			log_errors $? "Instalacion de PHP7.3 en Drupal: "
			if [[ $2 == 'MySQL' ]]; then apt install php7.3-mysql -y;
			else apt install php7.3-pgsql -y; fi
			log_errors $? "Instalacion de PHP7.3-$2: "
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				log_errors $? "Instalacion de libapache2-mod-php7.3: "
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6" "drupal"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y
			yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y
			yum install yum-utils -y
			yum-config-manager --enable remi-php73 -y
			yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring php-intl php-zip php-xmlrpc unzip zip -y
			log_errors $? "Instalacion de PHP7.3 en Drupal: "
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
			log_errors $? "Instalacion de PHP7.3-$2: "
			if [[ $3 == 'Apache' ]]; then
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6" "drupal"
			fi
			;;
	esac
	git_composer_drush "$1"
}

## @fn git_composer_drush()
## @brief Funcion que verifica la existencia o instala git, composer y drush
## @param $1 El sistema operativo donde se esta instalando Drupal : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
##
git_composer_drush(){
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
	log_errors 0 "Instalacion de $(git version): "
	if [ $(which composer) ]; then
				echo $(composer --version)
		else
				# Instalación de composer
				 wget https://getcomposer.org/installer
				 mv installer composer-setup.php
				 php composer-setup.php
				 rm composer-setup.php
				 mv composer.phar /usr/bin/composer
				 echo "Instalando composer ###########################################"
				 #composer global require consolidation/cgr
				 su $SUDO_USER -c "composer global require consolidation/cgr"
				 #PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"
				 #PATH="/$PROYECTO/vendor/bin:$PATH"

				 echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc
				 . ~/.bashrc
				 echo "Para instalar drush se requiere ingresar la contraseña del usuario '$SUDO_USER'"
				 su $SUDO_USER -c 'echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc'
				 # . ~/.bashrc  # NOTA: Cargar $PATH para utilizar drush con el usuario que utilizó "sudo"
	fi
	log_errors $? "Instalacion de $(composer --version): "
	if [ $(which drush) ]
		then
				echo $(drush version)
		else
				# Instalación de drush
				echo "Instalando drush ###########################################"
				su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/cgr drush/drush:8.x"
				#cgr drush/drush:8.x
	fi
	log_errors $? "Instalacion de drush 8.x "
}

## @fn modulos_configuraciones()
## @brief Funcion que instala y configura los modulos para habilitar CAPTCHA, deshabilitar creacion de cuentas anonimas y comentarios de anonimos
## @param $1 La version de Drupal que se esta configurando : '7.x' u '8.x'
##
modulos_configuraciones(){
	if [[ $1 =~ 7.* ]]; then
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset drupal_http_request_fails 0"
		 # Se incluye captcha en inicio de sesión
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 dl captcha && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 en captcha image_captcha -y"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 dl captcha_webform && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 en captcha_webform -y"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset captcha_default_challenge 'image_captcha/Image'"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset captcha_default_validation 0"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset captcha_persistence 0"
		 log_errors $? "Se incluye captcha en inicio de sesión"
		 # Se deshabilita creación de cuentas de forma pública
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset user_register 0"
		 log_errors $? "Se deshabilita creación de cuentas de forma pública"
		 # Se deshabilita comentarios de los usuarios públicos
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 rmp 'anonymous user' 'post comments'"  # rmp -> alias de role-remove-perm
		 log_errors $? "Se deshabilita comentarios de los usuarios públicos"
	else
		# Se incluye captcha en inicio de sesión
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush	\
		dl captcha && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		en captcha image_captcha -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush	\
		config-set captcha.settings default_challenge image_captcha/Image -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set captcha.settings default_validation 0 -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set captcha.settings persistence 0 -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set captcha.captcha_point.user_login_form status true -y"
		log_errors $? "Se incluye captcha en inicio de sesión"
		# Se deshabilita creación de cuentas de forma pública
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set user.settings register admin_only -y"
		log_errors $? "Se deshabilita creación de cuentas de forma pública"
		# Se deshabilita comentarios de los usuarios públicos
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		rmp anonymous 'post comments'"  # rmp -> alias de role-remove-perm
		log_errors $? "Se deshabilita comentarios de los usuarios públicos"
	fi
}

## @fn complementos_seguridad()
## @brief Funcion que instala y configura modulos de seguridad para Drupal
## @param $1 La version de Drupal que se esta configurando : '7.x' u '8.x'
##
complementos_seguridad(){
	if [[ $2 =~ 8.* ]]; then
		DOMAIN_NAME="$1"
		if [[ $DOMAIN_NAME =~ [^www.]* ]]; then
			echo -e "
			\$settings['trusted_host_patterns'] = [ \n
				'^${DOMAIN_NAME//./\\.}\$', \n
				'^www\.${DOMAIN_NAME//./\\.}\$', \n
			];" >> ./sites/default/settings.php
		else
			DOM=$(echo $DOMAIN_NAME | cut --complement -f1 -d".")
			echo -e "
			\$settings['trusted_host_patterns'] = [ \n
				'^${DOMAIN_NAME//./\\.}\$', \n
				'^${DOM//./\\.}\$', \n
				];" >> ./sites/default/settings.php
		fi
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush	\
		dl remove_http_headers && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		en remove_http_headers -y"
	else
		echo
	fi
}

## @fn drupal_installer()
## @brief Funcion que realiza la instalacion de Joomla
## @param $1 Version de drupal que se va a instalar
## @param $2 Manejador de la base de datos  ['MySQL'|'PostgreSQL']
## @param $3 Usuario de la base de datos para Drupal
## @param $4 Servidor de la base de datos (host)
## @param $5 Puerto al que se conecta el manejador de base de datos
## @param $6 Nombre de la base de datos con la que se establecera la conexion
## @param $7 Nombre de dominio que tendra el sitio
## @param $8 Corrreo de administracion y notificacion del sitio
## @param $9 Indica si se especifico que se tiene una base de datos existente
## @param ${10} Ruta del directorio donde fue ejecutado el script main.sh
## @param ${11} Nombre de usuario con el que se ejecuta el servidor web
##
drupal_installer(){
	# $1=CMS_VERSION; $2=DBM; $3=DB_USER; $4=DB_IP; $5=DB_PORT; $6=DB_NAME;
	# $7=DOMAIN_NAME; $8=EMAIL_NOTIFICATION; $9=DB_EXISTS; ${10}=TEMP_PATH; ${11}=WEB_USER
	if [[ $2 == 'MySQL' ]]; then DBM="mysql"; else DBM="pgsql"; fi
	# Se instala drupal con Drush
	echo "Instalando drupal ######################################################"

	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush dl drupal-$1 --drupal-project-rename=$7"
	log_errors $? "Se descarga 'drupal-$1' y se renombra como '$7'"

	while true; do
		read -sp "Ingresa la contraseña del usuario '$3' de la BD: " DB_PASS; echo -e "\n"
		if [[ -n $DB_PASS ]]; then
			if [[ $2 == "PostgreSQL" ]]; then
				su postgres -c "PGPASSWORD="$DB_PASS" psql -h $4 -p $5 -d $6 -U $3 -c '\q'"
			else
				mysql -h $4 -P $5 -u $3 --password=$DB_PASS $6 -e "\q"
			fi
			[[ $? == '0' ]] && break
		fi
	done

	while true; do
		read -p "Ingresa el usuario para configurar Drupal: " CMS_USER
		[[ -n $CMS_USER ]] && break
	done

	while true; do
		read -sp "Ingresa la contraseña del usuario '$CMS_USER' para configurar Drupal: " CMS_PASS; echo -e "\n"
		if [[ -n $CMS_PASS ]]; then
			read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
			[[ "$CMS_PASS" == "$userPass2" ]] && userPass2="" && break
			echo -e "No coinciden!\n"
		fi
	done

	read -p "Ingresa el nombre que tendrá el sitio ['$7' por defecto]: " SITE_NAME
	if [ -z "$SITE_NAME" ]; then SITE_NAME="$7"; fi

	cd $7

	if [[ $9 == "Yes" ]]; then
		DB_NAME="dbtemporal"
		if [[ $2 == "MySQL" ]]; then
			mysql -h $4 -P $5 -u $3 --password=$DB_PASS -e "CREATE DATABASE dbtemporal;"
			log_errors $? "Creación de base de datos 'dbtemporal' (necesaria para la configuración) en MySQL, servidor $5"
		else
			su postgres -c "psql -h $4 -p $5 -U $3 -c 'CREATE DATABASE dbtemporal;'"
			su postgres -c "psql -h $4 -p $5 -U $3 -c 'ALTER DATABASE dbtemporal SET bytea_output = 'escape';'"
			log_errors $? "Creación de base de datos 'dbtemporal' (necesaria para la configuración) en PostgreSQL, servidor $5"
		fi
	else
		DB_NAME="$6"
	fi
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush si standard --account-name="$CMS_USER" --account-pass="$CMS_PASS" \
	--db-url="$DBM://$3:$DB_PASS@$4:$5/$DB_NAME" --site-name=$SITE_NAME --account-mail=$8 -y"
	log_errors $? "Creación de sitio standard '$SITE_NAME' con Drupal"
	if [[ $9 == "Yes" ]]; then
		sed -i "s/\(^\s.*'database'.*=>\s\)'dbtemporal',/\1'$6',/" sites/default/settings.php
		log_errors $? "Se conecta a la base de datos '$6' que se proporciono en el formulario"
		if [[ $2 == "MySQL" ]]; then
			mysql -h $4 -P $5 -u $3 --password=$DB_PASS -e "DROP DATABASE dbtemporal;"
			log_errors $? "Se elimina la base de datos 'dbtemporal' de MySQL"
		else
			su postgres -c "psql -h $4 -p $5 -U $3 -c 'DROP DATABASE dbtemporal;'"
			log_errors $? "Se elimina la base de datos 'dbtemporal' de PostgreSQL"
		fi
	fi
	chown ${11}:${11} sites/default/files/
	modulos_configuraciones "$1"
	complementos_seguridad "$7" "$1"

	if [[ $1 =~ 7.* ]]; then
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush @none dl file_permissions"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush cc drush"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush fp -y"
	fi
	log_errors $? "Permisos en carpetas"

	jq -c -n --arg title "$SITE_NAME" --arg drup_admin "$CMS_USER" --arg drup_admin_pass "$CMS_PASS" \
	'{Title: $title, drup_admin:$drup_admin, drup_admin_pass:$drup_admin_pass}' \
	> ${10}/drupalInfo.json

}

SO=$1
DRUPAL_VERSION=$2
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
IPv6=${13}

echo "===============================================" | tee -a $LOG
echo "     Inicia la instalacion de Drupal $DRUPAL_VERSION" | tee -a $LOG
echo "===============================================" | tee -a $LOG

TEMP_PATH="$(su $SUDO_USER -c "pwd")"

mkdir -p $PATH_INSTALL

install_dep "$SO" "$DBM" "$WEB_SERVER" "$DOMAIN_NAME" "$PATH_INSTALL" "$IPv6"
chown $SUDO_USER:$SUDO_USER $PATH_INSTALL

WEB_USER=$(grep -o "^www-data" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^apache" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^httpd" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^nginx" /etc/passwd)

cd $PATH_INSTALL
drupal_installer "$DRUPAL_VERSION" "$DBM" "$DB_USER" "$DB_IP" "$DB_PORT"\
									"$DB_NAME" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION" "$DB_EXISTS"\
									"$TEMP_PATH" "$WEB_USER"
