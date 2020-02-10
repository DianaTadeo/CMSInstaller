#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador y configurador de Fail2Ban, LogWatch y LogCheck en Debian 9, 10 y CentOS 6, 7
## @version 1.0
##
## Este archivo permite instalar y confirgurar programas que permiten el monitoreo y ciertas configuraciones de seguridad.

# Argumento 1: SO
# Argumento 2: EMAIL_NOTIFICATION

LOG="`pwd`/Modulos/Log/Hardening.log"


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

## @fn web_server_ports()
## @brief Da formato a los puertos de entrada
## @param $1 Entrada de Puertos del Servidor web
##
web_server_ports(){
	if [[ -n $(echo $1 | grep " ") ]]; then
		echo $1 | tr " " ","
	else
		echo $1
	fi
}

## @fn install_fail2ban()
## @brief Realiza la instalacion de Fail2ban
## @param $1 Sistema operativo donde se instalara
## @param $2 Mail donde se enviaran las notificaciones
## @param $3 Tiempo de banneo
## @param $4 Tiempo de entrada
## @param $5 Maxima cantidad de intentos
## Qparam $6 Correo de envio
##
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

	sed -i 's/\(^\[sshd\]\)/\1 \nenabled = true\nfilter = sshd/' $JAIL_LOCAL
	log_errors $? "Se habilita protección sshd"

	if [[ $(which $APACHE_NAME) ]]; then
		#sed -i 's/\(\[apache-auth\]\)/\1 \nenabled = true\nfilter = apache-auth/' $JAIL_LOCAL
		sed -i 's/\(\[apache-badbots\]\)/\1 \nenabled = true\nfilter = apache-badbots/' $JAIL_LOCAL
		sed -i 's/\(\[apache-shellshock\]\)/\1 \nenabled = true\nfilter = apache-shellshock/' $JAIL_LOCAL
		log_errors $? "Se habilita protección de $APACHE_NAME"
		APACHE_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "apache2" | cut -d":" -f2 | sort -n | uniq | cut -d" " -f1)
		HTTPD_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "httpd" | cut -d":" -f2 | sort -n | uniq | cut -d" " -f1)

		if [[ -n "$APACHE_PORT" ]];then
			sed -i "s/\(^port\s\+=\)\s\+http.*/\1 $(web_server_ports "$APACHE_PORT") /" $JAIL_LOCAL
		fi

		if [[ -n "$HTTPD_PORT" ]];then
			sed -i "s/\(^port\s\+=\)\s\+http.*/\1 $(web_server_ports "$HTTPD_PORT") /" $JAIL_LOCAL
		fi
	fi

	if [[ $(which $NGINX_NAME) ]]; then
		#sed -i 's/\(\[nginx-http-auth\]\)/\1 \nenabled = true\nfilter = nginx-http-auth/' $JAIL_LOCAL
		#log_errors "$?" "Se habilita protección de $NGINX_NAME"
		NGINX_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "nginx" | cut -d":" -f2 | sort -n | uniq | cut -d" " -f1)
		if [[ -n "$NGINX_PORT" ]];then
			sed -i "s/\(^port\s\+=\)\s\+http.*/\1 $(web_server_ports "$NGINX_PORT") /" $JAIL_LOCAL
		fi

	fi

	SSH_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "ssh\|sshd" | cut -d":" -f2 | sort -n | uniq  | cut -d" " -f1)

	if [[ -n "$SSH_PORT" ]];then
			sed -i "s/\(^port*=\)*ssh$/\1 $SSH_PORT /" $JAIL_LOCAL
	fi

	if [[ $1 == 'CentOS 6' ]]; then
		cmd="service fail2ban restart"
	else
		cmd="systemctl restart fail2ban"
	fi
	$cmd
	log_errors $? "$cmd"
}

## @fn install_logcheck()
## @brief Realiza la instalacion de LogWatch
## @param $1 Sistema operativo donde se instalara
## @param $2 Correo de notificaciones
##
install_logwatch(){
	if [[ "$1" == "Debian 9"  ]] || [[ "$1" == "Debian 10"  ]]; then
		DEBIAN_FRONTEND=noninteractive apt \
		-o Dpkg::Options::=--force-confold \
		-o Dpkg::Options::=--force-confdef \
		-y install logwatch mailutils postfix
		cmd="apt install logwatch mailutils postfix -y"
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

## @fn install_logcheck()
## @brief Realiza la instalacion de LogCheck
## @param $1 Sistema operativo donde se instalara
##
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
	sed -i "s/\(SENDMAILTO=\)\"logcheck\"/\1\"$2\"/" $LOGCHECK_CONF
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
				echo "$APACHE_ACCESS" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$APACHE_ERROR" ]; then
				echo "$APACHE_ERROR" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$HTTPD_ACCESS" ]; then
				echo "$HTTPD_ACCESS" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$HTTPD_ERROR" ]; then
				echo "$HTTPD_ERROR" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$NGINX_ACCESS" ]; then
				echo "$NGINX_ACCESS" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$NGINX_ERROR" ]; then
				echo "$NGINX_ERROR" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$MAIL_LOG" ]; then
				echo "$MAIL_LOG" >> $LOGCHECK_LOGFILES
	fi
	if [ -f "$MAILLOG" ]; then
				echo "$MAILLOG" >> $LOGCHECK_LOGFILES
	fi
}

#====================================================#
#	main de instalación de f2b, logwatch y logcheck	 #
#====================================================#

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
