#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script para la configuración general de hardening en Debian 9, 10 y CentOS 6, 7
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

## @fn disable_default_services()
## @brief Función que deshabilita los servicios del sistema predeterminados
## @param $1 Sistema operativo ['Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7']
##
disable_default_services(){
	# Función que deshabilita los servicios del sistema predeterminados
	# $1=SO
	# Servicios que no se deshabilitarán
	SERVICES_NOT_DISABLED="network.* ssh.* cron.* fail2ban.* keyboard.* \
	console.* r*sync.* r*sys.* system.* d-bus.* apache.* mysql.* p.*g.*sql.* \
	mariadb.* httpd.* nginx.* log(check|watch).* postfix.* php.*"
	case $1 in
		'Debian 9' | 'Debian 10' | 'CentOS 7')
			DEFAULT_SERVICES_ENABLED=$(systemctl list-unit-files --state=enabled --type=service | grep enabled | cut -f1 -d" " | tr '\n' ' ')
			DISABLE_CMD="systemctl disable"
			RESTART_SSH="systemctl restart ssh"
			;;
		'CentOS 6')
			DEFAULT_SERVICES_ENABLED=$(chkconfig --list | grep '3:\(activo\|on\)' | cut -d"0" -f1 | cut -d" " -f1 | tr '[[:space:]]' ' ')
			DISABLE_CMD="chkconfig --del"
			RESTART_SSH="service ssh restart"
			;;
	esac
	for SERVICE in $DEFAULT_SERVICES_ENABLED; do
		DIS="Yes"
		for NOT_DISABLE in $SERVICES_NOT_DISABLED; do
			if [[ "$SERVICE" =~ $NOT_DISABLE ]]; then
				DIS="No"
				break
			fi
		done
		if [[ $DIS == "Yes" ]]; then
			$DISABLE_CMD $SERVICE
			log_errors $? "Servicio deshabilitado: $SERVICE"
		fi
	done
	sed -i "s/.*\(PermitRootLogin\s*\)yes/\1no/" /etc/ssh/sshd_config
	log_errors 0 "Se deshabilita acceso root por ssh"
	$RESTART_SSH
}

## @fn disable_user_accounts()
## @brief Función que deshabilita las cuentas de usuario que tienen una shell definida en /etc/passwd
##
disable_user_accounts(){
	# Función que deshabilita las cuentas de usuario que tienen una shell definida en /etc/passwd
	# No deshabilita la cuenta root y la cuenta del usuario que ejecutó "sudo"
	USER_ACCOUNTS=$(grep "/bin/.*sh" /etc/passwd  | cut -d":" -f1)
	for ACCOUNT in $USER_ACCOUNTS; do
		if [[ "$ACCOUNT" != "$SUDO_USER" ]] && [[ "$ACCOUNT" != "root" ]] && [[ "$ACCOUNT" != "postgres" ]]; then
			usermod -L -e 1 $ACCOUNT  # -L bloquea la contraseña del usuario y -e 1 deshabilita la cuenta
			# para desbloquear: usermod -U -e "" $ACCOUNT
			log_errors $? "Esta cuenta fue deshabilitada: $ACCOUNT"
		fi
	done
}

## @fn password_policy()
## @brief Función que establece la política de conteseñas para los usuarios del sistema.
## @param $1 Sistema operativo ['Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7']
##
password_policy(){
	# Función que establece la política de conteseñas para los usuarios del sistema.
	# $1=SO
	case $1 in
		'Debian 9' | 'Debian 10')
			apt install libpam-pwquality -y
			log_errors $? "Instalación de libpam-pam_pwquality"
			PAM_D_COMMON_PASSWORD="/etc/pam.d/common-password"
			PAM_D_COMMON_AUTH="/etc/pam.d/common-auth"
			sed -i "s/\(auth.*sufficient.*\)pam_unix.*/\1pam_unix.so likeauth nullok/" $PAM_D_COMMON_AUTH
			sed -i "s/\(password.*sufficient.*\)pam_unix.*/\1pam_unix.so nullok use_authtok sha256 shadow remember=5/" $PAM_D_COMMON_PASSWORD
			log_errors $? "Se restringe que los usuarios reutilicen alguna de sus últimas 5 contraseñas anteriores"
			sed -i "s/\(password.*requi.*\)pam_pwquality.*/\1pam_pwquality.so try_first_pass retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 difok=0 reject_username enforce_for_root/" $PAM_D_COMMON_PASSWORD
			log_errors $? "Se aplica uso de contraseñas fuertes: longitud mínima de 8, con al menos 1 letra minúscula, 1 mayúscula, 1 dígito, 1 carácter especial"
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 = 'CentOS 6' ]]; then PAM_PASSW="pam_cracklib"; else PAM_PASSW="pam_pwquality"; fi
			PAM_D_CONF="/etc/pam.d/system-auth"
			sed -i "s/\(auth.*sufficient.*\)pam_unix.*/\1pam_unix.so likeauth nullok/" $PAM_D_CONF
			sed -i "s/\(password.*sufficient.*\)pam_unix.*/\1pam_unix.so nullok use_authtok sha256 shadow remember=5/" $PAM_D_CONF
			log_errors $? "Se restringe que los usuarios reutilicen alguna de sus últimas 5 contraseñas anteriores"
			sed -i "s/\(password.*requi.*\)$PAM_PASSW.*/\1$PAM_PASSW.so try_first_pass retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 difok=0 reject_username enforce_for_root/" $PAM_D_CONF
			log_errors $? "Se aplica uso de contraseñas fuertes: longitud mínima de 8, con al menos 1 letra minúscula, 1 mayúscula, 1 dígito, 1 carácter especial"
			;;
	esac
	LOGIN_DEFS="/etc/login.defs"
	sed -i "s/\(PASS_MAX_DAYS[\t\s]*\).*/\1180/" $LOGIN_DEFS
	sed -i "s/\(PASS_MIN_DAYS[\t\s]*\).*/\17/" $LOGIN_DEFS
	sed -i "s/\(PASS_WARN_AGE[\t\s]*\).*/\130/" $LOGIN_DEFS
	log_errors $? "Expiración de contraseñas (nuevos usuarios): cada 180 días (se advertirá 90 días antes) y mínimo 7"
	ACCOUNTS=$(grep "/bin/.*sh" /etc/passwd  | cut -d":" -f1)
	for ACCOUNT in $ACCOUNTS; do
		echo "Debes cambiar el password de '$ACCOUNT':"
		if [[ "$ACCOUNT" == "postgres" ]]; then
			su postgres -c "psql -c '\password'"
		else
			passwd $ACCOUNT
		fi
		chage -M 180 -m 7 -W 30 $ACCOUNT
	done
	log_errors $? "Expiración de contraseñas (usuarios existentes): cada 180 días (se adevertirá 30 días antes) y mínimo 7"

}

## @fn users_and_privileges()
## @brief Función que establece los permisos y dueños de archivos relevantes en el sistema
## @param $1 Sistema operativo ['Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7']
##
users_and_privileges(){
	# Función que establece los permisos y dueños de archivos relevantes en el sistema
	# $1=SO
	if [[ $1 = "CentOS 6" ]] || [[ $1 = "CentOS 7" ]]; then
		CRONTAB_PATH="/var/spool/cron/"
	else
		CRONTAB_PATH="/var/spool/cron/crontabs/"
	fi
	CRON_PATHS=("/etc/anacrontab" "/etc/crontab" "/etc/cron.* $CRONTAB_PATH")
	for CRON_FILE in ${CRON_PATHS[@]}; do
		if [[ -e "$CRON_FILE" ]]; then
			chown root:root $CRON_FILE
			chmod go-rwx $CRON_FILE
		fi
	done
	log_errors $? "Se establecen permisos \"rwx------\" y a \"root:root\" dueño de los archivos \"cron\""

	PGSG_FILES=("/etc/passwd" "/etc/group" "/etc/shadow" "/etc/gshadow")
	for FILE in ${PGSG_FILES[@]}; do
		if [[ $FILE = "/etc/passwd" ]] || [[ $FILE="/etc/group" ]]; then	VALUE="644";	else VALUE="600"; fi
		chmod $VALUE $FILE
		chown root:root $FILE
	done
	log_errors $? "Se establecen permisos \"rwx------\" y a \"root:root\" dueño de los archivos \"passwd,group,shadow,gshadow\""
}

## @fn sudo_policy()
## @brief Función que realiza las políticas de sudo y agrega usuarios a ese grupo
## @param $1 Sistema operativo ['Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7']
##
sudo_policy(){
	# Función que realiza las políticas de sudo y agrega usuarios a ese grupo
	# $1=SO
	USER_ACCOUNTS=$(grep "/bin/.*sh" /etc/passwd  | cut -d":" -f1)
	if [[ $1 =~ Debian.* ]]; then
		GROUP="sudo"; INSTALL="/usr/sbin/apt, /usr/sbin/apt-*"
		SERVICES="/usr/bin/systemctl, /usr/sbin/service"
	else
		GROUP="wheel"; INSTALL="/usr/sbin/yum"
		if [[$1 == 'CentOS 6']]; then
			SERVICES="/usr/sbin/service"
		else
			SERVICES="/usr/bin/systemctl, /usr/sbin/service"
		fi
	fi
	usermod -aG $GROUP $SUDO_USER
	log_errors $? "El usuario '$SUDO_USER' fue agregado al grupo '$GROUP'"
	echo "El usuario '$SUDO_USER' fue agregado al grupo '$GROUP'"
	while true; do
		read -p "Quieres agregar otros usuarios? [N/s]: " RESP
		if [ -z "$RESP" ]; then RESP="N"; fi
		if [[ $RESP =~ s|S ]]; then
			read -p "Indica el usuario que quieres añadir: " USER_NAME
			if [[ -n "$(echo $USER_ACCOUNTS | grep "$USER_NAME")" ]]; then
				usermod -aG $GROUP $USER_NAME
				log_errors $? "El usuario '$USER_NAME' fue agregado al grupo '$GROUP'"
			else
				echo "No existe el usuario '$USER_NAME'"
			fi
		else break;
		fi
	done
	mv /etc/sudoers /etc/sudoers.original
	SUDOERS_FILE="/etc/sudoers"
	echo '# /etc/sudoers' >> $SUDOERS_FILE
	echo "# This file MUST be edited with the 'visudo' command as root." >> $SUDOERS_FILE
	echo "Cmnd_Alias ALLOWED_EXEC = /usr/sbin/visudo, $INSTALL, $SERVICES" >> $SUDOERS_FILE
	log_errors $? "Comandos que permiten ejecutarse con sudo: /usr/sbin/visudo, $INSTALL, $SERVICES"
	echo 'Cmnd_Alias BLACKLIST = /usr/bin/su' >> $SUDOERS_FILE
	log_errors $? "Comandos que no permiten ejecutarse con sudo: su"
	echo 'Cmnd_Alias SHELLS = /usr/bin/sh, /usr/bin/bash' >> $SUDOERS_FILE
	log_errors $? "Intérpretes de comandos que no serán permitidas para evitar 'escape shell': bash y sh"
	echo 'Cmnd_Alias USER_WRITEABLE = /home/*, /tmp/*, /var/tmp/*' >> $SUDOERS_FILE
	log_errors $? "Directorios donde no se permitirá ejecutar scripts:  /home/*, /tmp/*, /var/tmp/*"
	echo 'Cmnd_Alias PAGERS = /usr/bin/less, /usr/bin/tail, /usr/bin/head, /usr/bin/more, /usr/bin/cat, /usr/bin/tac' >> $SUDOERS_FILE
	log_errors $? "Utilerías que no solicitarán contraseña cuando se utilicen: less, tail, head, more, cat, tac"

	echo 'Defaults env_reset, noexec, requiretty, use_pty' >> $SUDOERS_FILE
	log_errors $? "Defaults: env_reset, noexec, requiretty, use_pty"
	echo 'Defaults !visiblepw' >> $SUDOERS_FILE
	log_errors $? "Defaults: !visiblepw"

	echo 'Defaults editor = /usr/bin/vim:/usr/bin/vi:/usr/bin/nano' >> $SUDOERS_FILE
	log_errors $? "Se utiliza como editor para visudo: vim, vi, nano"
	echo 'Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin' >> $SUDOERS_FILE
	log_errors $? "Directorios donde es posible ejecutar archivos: /sbin:/bin:/usr/sbin:/usr/bin"
	echo 'Defaults  log_host, log_year, logfile="/var/log/sudo.log"' >> $SUDOERS_FILE
	log_errors $? "Se indica archivo donde se escribirá el log de sudo: /var/log/sudo.log"


	echo 'Defaults!ALLOWED_EXEC,SHELLS !noexec' >> $SUDOERS_FILE
	log_errors $? "Comandos que se permiten ejecutar y shells que no permiten 'escape shell': ALLOWED_EXEC, SHELLS"
	echo 'Defaults!SHELLS log_output' >> $SUDOERS_FILE
	log_errors $? "Se hara registro de la salida en pseudo tty: log_output"

	echo 'root    ALL=(ALL)   ALL' >> $SUDOERS_FILE
	log_errors $? "Se permite al usuario root ejecutar todos los comandos: ALL"
	echo "%$GROUP  ALL=(root)  ALL,!BLACKLIST,!USER_WRITEABLE, NOPASSWD: PAGERS" >> $SUDOERS_FILE
	log_errors $? "Se permiten a los usuarios del grupo '$GROUP' ejecutar los comandos como el usuario root: ALL,!BLACKLIST,!USER_WRITEABLE, NOPASSWD: PAGERS"

	# sudo -s no reinicia el entorno y pueden conservar sus preferencias en la shell;
	# admins can enforce permitted root shells just like whitelisting or blacklisting any other binary on the system
	echo -e "IMPORTANTE:\nPara cambiar a usuario root ejecutar: sudo -s "
}

## @fn additional_preferences()
## @brief Función que añade elementos adicionales de hardening y preferencias a los usuarios del sistema
##
additional_preferences(){
	echo "export HISTTIMEFORMAT=\"%F %T \"" >> /etc/profile
	log_errors $? "Se agrega marca de tiempo para el comando 'history' de los usuarios del sistema"
	sed -i 's/^\(tty\([5-9]\|[1-9][0-9]\)\+\)/#\1/' /etc/securetty
	log_errors $? "Se deja habilitado el uso de 4 tty"

}
disable_default_services "$1"
disable_user_accounts
password_policy "$1"
users_and_privileges "$1"
additional_preferences
sudo_policy "$1"
