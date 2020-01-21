#!/bin/bash

####################################################################
# Script para la instalación de Fail2ban, Logwatch y Logcheck
# en Debian 9, 10 y CentOS 6, 7
# Argumento 1: SO
# Argumento 2: EMAIL_NOTIFICATION

LOG="`pwd`/../Log/Hardening.log"

###################### Log de Errores ###########################
# $1: Salida de error											#
# $2: Mensaje de la instalacion									#
#################################################################
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : $2 : [ERROR]" >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : $2 : [OK]" 	>> $LOG
	fi
}

web_server_ports(){
	if [[ -n $(echo $1 | grep " ") ]]; then
		echo $1 | tr " " ","
	else
		echo $1
	fi
}

install_fail2ban(){
	DESTEMAIL=$2
	BANTIME=$3
	FINDTIME=$4
	MAXRETRY=$5
	SENDER=$6
	case $1 in
		'Debian 9' | 'Debian 10')
			cmd="apt -y install fail2ban mailutils"
			$cmd
			log_errors $? "$cmd"
			APACHE_NAME="apache2"
			MYSQL_NAME="mysql"
			NGINX_NAME="nginx"
			# DEFAULT_SERVICES_ENABLED=$(systemctl list-unit-files --state=enabled | grep enabled | cut -f1 -d" " | tr '\n' ' ')
			;;
		'CentOS 6' | 'CentOS 7')
			cmd="yum install -y epel-release"
			$cmd
			log_errors $? "$cmd"

			cmd="yum install -y fail2ban postfix"
			$cmd
			log_errors $? "$cmd"

			if [[ "$1" = "CentOS 6" ]]; then
				APACHE_NAME="httpd"
				MYSQL_NAME="mysqld"
				NGINX_NAME="nginx"
			else # CentOS 7
				APACHE_NAME="httpd"
				MYSQL_NAME="mariadb"
				NGINX_NAME="nginx"
				# DEFAULT_SERVICES_ENABLED=$(systemctl list-unit-files --state=enabled | grep enabled | cut -f1 -d" " | tr '\n' ' ')
			fi
			;;
	esac

	# Se copian archivo jail.conf en jail.local para aplicar este archivo de configuración
	JAIL_LOCAL="/etc/fail2ban/jail.local"
	cp /etc/fail2ban/jail.conf $JAIL_LOCAL
	cmd="sed -i -e "/#.*$/d" -e "/^$/d" prueba.local"
	$cmd
	log_errors $? "Se quitan comentarios de archivo fail.local: $cmd"

	sed -i "0,/\(bantime[ \t]*=\).*/s/\(bantime[ \t]*=\).*/\1 $BANTIME/" $JAIL_LOCAL
	log_errors $? "Se asgina bantime=$BANTIME"

	sed -i "0,/\(findtime[ \t]*=\).*/s/\(findtime[ \t]*=\).*/\1 $FINDTIME/" $JAIL_LOCAL
	log_errors $? "Se asgina findtime=$FINDTIME"

	sed -i "0,/\(maxretry[ \t]*=\).*/s/\(maxretry[ \t]*=\).*/\1 $MAXRETRY/" $JAIL_LOCAL
	log_errors $? "Se asigna maxretry=$MAXRETRY"

	sed -i "s/\(^destemail[ \t]*=\).*/\1 $DESTEMAIL/" $JAIL_LOCAL
	log_errors $? "Se asigna destemail=$DESTEMAIL"

	sed -i "s/\(^sender[ \t]*=\).*/\1 $SENDER/" $JAIL_LOCAL
	log_errors $? "Se asigna sender=$SENDER"

	# Default action. Will block user and send you an email with whois content and log lines.
	sed -i "s/\(^action[ \t]*=\).*/\1 %(action_mwl)s/" $JAIL_LOCAL
	log_errors $? "Se asigna action= %(action_mwl)s para enviar email con contenido whois y log"

	sed -i 's/\(\[sshd\]\)/\1 \nenabled = true/' $JAIL_LOCAL
	log_errors $? "Se habilita protección sshd"

	if [[ $(which $APACHE_NAME) ]]; then
		sed -i 's/\(\[apache-auth\]\)/\1 \nenabled = true/' $JAIL_LOCAL
		sed -i 's/\(\[apache-badbots\]\)/\1 \nenabled = true/' $JAIL_LOCAL
		sed -i 's/\(\[apache-shellshock\]\)/\1 \nenabled = true/' $JAIL_LOCAL
		log_errors $? "Se habilita protección de $APACHE_NAME"
		APACHE_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "apache2" | cut -d":" -f2 | sort -n | uniq | cut -d" " -f1)
		HTTPD_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "httpd" | cut -d":" -f2 | sort -n | uniq | cut -d" " -f1)

		if [[ -n "$APACHE_PORT" ]];then
			sed -i "s/\(^port*=\)*http*/\1 $(web_server_ports "$APACHE_PORT") /" $JAIL_LOCAL
		fi

		if [[ -n "$HTTPD_PORT" ]];then
			sed -i "s/\(^port*=\)*http*/\1 $(web_server_ports "$HTTPD_PORT") /" $JAIL_LOCAL
		fi
	fi

	if [[ $(which $NGINX_NAME) ]]; then
		sed -i 's/\(\[nginx-http-auth\]\)/\1 \nenabled = true/' $JAIL_LOCAL
		log_errors "$?" "Se habilita protección de $NGINX_NAME"
		NGINX_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "nginx" | cut -d":" -f2 | sort -n | uniq | cut -d" " -f1)
		if [[ -n "$NGINX_PORT" ]];then
			sed -i "s/\(^port*=\)*http*/\1 $(web_server_ports "$APACHE_PORT") /" $JAIL_LOCAL
		fi

	fi

	SSH_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "ssh\|sshd" | cut -d":" -f2 | sort -n | uniq  | cut -d" " -f1)

	if [[ -n "$SSH_PORT" ]];then
			sed -i "s/\(^port*=\)*ssh$/\1 $ssh_port /" $JAIL_LOCAL
	fi

	if [[ $1 == 'CentOS 6']]; then
		cmd="service fail2ban restart"
	else
		cmd="systemctl restart fail2ban"
	fi
	$cmd
	log_errors $? "$cmd"
}

install_logwatch(){
	if [[ "$1" == "Debian 9"  ]] || [[ "$1" == "Debian 10"  ]]; then
		cmd="apt -y install logwatch mailutils postfix"
		$cmd
		log_errors $? "$cmd"
	else
		cmd="yum install -y epel-release"
		$cmd
		log_errors $? "$cmd"

		cmd="yum install -y logwatch postfix"
		$cmd
		log_errors $? "$cmd"
	fi

	LOGWATCH_CONF="/usr/share/logwatch/default.conf/logwatch.conf"

	sed -i "s/\(^Output[ \t]*=\).*/\1 mail/" $LOGWATCH_CONF
	log_errors $? "Salida asignada=mail"

	sed -i "s/\(^MailTo[ \t]*=\).*/\1 $2/" $LOGWATCH_CONF
	log_errors $? "Correo para recibir notificaciones de fail2ban: $2"

	sed -i "s/\(^Detail[ \t]*=\).*/\1 Low/" $LOGWATCH_CONF
	log_errors $? "Nivel de detalle: Low"
}

install_logcheck(){
	if [[ "$1" == "Debian 9"  ]] || [[ "$1" == "Debian 10"  ]]; then
		cmd="apt -y install logcheck mailutils postfix"
		$cmd
		log_errors $? "$cmd"
	else
		cmd="yum install -y epel-release"
		$cmd
		log_errors $? "$cmd"

		cmd="yum install -y logcheck postfix"
		$cmd
		log_errors $? "$cmd"
	fi

	# Archivo de configuración de logcheck
	LOGCHECK_CONF="/etc/logcheck/logcheck.conf"

	# Archivos log que se van a monitorear
	LOGCHECK_LOGFILES="/etc/logcheck/logcheck.logfiles"

	#Sets mail that will receive reports
	sed -i "s/SENDMAILTO=\"logcheck\"/SENDMAILTO=\"$2\"/" $LOGCHECK_CONF
	log_errors $? "Se asigna correo que recibirá los reportes de logcheck: $2"

	# Archivos log de los servidores web y mail
	APACHE_ACCESS="/var/log/apache2/access.log"
	APACHE_ERROR="/var/log/apache2/error.log"
	HTTPD_ACCESS="/var/log/httpd/access_log"
	HTTPD_ERROR="/var/log/httpd/error_log"
	NGINX_ACCESS="/var/log/nginx/access.log"
	NGINX_ERROR="/var/log/nginx/error.log"
	MAIL_LOG="/var/log/mail.log"
	MAILLOG="/var/log/maillog"

	if [ -f "$APACHE_ACCESS" ]; then
				echo "$APACHE_ACCESS" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$APACHE_ERROR" ]; then
				echo "$APACHE_ERROR" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$HTTPD_ACCESS" ]; then
				echo "$HTTPD_ACCESS" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$HTTPD_ERROR" ]; then
				echo "$HTTPD_ERROR" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$NGINX_ACCESS" ]; then
				echo "$NGINX_ACCESS" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$NGINX_ERROR" ]; then
				echo "$NGINX_ERROR" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$MAIL_LOG" ]; then
				echo "$MAIL_LOG" >> LOGCHECK_LOGFILES
	fi
	if [ -f "$MAILLOG" ]; then
				echo "$MAILLOG" >> LOGCHECK_LOGFILES
	fi
}

####################################################
#	main de instalación de f2b, logwatch y logcheck	 #
####################################################

SO=$1
# Dirección en la que se recibirán las notficaciones -> $2
DESTEMAIL=$2
# Tiempo de baneo en segundos de una IP
BANTIME=600
# Tiempo para que el contador de intentos fallidos de una determinada IP se reinicie
FINDTIME=300
# Número de intentos de autenticación máximos fallidos antes de un bloqueo
MAXRETRY=3
# Dirección con la que se enviarán los correos
SENDER="root@localhost"

if [[ $(which fail2ban) ]]; then
	echo "Fail2ban ya está instalado: $(fail2ban --version)" >> $LOG
else
	install_fail2ban "$SO" "$DESTEMAIL" "$BANTIME" "$FINDTIME" "$MAXRETRY" "$SENDER"
fi

if [[ $(which logwatch) ]]; then
	echo "Fail2ban ya está instalado: $(which logwatch)" >> $LOG
else
	install_logwatch "$SO" "$DESTEMAIL"
fi

if [[ $(which logcheck) ]]; then
	echo "Logcheck ya está instalado: $(which logcheck)" >> $LOG
else
	install_logcheck "$SO" "$DESTEMAIL"
fi