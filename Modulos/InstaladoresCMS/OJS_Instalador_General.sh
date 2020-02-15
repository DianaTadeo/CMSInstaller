#!/bin/bash -e
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de OJS para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: Sistema Operativo
# Argumento 2: Versión de OJS a instalar
# Argumento 3: Manejador de BD
# Argumento 4: Nombre de la Base de Datos
# Argumento 5: Servidor de base de datos (localhost, ip, etc..)
# Argumento 6: Puerto de servidor de base de datos
# Argumento 7: Usuario de la Base de Datos
# Argumento 8: Ruta de Instalacion de OJS
# Argumento 9: Url de OJS
# Argumento 10: Correo de notificaciones
# Argumento 11: Web Server
# Argumento 12: Existencia de BD
# Argumento 13: Compatibilidad con IPv6

# Se devuelve un archivo json con la informacion y credenciales
# de la instalacion de OJS

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
## @brief Funcion que realiza la instalacion de las dependencias de php para OJS
## @param $1 El sistema operativo donde se desea instalar Drupal : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalacion de OJS
## @param $3 Servidor web con el que se realiza la instalacion : 'Apache' o 'Nginx'
## @param $4 Nombre de dominio del sitio
## @param $5 Ruta donde se instalara OJS
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
			log_errors $? "Instalación de PHP7.3"
			if [[ $2 == 'MySQL' ]]; then apt install php7.3-mysqli -y; systemctl restart mysql.service;
		else apt install php7.3-pgsql -y; systemctl restart postgresql.service;  fi
			log_errors $? "Instalación de PHP7.3-$2"
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				log_errors $? "Instalación de libapache2-mod-php7.3"
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y
			yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y
			yum install yum-utils -y
			yum-config-manager --enable remi-php73 -y
			yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y
			log_errors $? "Instalación de PHP7.3"
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql php-mysqli -y; else yum install php-pgsql -y; fi
			log_errors $? "Instalación de PHP7.3-$2"
			if [[ $3 == 'Apache' ]]; then
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6"
			fi
			;;
	esac
}

## @fn git_existence()
## @brief Funcion que verifica la existencia o instala git
## @param $1 El sistema operativo donde se esta instalando OJS : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
##
git_existence(){
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
	log_errors 0 "Instalacion de $(git version)"
}

## @fn modulos_configuraciones()
## @brief Funcion que instala y configura los modulos para habilitar CAPTCHA, deshabilitar creacion de cuentas anonimas y comentarios de anonimos
## @param $1 La version de OJS que se esta configurando : '3.x' u '2.x'
##
modulos_configuraciones(){
	if [[ $1 =~ ^2.* ]]; then
		# Se incluye captcha en inicio de sesión
		sed -i 's/;*\(.*captcha\s*=\s*\).*/\1on/' config.inc.php
		log_errors $? "Se habilita captcha"
		sed -i 's/;*\(.*captcha_on_register\s*=\s*\).*/\1on/' config.inc.php
		log_errors $? "Se incluye captcha en registro de usuarios"
		sed -i 's/;*\(.*captcha_on_comments\s*=\s*\).*/\1on/' config.inc.php
		log_errors $? "Se incluye captcha en comentarios"
	else
		# Se incluye captcha en inicio de sesión
		echo "Para habilitar CAPTCHA en esta versión de OJS es necesario contar con \
		una cuenta de Google."
		read -p "Continuar con la configuración del CAPTCHA [S\n]: " RESP
		if [ -z "$RESP" ]; then RESP="S"; fi
		if [[ $RESP =~ s|S ]]; then
			echo -e "A continuación se muestran las instrucciones para obtener el par de llaves \
			(pública y privada) necesarias para la configuración.\n\
			Inicia sesión en el siguiente sitio con tu cuenta de Google y rellena el formulario: \
			https://www.google.com/u/2/recaptcha/admin/create\n
			NOTA: Se recomienda utilizar reCAPTCHA v2 por compatibilidad con OJS.\n\
			Una vez que el par de llaves se generó. Procede a copiarlas en el script cuando \
			se te soliciten."
			while true; do
				echo "Primer clave"
				read -p "Public key:" reCAPTCHA_PUB_KEY
				[ -n "$reCAPTCHA_pub_key" ] && break
			done
			while true; do
				echo "Segunda clave"
				read -p "Public key:" reCAPTCHA_PRIV_KEY
				[ -n "$reCAPTCHA_pub_key" ] && break
			done
			sed -i 's/;*\(.*allow_url_fopen\s*=\s*\).*/\1on/' config.inc.php config.TEMPLATE.inc.php
			log_errors $? "Se habilita url_open para comptabilidad con recaptcha"
			sed -i 's/;*\(.*recaptcha\s*=\s*\).*/\1on/' config.inc.php
			log_errors $? "Se habilita recaptcha"
			sed -i "s/;*\(.*recaptcha_public_key\s*=\s*\).*/\1$reCAPTCHA_pub_key/" config.inc.php
			log_errors $? "Se configuró: recaptcha_public_key"
			sed -i "s/;*\(.*recaptcha_private_key\s*=\s*\).*/\1$reCAPTCHA_priv_key/" config.inc.php
			log_errors $? "Se configuró: recaptcha_private_key"
			sed -i 's/;*\(.*captcha_on_register\s*=\s*\).*/\1on/' config.inc.php
			log_errors $? "Se incluye captcha en comentarios"
			sed -i 's/;*\(.*captcha_on_comments\s*=\s*\).*/\1on/' config.inc.php
			log_errors $? "Se incluye captcha en comentarios"
		else
			echo "Deberás configurar el CAPTCHA de forma manual."
			log_errors $? "Deberás configurar el CAPTCHA de forma manual una vez que tengas el par de claves: https://www.google.com/u/2/recaptcha/admin/create"
		fi
	fi
		# Se deshabilita creación de cuentas de forma pública

		# Se deshabilita comentarios de los usuarios públicos

}

## @fn ojs_installer()
## @brief Funcion que realiza la instalacion de OJS
## @param $1 Version de ojs que se va a instalar
## @param $2 Manejador de la base de datos  ['MySQL'|'PostgreSQL']
## @param $3 Usuario de la base de datos para ojs
## @param $4 Servidor de la base de datos (host)
## @param $5 Puerto al que se conecta el manejador de base de datos
## @param $6 Nombre de la base de datos con la que se establecera la conexion
## @param $7 Nombre de dominio que tendra el sitio
## @param $8 Corrreo de administracion y notificacion del sitio
## @param $9 Indica si se especifico que se tiene una base de datos existente
## @param ${10} Ruta del directorio donde fue ejecutado el script main.sh
## @param ${11} Servidor web con el que se realiza la instalacion : 'Apache' o 'Nginx'
##
ojs_installer(){
	# $1=CMS_VERSION; $2=DBM; $3=DB_USER; $4=DB_IP; $5=DB_PORT; $6=DB_NAME;
	# $7=DOMAIN_NAME; $8=EMAIL_NOTIFICATION; $9=DB_EXISTS; ${10}=TEMP_PATH;
	# ${11}=WEB_SERVER
	if [[ $2 == 'MySQL' ]]; then DBM="mysqli"; else DBM="postgres"; fi
	git_existence
	echo "Instalando ojs ######################################################"

	wget pkp.sfu.ca/ojs/download/ojs-$1.tar.gz
	log_errors $? "Descarga de ojs-$1"
	tar -xzvf ojs-$1.tar.gz
	log_errors $? "Se extrae contenido de ojs-$1.tar.gz"
	rm ojs-$1.tar.gz
	mv ojs-$1 $7
	log_errors $? "Se renombra 'ojs-$1' a '$7'"

	mkdir /var/www/files
	log_errors $? "Se crea directorio /var/www/files"
	chown www-data:www-data -R /var/www/files/
	log_errors $? "Se asigna www-data dueño del directorio /var/www/files"

	cd $7

	chgrp -R www-data cache public config.inc.php
	log_errors $? "Se asigna al grupo www-data (para configuración) los directorios y archivos: cache public config.inc.php"
	chmod -R ug+w cache public config.inc.php
	log_errors $? "Se asigna permisos de escritura (para configuración) los directorios y archivos: cache public config.inc.php"


	read -sp "Ingresa la contraseña del usuario '$3' de la BD: " DB_PASS; echo -e "\n"
	read -p "Ingresa el usuario para configurar OJS: " CMS_USER
	read -sp "Ingresa la contraseña del usuario '$CMS_USER' para configurar OJS: " CMS_PASS; echo -e "\n"
	read -p "Ingresa el nombre que tendrá el sitio ['$7' por defecto]: " SITE_NAME
	if [ -z "$SITE_NAME" ]; then SITE_NAME="$7"; fi

	# URL con la que se instala el CMS ojs para Apache o Nginx
	URL="https://$7/index.php/index/install/install"
	[[ ${11} == 'Nginx' ]] && sed -i "s/\(disable_path_info = \)Off/\1On/" config.inc.php && URL="https://$7/index.php?journal=index&page=install&op=install"
	log_errors 0 "Se utiliza la URL para realizar la instalación de ojs: $URL"
	# Se cambia puerto de servidor de BD por el seleccionado en el formulario o en la instalación
	sed -i "s/;\(.*port.*=\s*\).*/\1$5/" config.inc.php

	adminUsername="adminUsername=$CMS_USER"
	adminPassword="adminPassword=$CMS_PASS"
	adminPassword2="adminPassword2=$CMS_PASS"
	adminEmail="adminEmail=$8"
	filesDir="filesDir=/var/www/files"
	databaseDriver="databaseDriver=$DBM"
	databaseHost="databaseHost=$4"
	databaseUsername="databaseUsername=$3"
	databasePassword="databasePassword=$DB_PASS"
	databaseName="databaseName=$6"
	oaiRepositoryId="oaiRepositoryId=$SITE_NAME"

	if [[ $1 =~ ^2.* ]]; then
		DATA="installing=1&locale=en_US&additionalLocales%5B%5D=es_ES&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8&encryption=sha1&createDatabase=0&enableBeacon=0"
	else
		DATA="installing=0&locale=en_US&additionalLocales%5B%5D=es_ES&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8&createDatabase=0&enableBeacon=0"
	fi

	while true; do
		curl -k \
		--data $DATA \
		--data-urlencode "$adminUsername" --data-urlencode "$adminPassword" \
		--data-urlencode "$adminPassword2" --data-urlencode "$adminEmail" \
		--data-urlencode "$filesDir" --data-urlencode "$databaseDriver" \
		--data-urlencode "$databaseHost" --data-urlencode "$databaseUsername" \
		--data-urlencode "$databasePassword" --data-urlencode "$databaseName" \
		--data-urlencode "$oaiRepositoryId" \
		$URL  --trace-ascii - | grep "Errors occurred"#> /dev/null
		[[ $? == '1' ]] && break
	done
	log_errors $? "Termina instalación de ojs"
	modulos_configuraciones "$1"
	cd -
	jq -c -n --arg title "$SITE_NAME" --arg ojs_admin "$CMS_USER" --arg ojs_admin_pass "$CMS_PASS" \
	'{Title: $title, ojs_admin:$ojs_admin, ojs_admin_pass:$ojs_admin_pass}' \
	> ${10}/ojsInfo.json
}

SO=$1
OJS_VERSION=$2
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

mkdir -p $PATH_INSTALL
chown $SUDO_USER:$SUDO_USER -R $PATH_INSTALL
install_dep "$SO" "$DBM" "$WEB_SERVER" "$DOMAIN_NAME" "$PATH_INSTALL" "$IPv6"
chown $SUDO_USER:$SUDO_USER $PATH_INSTALL
TEMP_PATH="$(su $SUDO_USER -c "pwd")"
cd $PATH_INSTALL
ojs_installer "$OJS_VERSION" "$DBM" "$DB_USER" "$DB_IP" "$DB_PORT"\
									"$DB_NAME" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION" "$DB_EXISTS"\
									"$TEMP_PATH" "$WEB_SERVER"
cd -
