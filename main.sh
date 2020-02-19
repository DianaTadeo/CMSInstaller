#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script Main de instalador y configurador de CMS seguros en Debian 9, 10 y CentOS 6, 7
## @version 1.0
## @includes Modulos/Auxiliares/DB_Instalador_Debian.sh
## @includes Modulos/Auxiliares/DB_Instalador_CentOS.sh

# Argumento 1: fileID.json generado desde el sitio web

# Se crea directorio (si es que no existe) para archivos Log
mkdir -p ./Modulos/Log
LOG="`pwd`/Modulos/Log/Configuracion_Instalacion_CMS.log"



## @fn log_errors()
## Funcion para creacion de bitacora de errores
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


## @fn jq_install_OS_detection()
## @brief Función que instala jq detectando el SO (Debian o CentOS)
##
jq_install_OS_detection(){
	if [ `cat /etc/issue | grep -E 'Debian'| wc -l` == '1' ]; then
		apt update -y
		apt install jq -y
	elif [ -e "/etc/centos-release" ]; then
		yum update -y
		yum install epel-release -y
		yum install jq -y
# Para script final se habilita exit
#	else
#		exit
	fi
}

## @fn OS_dependencies()
## @brief Función que permite instalar las dependencias necesarias
## @param $1 Sistema Operativo
##
OS_dependencies(){
	case $1 in
		'Debian 9' | 'Debian 10')
			echo "Deb9"
			apt install -y sudo vim curl wget expect sendmail
			;;
		'CentOS 6' | 'CentOS 7')
			echo "Cent6"
			yum install sudo vim curl wget expect sendmail lsof -y
			;;
	esac
}

## @fn ip_v4_v6()
## @brief Función para habilitar soporte de IPv4 e IPv6
## @param $1
##
ip_v4_v6(){
	# Función para habilitar soporte de IPv4 e IPv6
	# $1=IPv4 $2=IPv6
	if [ $1 = "Yes" ]; then	IPV4_SUPPORT="0"; else IPV4_SUPPORT="1";	fi
	sysctl -w net.ipv4.conf.all.disable_ipv4=$IPV4_SUPPORT
	sysctl -w net.ipv4.conf.default.disable_ipv4=$IPV4_SUPPORT
	log_errors $? "Soporte para IPv4: $1"
	if [ $2 = "Yes" ]; then	IPV6_SUPPORT="0"; else IPV6_SUPPORT="1";	fi
	sysctl -w net.ipv6.conf.all.disable_ipv6=$IPV6_SUPPORT
	sysctl -w net.ipv6.conf.default.disable_ipv6=$IPV6_SUPPORT
	log_errors $? "Soporte para IPv6: $2"
}

## @fn OS_hardening()
## @brief Instalación y configuración de F2Ban, logwatch y logcheck
## @param $1 Sistema operativo
## @param $2 email de notificacion
##
OS_hardening(){
	# $1=SO; $2=EMAIL_NOTIFICATION
	bash ./Modulos/Hardening/F2BanLogwatchLogcheck.sh "$1" "$2"

	 # configuraciones generales de hardening (política de contraseñas, sudo, servicios predet., etc.)
	bash ./Modulos/Hardening/Configuraciones_Generales.sh "$1"
}

## @fn web_server_installer()
## @brief Función que instalará el servidor web con la versión elegida.
## @param $1 Sistema operativo
## @param $2 Servidor web
## @param $3 version del servidor web
##
web_server_installer(){
	# $1=$SO; $2=$WEBSERVER; $3=$WSVersion;
	case $1 in
		'Debian 9' | 'Debian 10')
			# Se ejecuta script para instalación de web server en debian
			 bash ./Modulos/Auxiliares/Apache_Nginx_Debian.sh "$1" "$2" "$3"
		;;
		'CentOS 6' | 'CentOS 7')
			# Se ejecuta script para instalación de web server en centos
			 bash ./Modulos/Auxiliares/Apache_Nginx_CentOS.sh "$1" "$2" "$3"
		;;
	esac
}

## @fn data_base_manager_installer()
## @brief Función que instalará el DBM seleccionado
## @param $1 Sistema operativo
## @param $2 Manejador de base de datos
## @param $3 Version de manejador de base de datos
## @param $4 Existe la base de datos
## @param $5 Usuario de la base de datos
## @param $6 Servidor de base de datos (Host)
## @param $7 Puerto del manejador de base de datos
## @param $8 Nombre de la base de datos
##
data_base_manager_installer(){
	# $1=$SO; $2=$DBM; $3=$DB_VERSION; $4=$DB_EXISTS
	# $5=$DB_USER; $6=$DB_IP; $7=$DB_PORT; $8=$DB_NAME
	case $1 in
		'Debian 9' | 'Debian 10')
			# Se ejecuta script para instalación de base de datos en debian
			bash ./Modulos/Auxiliares/DB_Instalador_Debian.sh "$2" "$3" "$4" "$DB_NAME" \
			"$DB_USER" "$DB_IP" "$DB_PORT" "$1"
		;;
		'CentOS 6' | 'CentOS 7')
			# Se ejecuta script para instalación de base de datos en centos
			bash ./Modulos/Auxiliares/DB_Instalador_CentOS.sh "$2" "$DB_NAME" "$DB_PORT"  \
			"$DB_USER" "$DB_IP"
		;;
	esac
}

## @fn CMS()
## @brief Función que instalará el CMS elegido.
## @param $1 CMS a instalar 'drupal', 'joomla', 'moodle', 'wordpress' y 'ojs'
## @param $2 Sistema operativo
## @param $3 Version de CMS a instalar
## @param $4 Manejador de base de datos
## @param $5 Nombre de la base de datos
## @param $6 Servidor de base de datos (Host)
## @param $7 Puerto del manejador de base de datos
## @param $8 Usuario de la base de datos
## @param $9 Directorio de instalacion para el CMS
## @param $10 Nombre de dominio de la pagina
## @param $11 Correo a donde se enviar[an las notificaciones
## @param $12 Servidor Web 'Apache' o 'Nginx'
## @param $13 Existe la base de datos
## @param $14 Compatibilidad con IPv6
##
CMS(){
	# $1=CMS; $2=$SO; $3=$CMS_VERSION; $4=$DBM; $5=$DB_NAME; $6=$DB_IP; $7=$DB_PORT;
	# $8=$DB_USER; $9=$PATH_INSTALL; $10=$DOMAIN_NAME;
	# $11=EMAIL_NOTIFICATION; $12=WEB_SERVER; $13=DB_EXISTS; $14=IPv6
	case $1 in
		'drupal')
			echo 'Drupal' $3
			bash ./Modulos/InstaladoresCMS/Drupal_Instalador_General.sh "$2" "$3" "$4" \
			"$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}" "${13}" "${14}"
			;;
		'joomla')
			echo 'Joomla' $3
			bash ./Modulos/InstaladoresCMS/Joomla_Instalador_General.sh "$5" "$8" "$6" \
			"$7" "$9" "$3" "$2" "$4" "${13}" "${11}" "${12}" "${10}" "${14}"
			;;
		'moodle')
			echo 'moodle' $3
			bash ./Modulos/InstaladoresCMS/Moodle_Instalador_General.sh "$5" "$8" "$6" \
			"$7" "$9" "$3" "${10}" "$2" "$4" "${12}" "${11}" "${14}"
			;;
		'wordpress')
			echo 'wordpress' $3
			bash ./Modulos/InstaladoresCMS/WP_Instalador_General.sh "$5" "$6:$7" "$8" "$9" \
			"${10}" "${11}" "$4" "${12}" "$2" "$3" "${14}"
			;;
		'ojs')
			echo 'ojs' $3
			bash ./Modulos/InstaladoresCMS/OJS_Instalador_General.sh "$2" "$3" "$4" \
			"$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}" "${13}" "${14}"
			;;
	esac
	bash ./Modulos/Auxiliares/Web_Configuration_Sec.sh "$2" "${12}" "${10}"
}

#===============================================================================================#
#																								#													#
#					Main de instalador y configurador de CMS seguros							#
#																								#													#
#===============================================================================================#

if [ -z $(which sudo) ]; then
	echo "Para ejecutar el script primero se instalará sudo:"
	case $SO in
		'Debian 9' | 'Debian 10')
			apt install sudo -y
			;;
		'CentOS 6' | 'CentOS 7')
			yum install sudo -y
			;;
	esac
	echo -e "Ejecuta nuevamente el script.\nEjecución: sudo ./main.sh"
	exit 1
fi

if [ $(id -u) -ne 0 ] && [ -z "$SUDO_USER" ];then
	echo "Ejecución: sudo ./main.sh"
	exit 1
fi
# Se instala jq para parsear JSON con las opciones elegidas en Debian o CentOS
jq_install_OS_detection

# Se lee archivo "*.json" generado desde el sitio web
JSON_OPTIONS='*.json'

# Se asginan los valores del archivo JSON

SO=`jq '.SO' $JSON_OPTIONS | cut -f2 -d'"'`

CMS=`jq '.CMS' $JSON_OPTIONS | cut -f2 -d'"'`
CMS_VERSION=`jq '.CMSVersion' $JSON_OPTIONS | cut -f2 -d'"'`

WEB_SERVER=`jq '.WebServer' $JSON_OPTIONS | cut -f2 -d'"'`
WS_VERSION=`jq '.WSVersion' $JSON_OPTIONS | cut -f2 -d'"'`

DBM=`jq '.DatabaseManager' $JSON_OPTIONS | cut -f2 -d'"'`
DB_VERSION=`jq '.DBVersion' $JSON_OPTIONS | cut -f2 -d'"'`

DOMAIN_NAME=`jq '.DomainName' $JSON_OPTIONS | cut -f2 -d'"'`

IPV_4=`jq '.IPv4' $JSON_OPTIONS | cut -f2 -d'"'`
IPV_6=`jq '.IPV6' $JSON_OPTIONS | cut -f2 -d'"'`

PATH_INSTALL=`jq '.PathInstall' $JSON_OPTIONS | cut -f2 -d'"'`
EMAIL_NOTIFICATION=`jq '.EmailTo' $JSON_OPTIONS | cut -f2 -d'"'`

BACKUP_DAYS=`jq '.BackupDays' *.json -c | tr '["]' ' ' | sed -e 's/ //g'`
BACKUP_TIME=`jq '.BackupTime' $JSON_OPTIONS | cut -f2 -d'"'`

DB_EXISTS=`jq '.DBExists' $JSON_OPTIONS | cut -f2 -d'"'`

# Se ejecutan las funciones para realizar las instalaciones y configuraciones

OS_dependencies "$SO"
chmod +x ./Modulos/Auxiliares/* ./Modulos/InstaladoresCMS/* ./Modulos/Hardening/*
web_server_installer "$SO" "$WEB_SERVER" "$WS_VERSION"
TEMP_PATH="$PWD"
# Se asginan valores para conexión a la BD si existe o no
if [ $DB_EXISTS = "Yes" ]; then
	DB_USER=`jq '.DBUser' $JSON_OPTIONS | cut -f2 -d'"'`
	DB_IP=`jq '.DBIP' $JSON_OPTIONS | cut -f2 -d'"'`
	DB_PORT=`jq '.DBPort' $JSON_OPTIONS | cut -f2 -d'"'`
else
	while true; do
		read -p "Ingresa el usuario para la base de datos: " DB_USER
		[[ -n $DB_USER ]] && break
	done
	## Se quita la opción de ingresar IP porque la BD es local
	#read -p "Ingresa la dirección IPv4 del servidor de la base de datos [localhost por defecto]: " DB_IP
	if [ -z "$DB_IP" ]; then DB_IP="localhost"; fi
	if [ $DBM = "MySQL" ]; then DEFAULT_DB_PORT="3306"; else DEFAULT_DB_PORT="5432"; fi
	read -p "Ingresa el puerto del servidor de la base de datos [$DEFAULT_DB_PORT por defecto]: " DB_PORT
	if [ -z "$DB_PORT" ]; then DB_PORT=$DEFAULT_DB_PORT; fi
fi
while true; do
	read -p "Ingresa el nombre de la base de datos: " DB_NAME
	[[ -n $DB_NAME ]] && break
done

data_base_manager_installer "$SO" "$DBM" "$DB_VERSION" "$DB_EXISTS" \
"$DB_USER" "$DB_IP" "$DB_PORT" "$DB_NAME"

CMS "$CMS" "$SO"  "$CMS_VERSION" "$DBM" "$DB_NAME" "$DB_IP" "$DB_PORT" \
"$DB_USER" "$PATH_INSTALL" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION" "$WEB_SERVER" \
"$DB_EXISTS" "$IPV_6"

OS_hardening "$SO" "$EMAIL_NOTIFICATION"

bash ./Modulos/Auxiliares/Backup_Files_General.sh "$BACKUP_DAYS" "$SO" \
"$WEB_SERVER" "$DBM" "$PATH_INSTALL" "$DOMAIN_NAME" "$DB_USER" "$DB_IP" \
"$DB_PORT" "$DB_NAME" "$BACKUP_TIME" "$TEMP_PATH" "$EMAIL_NOTIFICATION"
bash ./Modulos/Auxiliares/firewall/Firewall_Config.sh "$SO" "$DB_PORT" "$DB_IP"
echo -e "Recarga las variables de entorno.\n Ejecute los siguientes comandos: . /etc/profile\n\t\t\t\t  . ~/.bashrc"
