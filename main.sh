#!/bin/bash

jq_install_OS_detection(){
	# Función que instala jq detectando el SO (Debian o CentOS)
	if [[ `cat /etc/issue | grep -E 'Debian'| wc -l` == '1' ]]; then
		apt install jq -y
	elif [[ -e "/etc/centos-release" ]]; then
		yum install epel-release -y
		yum install jq -y
# Para script final se habilita exit
#	else
#		exit
	fi
}

OS_dependencies(){
	# Función que permite instalar las dependencias necesarias
	case $1 in
		'Debian 9' | 'Debian 10')
			echo "Deb9"
			apt install -y sudo vim curl wget
			;;
		'CentOS 6' | 'CentOS 7')
			echo "Cent6"
			yum install sudo vim curl wget -y
			;;
	esac
}

OS_hardening(){
	echo "TODO"
}

web_server_installer(){
	# Función que instalará el servidor web con la versión elegida.
	# $1=$SO; $2=$WEBSERVER; $3=$WSVersion;
	case $1 in
		'Debian 9' | 'Debian 10')
			echo "Es debian"
			# Se ejecuta script para instalación de web server en debian
			 ./Modulos/Auxiliares/Apache_Nginx_Debian.sh "$1" "$2" "$3"
		;;
		'CentOS 6' | 'CentOS 7')
			echo "Es centos"
			# Se ejecuta script para instalación de web server en centos
			 ./Modulos/Auxiliares/Apache_Nginx_CentOS.sh "$1" "$2" "$3"
		;;
	esac
}

data_base_manager_installer(){
	# Función que instalará el DBM seleccionado
	# $1=$SO; $2=$DBM; $3=$DB_VERSION; $4=$DB_EXISTS
	# $5=$DB_USER; $6=$DB_IP; $7=$DB_PORT; $8=$DB_NAME
	case $1 in
		'Debian 9' | 'Debian 10')
			echo "Es debian"
			# Se ejecuta script para instalación de base de datos en debian
			bash ./Modulos/Auxiliares/DB_Instalador_Debian.sh "$2" "$3" "$4" "$DB_NAME" \
			"$DB_USER" "$DB_IP" "$DB_PORT"
		;;
		'CentOS 6' | 'CentOS 7')
			echo "Es centos"
			# Se ejecuta script para instalación de base de datos en centos
			bash ./Modulos/Auxiliares/DB_Instalador_CentOS.sh "$2" "$3" "$4" "$DB_NAME" \
			"$DB_USER" "$DB_IP" "$DB_PORT"
		;;
	esac
}

CMS(){
	# Función que instalará el CMS elegido.
	# $1=CMS; $2=$SO; $3=$CMS_VERSION; $4=$DBM; $5=$DB_NAME; $6=$DB_IP; $7=$DB_PORT;
	# $8=$DB_USER; $9=$PATH_INSTALL; $10=$DOMAIN_NAME;
	# $11=EMAIL_NOTIFICATION; $12=WEB_SERVER
	case $1 in
		'drupal')
			echo 'Drupal' $3
			bash ./Modulos/InstaladoresCMS/Drupal_Instalador_General.sh "$2" "$3" "$4" \
			"$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}"
			;;
		'joomla')
			echo 'Joomla' $3
			;;
		'moodle')
			echo 'moodle' $3
			;;
		'wordpress')
			echo 'wordpress' $3
			;;
		'ojs')
			echo 'ojs' $3
			;;
	esac
}

backups(){
	echo "TODO"
}
###########################################################################
#																																					#
#					Main de instalador y configurador de CMS seguros								#
#																																					#
###########################################################################

if [ $(id -u) -ne 0 ]
	then
		echo "Ejecuta como root"
		exit
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

BACKUP_DAYS=`jq '.BackupDays' *.json -c | tr ',[]' ' ()'`  # revisar como pasar a array
BACKUP_TIME=`jq '.BackupTime' $JSON_OPTIONS | cut -f2 -d'"'`

DB_EXISTS=`jq '.DBExists' $JSON_OPTIONS | cut -f2 -d'"'`

# Se ejecutan las funciones para realizar las instalaciones y configuraciones
OS_dependencies "$SO"
chmod +x ./Modulos/Auxiliares/* ./Modulos/InstaladoresCMS/*
OS_hardening "$SO"
web_server_installer "$SO" "$WEB_SERVER" "$WS_VERSION"

# Se asginan valores para conexión a la BD si existe o no
if [ $DB_EXISTS == "Yes" ]; then
	DB_USER=`jq '.DBUser' $JSON_OPTIONS | cut -f2 -d'"'`
	DB_IP=`jq '.DBIP' $JSON_OPTIONS | cut -f2 -d'"'`
	DB_PORT=`jq '.DBPort' $JSON_OPTIONS | cut -f2 -d'"'`
else
	read -p "Ingresa el usuario para la base de datos: " DB_USER
	read -p "Ingresa la dirección IPv4 del servidor de la base de datos: " DB_IP
	read -p "Ingresa el puerto del servidor de la base de datos: " DB_PORT
fi
read -p "Ingresa el nombre de la base de datos: " DB_NAME

data_base_manager_installer "$SO" "$DBM" "$DB_VERSION" "$DB_EXISTS" \
"$DB_USER" "$DB_IP" "$DB_PORT" "$DB_NAME"

CMS "$CMS" "$SO"  "$CMS_VERSION" "$DBM" "$DB_NAME" "$DB_IP" "$DB_PORT" \
"$DB_USER" "$PATH_INSTALL" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION" "$WEB_SERVER"
backups
