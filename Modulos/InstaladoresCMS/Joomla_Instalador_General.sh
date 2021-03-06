#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de Joomla para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##

# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Usuario de la Base de Datos
# Argumento 3: Servidor de la base de Datos (localhost, ip, etc.)
# Argumento 4: Puerto de la Base de Datos
# Argumento 5: Ruta de instalacion de joomla
# Argumento 6: Version de Joomla
# Argumento 7: SO
# Argumento 8: Manejador de DB ['MySQL'|'PostgreSQL']
# Argumento 9: Base de datos existente ['Yes'|'No']
# Argumento 10: Correo de administrador
# Argumento 11: Web server ['Apache'|'Nginx']
# Argumento 12: Nombre de dominio del sitio
# Argumento 13: Compatibilidad con IPv6
# Argumento 14: Versión del manejador de base de datos

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
## @brief Funcion que realiza la instalacion de las dependencias de php para Joomla
## @param $1 El sistema operativo donde se desea instalar Joomla : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $2 Manejador de base de datos para la instalaci[on de Joomla
## @param $3 Servidor web con el que se realiza la instalacion : 'Apache' o 'Nginx'
## @param $4 Nombre de dominio del sitio
## @param $5 Ruta donde se instalara Joomla
## @param $6 Compatibilidad con IPv6
##
install_dep(){
	# $1=SO; $2=DBM; $3=WEB_SERVER; $4=DOMAIN_NAME; $5=PATH_INSTALL: $6=IPv6
	case $1 in
		'Debian 9' | 'Debian 10')
			[[ $3 == "Apache" ]] && PHP="php7.3"
			[[ $3 == "Nginx" ]] && PHP="php7.3-fpm"
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"; else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			cmd="apt install $PHP php7.3-common \
			php7.3-gd php7.3-json php7.3-mbstring \
			php7.3-xml php7.3-zip unzip zip -y"
			$cmd
			log_errors $? "Instalacion de PHP en Joomla: $cmd"
			if [[ $2 == 'MySQL' ]]; then
				cmd="apt install php7.3-mysqli -y"
				$cmd
				log_errors $? "Instalacion de dependencias Joomla: $cmd"
			else
				cmd="apt install php7.3-mysqli php7.3-pgsql -y"
				$cmd
				log_errors $? "Instalacion de dependencias Joomla: $cmd"
			fi
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				log_errors $? "Instalacion de libapache2-mod-php7.3: "
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				apt install apache2-utils -y
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6" "joomla"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			[[ $3 == "Apache" ]] && PHP="php"
			[[ $3 == "Nginx" ]] && PHP="php-fpm"
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			cmd="yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y"
			$cmd
			log_errors 0 "Instalacion de dependencias Joomla: $cmd"
			cmd="yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y"
			$cmd
			log_errors 0 "Instalacion de dependencias Joomla: $cmd"
			cmd="yum install yum-utils -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			cmd="yum-config-manager --enable remi-php73 -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			cmd="yum install wget $PHP php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-intl php-zip php-xmlrpc unzip zip -y"
			$cmd
			log_errors $? "Instalacion de dependencias Joomla: $cmd"
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-mysql php-pgsql -y; fi
			log_errors $? "Instalacion de PHP7.3-$2: "
			if [[ $3 == 'Apache' ]]; then
				yum install -y httpd-tools
				bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$1" "$4" "$5"
			else
				yum install -y httpd-tools
				bash ./Modulos/InstaladoresCMS/virtual_host_nginx.sh "$1" "$4" "$5" "$6" "joomla"
			fi
			;;
	esac
}

## @fn modulos_joomla()
## @brief Funcion que instala y habilita modulos para captcha y de seguridad
## @param $1 Ruta del directorio raiz donde se instalara Joomla
## @param $2 Nombre de dominio del sitio
##
modulos_joomla(){
	# Se instalan modulos para captcha y medidas de seguridad adicionales
	wget https://github.com/osolgithub/OSOLCaptcha4Joomla3/archive/master.zip
	mv master.zip OSOLCaptcha4Joomla3.zip
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla extension:installfile --www=$1 $2 OSOLCaptcha4Joomla3.zip"
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla extension:enable --www=$1 $2 osolcaptcha"
	rm OSOLCaptcha4Joomla3.zip

	wget https://downloads.kubik-rubik.de/joomla-extensions/plg_easycalccheckplus_v3.1.6.zip
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla extension:installfile --www=$1 $2 plg_easycalccheckplus_v3.1.6.zip"
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla extension:enable --www=$1 $2 easycalccheckplus"
	rm plg_easycalccheckplus_v3.1.6.zip

}

## @fn install_composer()
## @brief Funcion que realiza la instalacion de composer
##
## Composer es necesario para poder instalar Joomla de forma remota (Por linea de comando)
##
install_composer(){
	wget https://getcomposer.org/installer
	mv installer composer-setup.php
	php composer-setup.php
	rm composer-setup.php
	mv composer.phar /usr/bin/composer
	echo "============ Instalando composer =============="
	su $SUDO_USER -c "composer global require consolidation/cgr"
	echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc
. ~/.bashrc
	echo "Para instalar joomla se requiere ingresar la contraseña del usuario '$SUDO_USER'"
	su $SUDO_USER -c 'echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc'
	#su $SUDO_USER -c "composer  require nesbot/carbon"
	#log_errors $? "Instalacion de composer: composer  require nesbot/carbon"
}

## @fn install_joomla()
## @brief Funcion que realiza la instalacion de Joomla
## @param $1 Nombre de la base de  para Joomla
## @param $2 Usuario de la base de datos para Joomla
## @param $3 Servidor de la base de datos (host)
## @param $4 Puerto al que se conecta el manejador de base de datos
## @param $5 Ruta del directorio raiz donde se instalara Joomla
## @param $6 Version de Joomla que se desea instalar
## @param $7 Nombre de dominio del sitio
## @param $8 Manejador de base de datos para el sitio ['MySQL' o 'PostgreSQL']
## @param $9 Valor que indica si se cuenta con una base de datos externa
## @param $10 Correo del administrador que se introdujo en el formulario web
## @param $11 Ruta del directorio donde fue ejecutado el script main.sh
## @param $12 El sistema operativo donde se desea instalar Joomla : 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
## @param $13 Nombre de usuario con el que se ejecuta el servidor web
## @param $14 Versión del manejador de base de datos
##
install_joomla(){
	# $1=dbname $2=dbuser $3=dbhost $4=dbport $5=ruta $6=version
	# $7=DOMAIN_NAME; $8=DBM; $9=DB_EXISTS; ${10}=EMAIL_NOTIFICATION;
	# ${11}=TEMP_PATH; ${12}=SO; ${13}=WEB_USER; ${14}=DB_VERSION
	DBM="mysqli"
	[[ ${12} == 'CentOS 6' ]] && DBM="mysql"
	if [[ $8 == "PostgreSQL" ]]; then
		if [[ ${12} =~ Debian.* ]]; then
			apt install mariadb-server -y
			if [[ ${12} == "Debian 10" ]]; then
				DB_CONF_PGSQL="database_conf.pgsql"
				sed -i "s/\(^local\s.*all\s.*all\s.*\)peer/\1md5/" /etc/postgresql/11/main/pg_hba.conf
			else
				DB_CONF_PGSQL="database_conf_d9.pgsql"
				sed -i "s/\(^local\s.*all\s.*all\s.*\)peer/\1md5/" /etc/postgresql/9.6/main/pg_hba.conf
			fi
			systemctl restart postgresql
		else
			if [[ ${12} == 'CentOS 6' ]]; then
				rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
				rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
				yum --enablerepo=remi,remi-test -y install mysql-server
			else
				yum -y install mariadb-server
				systemctl start mariadb
			fi
			if [[ ${14} == "11" ]]; then
				DB_CONF_PGSQL="database_conf.pgsql"
			else
				DB_CONF_PGSQL="database_conf_d9.pgsql"
			fi
			sed -i "s/\(^local\s.*all\s.*all\s.*\)peer/\1md5/" /var/lib/pgsql/${14}/data/pg_hba.conf
			service postgresql-${14} restart
		fi
		mysql -e "CREATE USER 'temp' IDENTIFIED BY 'temp'; GRANT ALL PRIVILEGES ON *.* TO 'temp'; FLUSH PRIVILEGES;"
	fi

	su $SUDO_USER -c "composer global require joomlatools/console"

	#clear
	while true; do
		read -sp "Ingresa el password del usuario '$2' de la base de datos de Joomla: " passDB; echo -e "\n"
		if [[ -n $passDB ]]; then
			if [[ $8 == "PostgreSQL" ]]; then
				su postgres -c "PGPASSWORD="$passDB" psql -h $3 -p $4 -d $1 -U $2 -c '\q'"
			else
				mysql -h $3 -P $4 -u $2 --password=$passDB $1 -e "\q"
			fi
			[[ $? == '0' ]] && break
		fi
	done

	while true; do
		read -p "Ingresa el nombre para el administrador de Joomla: " adminuser
		[[ -n $adminuser ]] && break
	done

	while true; do
		read -sp "Ingresa el password para el '$adminuser' de Joomla: " adminpass; echo -e "\n"
		if [[ -n $adminpass ]]; then
			read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
			[[ "$adminpass" == "$userPass2" ]] && userPass2="" && break
			echo -e "No coinciden!\n"
		fi
	done

	if [[ ${12} == 'CentOS 6' ]]; then
		echo "<?php echo password_hash(\"$adminpass\", PASSWORD_BCRYPT);?>" > script.php
		adminpass_hash=$(php -f script.php)
		rm script.php
	else
		adminpass_hash=$(htpasswd -bnBC 10 "" $adminpass | tr -d ':\n')
	fi

	read -p "Ingresa el nombre del sitio ['$7' por defecto]: " site
	if [ -z "$site" ]; then site="$7"; fi
	echo -e "sitename: '$site'\ncaptcha: 0\nmailfrom: '${10}'\nlog_path: '$5/$7/administrator/logs'\ndebug: 0\nsef: 0\naccess: '3'" > sitio.yaml

	chown $SUDO_USER:$SUDO_USER "$5"

	if [[ $8 == "PostgreSQL" ]]; then
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla site:create --www=$5 --mysql-driver=$DBM --mysql-login="temp:temp" --release=$6 --clear-cache --sample-data=default --disable-ssl $7 --options=sitio.yaml -q"
		log_errors $? "Instalacion de joomla"

		if [[ $9 == "No" ]]; then
			sed -i "s/temp_user/$2/g" "${11}/Modulos/InstaladoresCMS/$DB_CONF_PGSQL"
			#echo "Introduce la contraseña del usuario '$2' de la BD"
			su -c "PGPASSWORD=$passDB psql -U $2 $1 < ${11}/Modulos/InstaladoresCMS/$DB_CONF_PGSQL"
			log_errors $? "Configuracion con PostgreSQL"
		fi

		sed -i "s/\(.*public.*sitename.*= \)'.*';/\1'$site';/" $7/configuration.php
		sed -i "s/\(.*public.*dbtype = \)'mysqli';/\1'pgsql';/" $7/configuration.php
		sed -i "s/\(.*public.*host.*= \)'.*';/\1'$3';/" $7/configuration.php
		sed -i "s/\(.*public.*user = \)'.*';/\1'$2';/" $7/configuration.php
		sed -i "s/\(.*public.*password = \)'.*';/\1'$passDB';/" $7/configuration.php
		sed -i "s/\(.*public.*db = \)'.*';/\1'$1';/" $7/configuration.php
		sed -i "s/\(.*public.*mailfrom.*= \)'.*';/\1'${10}';/" $7/configuration.php
		sed -i "s/\(.*public.*debug = \).*;/\10;/" $7/configuration.php
		sed -i "s/\(.*public.*sef = \).*;/\10;/" $7/configuration.php
		sed -i "s/\(.*public.*dbprefix = \).*;/\1'j_';/" $7/configuration.php

		log_errors $? "Actualizacion de BD y elementos adicionales del sitio"
	else
		if [[ $9 == "No" ]]; then
			su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla site:create --www=$5 -H $3 -P $4 --mysql-database=$1 --mysql-driver=$DBM --mysql-login="$2:$passDB" --release=$6 --clear-cache --skip-create-statement --sample-data=default --disable-ssl $7 --options=sitio.yaml -q"
			log_errors $? "Instalacion de joomla"
		else
			su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/joomla site:create --www=$5 -H $3 -P $4 --mysql-database=$1 --mysql-driver=$DBM --mysql-login="$2:$passDB" --release=$6 --clear-cache --skip-create-statement --sample-data=default --disable-ssl $7 --options=sitio.yaml -q"
			log_errors $? "Instalacion de joomla"
		fi
	fi

	modulos_joomla "$5" "$7"

	# Se actualiza cuenta de administrador con las credenciales proporcionadas
	if [[ "$8" == "MySQL" ]]; then
		mysql -h $3 -P $4 -u $2 --password=$passDB $1 -e "update j_users set username=\"$adminuser\", password=\"$adminpass_hash\",email=\"${10}\" where name=\"Super User\";"
	else
		#echo "Introduce la contraseña del usuario '$2' de la BD"
		su -c "PGPASSWORD=$passDB psql -U $2 $1 -c \"update j_users set username='$adminuser', password='${adminpass_hash//\$/\\$}', email='${10}' where name='Super User';\""
		rm "${11}/Modulos/InstaladoresCMS/$DB_CONF_PGSQL"
		if [[ ${12} =~ Debian.* ]]; then
			apt purge mariadb-server -y
		else
			[[ ${12} == 'CentOS 7' ]] && yum -y remove mariadb-server
			[[ ${12} == 'CentOS 6' ]] && yum -y remove mysql-server
		fi

	fi
	log_errors $? "Configuracion de administrador '$adminuser' para joomla"

	echo "Estoy en: $PWD"
	# Permisos de carpetas y archivos
	find . -type f -exec chmod 644 {} +
	log_errors $? "Permisos en archivos: 644"
	find . -type d -exec chmod 755 {} +
	log_errors $? "Permisos en carpetas: 755"
	chown $USER:$USER . -R


	# Permisos de escritura para log y tmp
	chown -R ${13}:${13} $7/administrator/logs $7/tmp $7/plugins $7/administrator/language
	log_errors $? "Permisos de escritura para archivos log y tmp de joomla"
	rm sitio.yaml
	rm -r install_*

	[[ ${12} =~ CentOS.* ]] && [[ $8 == 'PostgreSQL' ]] && sed -i "s/\(^local\s.*all\s.*all\s.*\)md5/\1peer/" /var/lib/pgsql/${14}/data/pg_hba.conf && service postgresql-${14} restart

	jq -c -n --arg title "$site" --arg joomla_admin "$adminuser" --arg joomla_admin_pass "$adminpass" \
	'{Title: $title, joomla_admin:$joomla_admin, joomla_admin_pass:$joomla_admin_pass}' \
	> ${11}/joomlaInfo.json
}

echo "===============================================" | tee -a $LOG
echo "     Inicia la instalacion de Joomla $6" | tee -a $LOG
echo "===============================================" | tee -a $LOG

TEMP_PATH="$(su $SUDO_USER -c "pwd")"
mkdir -p "$5"

install_dep "$7" "$8" "${11}" "${12}" "$5" "${13}"

install_composer

WEB_USER=$(grep -o "^www-data" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^apache" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^httpd" /etc/passwd)
[[ -z $WEB_USER ]] && WEB_USER=$(grep -o "^nginx" /etc/passwd)

cd $5
install_joomla "$1" "$2" "$3" "$4" "$5" "$6" "${12}" "$8" "$9" "${10}" \
"$TEMP_PATH" "$7" "$WEB_USER" "${14}"
