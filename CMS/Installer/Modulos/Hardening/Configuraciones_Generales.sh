#!/bin/bash

####################################################################
# Script para la configuración general de hardening
# en Debian 9, 10 y CentOS 6, 7
# Argumento 1: SO

LOG="`pwd`/Modulos/Log/Hardening.log"

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

disable_default_services(){
	# Función que deshabilita los servicios del sistema predeterminados
	# $1=SO
	# Servicios que no se deshabilitarán
	SERVICES_NOT_DISABLED="network.* ssh.* cron.* fail2ban.* keyboard.* \
	console.* r*sync.* r*sys.* system.* d-bus.* apache.* mysql.* p.*g.*sql.* \
	mariadb.* httpd.* nginx.* log(check|watch).* postfix.*"
	case $1 in
		'Debian 9' | 'Debian 10' | 'CentOS 7')
			DEFAULT_SERVICES_ENABLED=$(systemctl list-unit-files --state=enabled --type=service | grep enabled | cut -f1 -d" " | tr '\n' ' ')
			DISABLE_CMD="systemctl disable"
			;;
		'CentOS 6')
			DEFAULT_SERVICES_ENABLED=$(chkconfig --list | grep '3:\(activo\|on\)' | cut -d"0" -f1 | cut -d" " -f1 | tr '[[:space:]]' ' ')
			DISABLE_CMD="chkconfig --del"
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
}

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
	sed -i "s/\(PASS_MAX_DAYS[\t\s]*\).*/\190/" $LOGIN_DEFS
	sed -i "s/\(PASS_MIN_DAYS[\t\s]*\).*/\17/" $LOGIN_DEFS
	sed -i "s/\(PASS_WARN_AGE[\t\s]*\).*/\17/" $LOGIN_DEFS
	log_errors $? "Expiración de contraseñas (nuevos usuarios): cada 90 días (se advertirá 7 días antes) y mínimo 7"
	ACCOUNTS=$(grep "/bin/.*sh" /etc/passwd  | cut -d":" -f1)
	for ACCOUNT in $ACCOUNTS; do
		echo "Debes cambiar el password de '$ACCOUNT':"
		if [[ "$ACCOUNT" == "postgres" ]]; then
			su postgres -c "psql -c '\password'"
		else
			passwd $ACCOUNT
		fi
		chage -M 90 -m 7 -W 7 $ACCOUNT
	done
	log_errors $? "Expiración de contraseñas (usuarios existentes): cada 90 días (se adevertirá 7 días antes) y mínimo 7"

}

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

sudo_policy(){
	echo "sudo_policy: TODO"
}

disable_default_services "$1"
disable_user_accounts
password_policy "$1"
users_and_privileges "$1"
sudo_policy
