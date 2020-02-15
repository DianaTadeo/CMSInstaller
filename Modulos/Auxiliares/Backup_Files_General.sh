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
			SECURITY_CONF="/etc/apache2/conf-available/security.conf"
			VH_CONFIG="/etc/apache2/sites-available/$6.conf"
			WAF_CONFIG="/etc/modsecurity/modsecurity.conf"
			WAF_CONFIG_MOD="/etc/apache2/mods-enabled/security2.conf"
		else
			WEB_CONFIG="/etc/nginx/nginx.conf"
			SECURITY_CONF="/etc/nginx/conf.d/security.conf"
			VH_CONFIG="/etc/nginx/sites-available/$6.conf"
			WAF_CONFIG="/etc/nginx/modsec/modsecurity.conf"
			WAF_CONFIG_MOD="/etc/nginx/modsec/crs-setup.conf"
		fi
		if [[ $4 == "MySQL" ]]; then
			DBM_CONFIG="/etc/mysql/mariadb.conf.d/50-server.cnf"
		else
			if [[ $2 == "Debian 9" ]]; then
				DBM_CONFIG="/etc/postgresql/9.6/main/postgresql.conf"
				DBM_CONF="/etc/postgresql/9.6/main/pg_hba.conf"
			else
				DBM_CONFIG="/etc/postgresql/11/main/postgresql.conf"
				DBM_CONF="/etc/postgresql/11/main/pg_hba.conf"
			fi
		fi
	else
		service crond start
		if [[ $3 == "Apache" ]]; then
			WEB_CONFIG="/etc/httpd/conf/httpd.conf"
			SECURITY_CONF="/etc/httpd/conf.d/security.conf"
			[[ ! -e $SECURITY_CONF ]] && SECURITY_CONF=$WEB_CONFIG
			VH_CONFIG="/etc/httpd/sites-available/$6.conf"
			WAF_CONFIG="/etc/httpd/conf.d/mod_security.conf"
			WAF_CONFIG_MOD="/etc/httpd/mods-enabled/security2.conf"
			[[ ! -e $WAF_CONFIG_MOD ]] && WAF_CONFIG_MOD=$WAF_CONFIG
		else
			WEB_CONFIG="/etc/nginx/nginx.conf"
			SECURITY_CONF="/etc/nginx/conf.d/security.conf"
			VH_CONFIG="/etc/nginx/sites-available/$6.conf"
			WAF_CONFIG="/etc/nginx/modsec/modsecurity.conf"
			WAF_CONFIG_MOD="/etc/nginx/modsec/crs-setup.conf"
		fi
		if [[ $4 == "MySQL" ]]; then
			DBM_CONFIG="/etc/my.cnf"
		else
			DBM_CONFIG="/var/lib/pgsql/data/"
			DBM_CONF="/var/lib/pgsql/data/pg_hba.conf"
		fi
	fi
	FIREWALL_CONFIG="./Modulos/Auxiliares/firewall/iptables.v4"

	CRON_SCRIPT="/usr/bin/backup_cron.sh"
	echo '#!/bin/bash' > $CRON_SCRIPT
	echo -e '\nDATE=$(date "+%F")' >> $CRON_SCRIPT

	mkdir backup
	cd backup
	CURR_DIR=$PWD
	chown $SUDO_USER:$SUDO_USER $CURR_DIR -R
	DATE=$(date "+%F")
	log_errors $? "Se crea directorio de respaldos en: $CURR_DIR"
	# Respaldo de configuraciones Web
	tar -czvf "$CURR_DIR/$DATE-config_files_web.tar.gz" \
	-C $(dirname $WEB_CONFIG) $(basename $WEB_CONFIG) \
	-C  $(dirname $VH_CONFIG) $(basename $VH_CONFIG) \
	-C $(dirname $SECURITY_CONF) $(basename $SECURITY_CONF)
	log_errors $? "Respaldos de configuraciones web actuales: $DATE-config_files_web.tar.gz"
	echo "tar -czvf "$CURR_DIR/'$DATE'-config_files_web.tar.gz" \
	-C $(dirname $WEB_CONFIG) $(basename $WEB_CONFIG) \
	-C $(dirname $VH_CONFIG) $(basename $VH_CONFIG) \
	-C $(dirname $SECURITY_CONF) $(basename $SECURITY_CONF)" >> $CRON_SCRIPT
	log_errors $? "Programación de respaldos de configuraciones web agregada en '$CRON_SCRIPT'"

	# Respaldo de config de BD
	[[ $4 == "PostgreSQL" ]] && CONF_PSQL="-C $(dirname $DBM_CONF) $(basename $DBM_CONF)"
	tar -czvf "$CURR_DIR/$DATE-config_files_db.tar.gz" \
	-C $(dirname $DBM_CONFIG) $(basename $DBM_CONFIG) $CONF_PSQL
	log_errors $? "Respaldos de configuraciones de BD actuales: $DATE-config_files_db.tar.gz"
	echo "tar -czvf "$CURR_DIR/'$DATE'-config_files_db.tar.gz" \
	-C $(dirname $DBM_CONFIG) $(basename $DBM_CONFIG) $CONF_PSQL" >> $CRON_SCRIPT
	log_errors $? "Programación de respaldos de configuraciones de BD agregada en '$CRON_SCRIPT'"

	# Respaldo de config de WAF
	if [[ -e $WAF_CONFIG ]]; then
		tar -czvf "$CURR_DIR/$DATE-config_files_waf.tar.gz" \
		-C $(dirname $WAF_CONFIG) $(basename $WAF_CONFIG) \
		-C $(dirname $WAF_CONFIG_MOD) $(basename $WAF_CONFIG_MOD)
		log_errors $? "Respaldo de configuraciones WAF actuales: $DATE-config_files_waf.tar.gz"
		echo "tar -czvf "$CURR_DIR/'$DATE'-config_files_waf.tar.gz" \
		-C $(dirname $WAF_CONFIG) $(basename $WAF_CONFIG) \
		-C $(dirname $WAF_CONFIG_MOD) $(basename $WAF_CONFIG_MOD)" >> $CRON_SCRIPT
		log_errors $? "Programación de respaldos de WAF de BD agregada en '$CRON_SCRIPT'"
	fi

	# Respaldo de config de Firewall
	if [[ -e $FIREWALL_CONFIG ]]; then
		tar -czvf "$CURR_DIR/$DATE-config_files_firewall.tar.gz" \
		-C $(dirname $FIREWALL_CONFIG) $(basename $FIREWALL_CONFIG)
		log_errors $? "Respaldo de configuraciones de firewall actuales: $DATE-config_files_firewall.tar.gz"
		echo "tar -czvf "$CURR_DIR/'$DATE'-config_files_firewall.tar.gz" \
		-C $(dirname $FIREWALL_CONFIG) $(basename $FIREWALL_CONFIG)" >> $CRON_SCRIPT
		log_errors $? "Programación de respaldos de firewall agregada en '$CRON_SCRIPT'"
	fi
	echo "Respaldo de datos:"
	# Respaldo sitio web
	tar -czf "$CURR_DIR/$DATE-$6.tar.gz" \
	-C $5 $6
	log_errors $? "Respaldo de datos de sitio web actual: $DATE-$6.tar.gz"
	echo "tar -czvf $CURR_DIR/'$DATE'-$6.tar.gz \
	-C $5 $6" >> $CRON_SCRIPT
	log_errors $? "Programación de respaldo de datos de sitio web agregada en '$CRON_SCRIPT'"

	# Respaldo de BD
	read -sp "Ingresa la contraseña del usuario '$7' de la BD para hacer el respaldo: " DB_PASS; echo -e "\n"
	if [[ $4 == "MySQL" ]]; then
		mysqldump -u $7 --password=$DB_PASS -h $8 -P $9 ${10} > "$DATE-${10}.sql"
		log_errors $? "Respaldo de BD actual: $DATE-${10}.sql"
		echo "mysqldump -u $7 --password=$DB_PASS -h $8 -P $9 ${10} > '$DATE'-${10}.sql" >> $CRON_SCRIPT
		log_errors $? "Programación de respaldo de BD agregada en '$CRON_SCRIPT'"
	else
		su -c "PGPASSWORD="$DB_PASS" pg_dump -U $7 -h $8 -p $9 ${10} > $DATE-${10}.sql"
		log_errors $? "Respaldo de BD actual: $DATE-${10}.sql"
		echo "su -c \"PGPASSWORD=\"$DB_PASS\" pg_dump -U $7 -h $8 -p $9 ${10} > '$DATE'-${10}.sql\"" >> $CRON_SCRIPT
		log_errors $? "Programación de respaldo de BD agregada en '$CRON_SCRIPT'"
	fi

	chown $SUDO_USER:$SUDO_USER $CURR_DIR -R
	log_errors $? "Se asigna como dueño del directorio '$PWD' a '$SUDO_USER'"
	echo "chown $SUDO_USER:$SUDO_USER $CURR_DIR -R" >> $CRON_SCRIPT
	log_errors $? "Programación como dueño del directorio en '$CRON_SCRIPT'"
	HOUR=$(echo ${11} | cut -f1 -d":")
	MIN=$(echo ${11} | cut -f2 -d":")
	CRONTAB="/etc/crontab"
	chmod 700 $CRON_SCRIPT
	# hour		min		day_of_month		month		day_of_week		user command_to_be_executed
	# Se agrega ejecución de script para respaldos
	echo "$MIN $HOUR		*	*	$1 		root		$CRON_SCRIPT" >> $CRONTAB
	log_errors $? "Respaldos programados: $1 on $HOUR:$MIN"
	if [[ $2 =~ Debian.* ]]; then systemctl restart cron; else service crond restart; fi
	cd -
}

backups "$1" "$2" "$3" "$4" "$5" \
"$6" "$7" "$8" "$9" "${10}" "${11}" \
"${12}" "${13}"
