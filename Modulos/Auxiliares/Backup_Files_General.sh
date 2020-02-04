#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script que realiza el respaldo de los archivos de configuración y datos en Debian 9, 10 y CentOS 6, 7
## @version 1.0

# Argumento 1: Días en los que se realiza el respaldo
# Argumento 2: Sistema operativo
# Argumento 3: Servidor Web 'Apache' o 'Nginx'
# Argumento 4: Manejador de base de datos
# Argumento 5: Directorio de instalacion para el CMS
# Argumento 6: Nombre de dominio de la pagina
# Argumento 7: Usuario de la base de datos
# Argumento 8: Servidor de base de datos (Host)
# Argumento 9: Puerto del manejador de base de datos
# Argumento 10: Nombre de la base de datos
# Argumento 11: Hora en la que se realizarán los respaldos
# Argumento 12: Directorio donde se ejecutó el script main.sh
# Argumento 13: Correo a donde se enviar[an las notificaciones

LOG="`pwd`/Modulos/Log/Backup_Files.log"

## @fn log_errors()
## Funcion para creacion de bitacora de errores
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

## @fn backups()
## @brief Función que realiza el respaldo de las configuraciones y de datos.
## @param $1 Días en los que se realiza el respaldo
## @param $2 Sistema operativo
## @param $3 Servidor Web 'Apache' o 'Nginx'
## @param $4 Manejador de base de datos
## @param $5 Directorio de instalacion para el CMS
## @param $6 Nombre de dominio de la pagina
## @param $7 Usuario de la base de datos
## @param $8 Servidor de base de datos (Host)
## @param $9 Puerto del manejador de base de datos
## @param $10 Nombre de la base de datos
## @param $11 Hora en la que se realizarán los respaldos
## @param $12 Directorio donde se ejecutó el script main.sh
## @param $13 Correo a donde se enviar[an las notificaciones
##
backups(){
	# $1=BACKUP_DAYS
	# $2=SO; $3=WEB_SERVER; $4=DBM; $5=PATH_INSTALL; $6=DOMAIN_NAME; $7=DB_USER; $8=DB__IP
	# $9=DB_PORT; $10=DB_NAME; $11=BACKUP_TIME; $12=TEMP_PATH; $13=EMAIL_NOTIFICATION
	cd ${12}
	if [[ $2 =~ Debian.* ]]; then
		systemctl start cron
		if [[ $3 == "Apache" ]]; then
			WEB_CONFIG="/etc/apache2/apache2.conf"
			SECURITY_CONF="/etc/apache2/conf-enabled/security.conf"
			WAF_CONFIG="/etc/modsecurity/modsecurity.conf"
			WAF_CONFIG_MOD="/etc/apache2/mods-enabled/security2.conf"
		else
			WEB_CONFIG="/usr/local/nginx/conf/nginx.conf"
			SECURITY_CONF=""
			WAF_CONFIG="/usr/local/nginx/conf/modsecurity.conf"
			WAF_CONFIG_MOD="/usr/local/nginx/conf/crs-setup.conf"
		fi
		if [[ $4 == "MySQL" ]]; then
			DBM_CONFIG="/etc/mysql/mariadb.conf.d/50-server.cnf"
		else
			if [[ $2 == "Debian 9" ]]; then
				DBM_CONFIG="/etc/postgresql/9.6/main/postgresql.conf"
			else
				DBM_CONFIG="/etc/postgresql/11/main/postgresql.conf"
			fi
		fi
	else
		systemctl cron start
		if [[ $3 == "Apache" ]]; then
			WEB_CONFIG="/etc/httpd/conf/httpd.conf"
			SECURITY_CONF="/etc/httpd/conf.d/security.conf"
			WAF_CONFIG="/etc/httpd/conf.d/mod_security.conf"
			WAF_CONFIG_MOD=""

		else
			WEB_CONFIG=""
			SECURITY_CONF=""
			WAF_CONFIG=""
			WAF_CONFIG_MOD=""

		fi
		if [[ $4 == "MySQL" ]]; then
			DBM_CONFIG="/etc/my.cnf"
		else
			DBM_CONFIG="/var/lib/pgsql/data/"
		fi
	fi
	FIREWALL_CONFIG="./Modulos/Auxiliares/firewall/iptables.v4"

	HOUR=$(echo ${11} | cut -f1 -d":")
	MIN=$(echo ${11} | cut -f2 -d":")
	CRONTAB="/etc/crontab"
	# hour		min		day_of_month		month		day_of_week		user command_to_be_executed

	mkdir backup
	cd backup
	# Respaldo de configuración Web
	tar -czvf config_files_web.tar.gz $WEB_CONFIG $SECURITY_CONF
	log_errors $? "Respaldos de configuraciones web actuales: config_files_web.tar.gz"
	echo "$MIN $HOUR		*	*	$1 		root		tar -czvf $PWD/config_files_web`date +"%F"`.tar.gz $WEB_CONFIG $SECURITY_CONF" >> $CRONTAB
	log_errors $? "Respaldos de configuraciones web programada: $1 on $HOUR:$MIN"
	# Respaldo de config de BD
	tar -czvf config_files_db.tar.gz $DBM_CONFIG
	log_errors $? "Respaldos de configuraciones de BD actuales: config_files_db.tar.gz"
	echo "$MIN $HOUR		*	*	$1 		root		tar -czvf $PWD/config_files_db`date +"%F"`.tar.gz $DBM_CONFIG" >> $CRONTAB
	log_errors $? "Respaldos de configuraciones de BD programado: $1 on $HOUR:$MIN"

	# Respaldo de config de WAF
	tar -czvf config_files_waf.tar.gz $WAF_CONFIG $WAF_CONFIG_MOD
	log_errors $? "Respaldo de configuraciones WAF actuales: config_files_waf.tar.gz"
	echo "$MIN $HOUR		*	*	$1 		root		tar -czvf $PWD/config_files_waf`date +"%F"`.tar.gz $WAF_CONFIG $WAF_CONFIG_MOD" >> $CRONTAB
	log_errors $? "Respaldo de configuraciones de WAF programado: $1 on $HOUR:$MIN"

	# Respaldo de config de Firewall
	if [[ -e $FIREWALL_CONFIG ]]; then
		tar -czvf config_files_firewall.tar.gz $FIREWALL_CONFIG
		log_errors $? "Respaldo de configuraciones de firewall actuales: config_files_firewall.tar.gz"
		echo "$MIN $HOUR		*	*	$1 		root		tar -czvf $PWD/config_files_firewall`date +"%F"`.tar.gz $FIREWALL_CONFIG" >> $CRONTAB
		log_errors $? "Respaldo de configuraciones de firewall programado: $1 on $HOUR:$MIN"
	fi
	echo "Respaldo de datos:"
	# Respaldo sitio web
	tar -czf $6.tar.gz $5/$6
	log_errors $? "Respaldo de datos de sitio web actual: $6.tar.gz"
	echo "$MIN $HOUR		*	*	$1 		root		tar -czf $PWD/$6`date +"%F"`.tar.gz $5/$6" >> $CRONTAB
	log_errors $? "Respaldo de datos de sitio web programado: $1 on $HOUR:$MIN"

	# Respaldo de BD
	read -sp "Ingresa la contraseña del usuario '$7' de la BD para hacer el respaldo: " DB_PASS; echo -e "\n"
	if [[ $4 == "MySQL" ]]; then
		mysqldump -u $7 --password=$DB_PASS -h $8 -P $9 ${10} > ${10}.sql
		log_errors $? "Respaldo de BD actual: ${10}.sql"
		echo "$MIN $HOUR		*	*	$1 		root		mysqldump -u $7 --password=$DB_PASS -h $8 -P $9 ${10} > $PWD/${10}`date +"%F"`.sql" >> $CRONTAB
		log_errors $? "Respaldo de BD programado: $1 on $HOUR:$MIN"
	else
		su -c "PGPASSWORD="$DB_PASS" pg_dump -U $7 -h $8 -p $9 ${10} > ${10}.bak"
		log_errors $? "Respaldo de BD actual: ${10}.bak"
		echo "$MIN $HOUR		*	*	$1 		root		su -c \"PGPASSWORD=\"$DB_PASS\" pg_dump -U $7 -h $8 -p $9 ${10} > $PWD/${10}`date +"%F"`.bak\"" >> $CRONTAB
		log_errors $? "Respaldo de BD programado: $1 on $HOUR:$MIN"
	fi
	if [[ $2 =~ Debian.* ]]; then systemctl restart cron; else service cron restart; fi
	cd -
}

backups "$1" "$2" "$3" "$4" "$5" \
"$6" "$7" "$8" "$9" "${10}" "${11}" \
"${12}" "${13}"
