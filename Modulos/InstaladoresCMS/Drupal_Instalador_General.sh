#!/bin/bash -e
##############################################################
# Script para la instalacion de Drupal en Debian 9 y 10 y 	 #
# CentOS 6 y 7                                               #
##############################################################

# Argumento 1: Sistema Operativo
# Argumento 2: Versión de Drupal a instalar
# Argumento 3: Manejador de BD
# Argumento 4: Nombre de la Base de Datos
# Argumento 5: Servidor de base de datos (localhost, ip, etc..)
# Argumento 6: Puerto de servidor de base de datos
# Argumento 7: Usuario de la Base de Datos
# Argumento 8: Ruta de Instalacion de Drupal
# Argumento 9: Url de Drupal
# Argumento 10: Correo de notificaciones
# Argumento 11: Web Server

# Se devuelve un archivo json con la informacion y credenciales
# de la instalacion de Drupal

#Requisitos
install_dep(){
	# $1=SO; $2=DBM; $3=WEB_SERVER; $4=DOMAIN_NAME; $5=PATH_INSTALL
	case $1 in
		'Debian 9' | 'Debian 10')
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"; else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			apt install php7.3 php7.3-common \
			php7.3-gd php7.3-json php7.3-mbstring \
			php7.3-xml php7.3-zip unzip zip -y
			if [[ $2 == 'MySQL' ]]; then apt install php7.3-mysql -y;
			else apt install php7.3-pgsql -y; fi
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.3 -y
				virtual_host_apache "$1" "$4" "$5"
			else
				site_default_nginx "Debian"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y
			yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y
			yum install yum-utils -y
			yum-config-manager --enable remi-php73 -y
			yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
			if [[ $3 == 'Apache' ]]; then
#				yum install libapache2-mod-php -y
#				a2enmod rewrite;
				site_default_apache "CentOS"
				virtual_host_apache "$1" "$4" "$5"
			else
				site_default_nginx "CentOS"
			fi
			;;
	esac
}

# Se permite .htacces para Drupal
virtual_host_apache(){
# $1=SO; $2=DomainName; $3=PathInstall
	if [[ $1 =~ CentOS.* ]]; then
		yum install
		SISTEMA="/etc/httpd/sites-available/$2.conf"
	else
		SISTEMA="/etc/apache2/sites-available/$2.conf"
	fi
	if [[ $2 =~ [^www.]* ]]; then SERVERNAME="www.$2"; else SERVERNAME=$2; fi
	echo "
	<VirtualHost *:80>
		ServerName $SERVERNAME
		ServerAlias $2
		DocumentRoot /var/www/html/$2
		<Directory /var/www/html/$2>
				AllowOverride All
				Require all granted
		</Directory>

		ErrorLog /var/log/apache2/error.log
		CustomLog /var/log/apache2/access.log combined
		#ErrorLog /var/www/html/$2/error.log
		#CustomLog /var/www/html/$2/requests.log combined

	</VirtualHost>" |  tee $SISTEMA
		if [ $3 != "/var/www/html" ]; then
			ln -s $4 /var/www/html/$2
		fi

		if [[ $1 =~ Debian.* ]]; then
			cd /etc/apache2/sites-available/
			a2ensite $2.conf
			a2enmod rewrite
			cd -
			systemctl restart apache2
		else
			ln -s /etc/httpd/sites-available/$2.conf  /etc/httpd/sites-enabled/$2.conf
			setenforce 0
			if [[ $1 = 'CentOS 6' ]]; then
				service httpd restart
			else
				systemctl restart httpd
			fi
		fi
}

site_default_nginx(){
	echo "site_default_nginx: TODO"
}
# Verifica existencia de git, composer, drush
git_composer_drush(){
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

	if [ $(which composer) ]; then
				echo $(composer --version)
		else
				# Instalación de composer
				 wget https://getcomposer.org/installer
				 mv installer composer-setup.php
				 php composer-setup.php
				 rm composer-setup.php
				 mv composer.phar /usr/bin/composer
				 echo "Instalando composer ###########################################"
				 #composer global require consolidation/cgr
				 su $SUDO_USER -c "composer global require consolidation/cgr"
				 #PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"
				 #PATH="/$PROYECTO/vendor/bin:$PATH"

				 echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc
				 . ~/.bashrc
				 echo "Para instalar drush se requiere ingresar la contraseña del usuario '$SUDO_USER'"
				 su $SUDO_USER -c 'echo "export PATH="$(su $SUDO_USER -c "composer config -g home")/vendor/bin:$PATH"" >> ~/.bashrc'
				 # . ~/.bashrc  # NOTA: Cargar $PATH para utilizar drush con el usuario que utilizó "sudo"
	fi

	if [ $(which drush) ]
		then
				echo $(drush version)
		else
				# Instalación de drush
				echo "Instalando drush ###########################################"
				su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/cgr drush/drush:8.x"
				#cgr drush/drush:8.x
	fi
}


# Se hace respaldo del sitio
backup(){
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush archive-dump --root=$1 --destination=$1.tar.gz -v --overwrite"
}

# Módulos
modulos_configuraciones(){
	if [[ $1 =~ 7.* ]]; then
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset drupal_http_request_fails 1"
		 # Se incluye captcha en inicio de sesión
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 dl captcha && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 en captcha image_captcha -y"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 dl captcha_webform && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 en captcha_webform -y"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset captcha_default_challenge 'image_captcha/Image'"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset captcha_default_validation 0"
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset captcha_persistence 0"
		 # Se deshabilita creación de cuentas de forma pública
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 vset user_register 0"
		 # Se deshabilita comentarios de los usuarios públicos
		 su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		 rmp 'anonymous user' 'post comments'"  # rmp -> alias de role-remove-perm
	else
		# Se incluye captcha en inicio de sesión
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush	\
		dl captcha && $(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		en captcha image_captcha -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush	\
		config-set captcha.settings default_challenge image_captcha/Image -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set captcha.settings default_validation 0 -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set captcha.settings persistence 0 -y"
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set captcha.captcha_point.user_login_form status true -y"
		# Se deshabilita creación de cuentas de forma pública
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		config-set user.settings register admin_only -y"
		# Se deshabilita comentarios de los usuarios públicos
		su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush \
		rmp anonymous 'post comments'"  # rmp -> alias de role-remove-perm
	fi
}


drupal_installer(){
	# $1=CMS_VERSION; $2=DBM; $3=DB_USER; $4=DB_IP; $5=DB_PORT; $6=DB_NAME;
	# $7=DOMAIN_NAME; $8=EMAIL_NOTIFICATION; $9=DB_EXISTS ${10}=TEMP_PATH
	if [[ $2 == 'MySQL' ]]; then DBM="mysql"; else DBM="pgsql"; fi
	git_composer_drush
	# Se instala drupal con Drush
	echo "Instalando drupal ######################################################"

	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush dl drupal-$1 --drupal-project-rename=$7"

	read -sp "Ingresa la contraseña del usuario '$3' de la BD: " DB_PASS; echo -e "\n"
	read -p "Ingresa el usuario para configurar Drupal: " CMS_USER
	read -sp "Ingresa la contraseña del usuario '$CMS_USER' para configurar Drupal: " CMS_PASS; echo -e "\n"
	read -p "Ingresa el nombre que tendrá el sitio ['$7' por defecto]: " SITE_NAME
	if [ -z "$SITE_NAME" ]; then SITE_NAME="$7"; fi

	cd $7

	if [[ $9 == "Yes" ]]; then
		DB_NAME="dbtemporal"
		if [[ $2 == "MySQL" ]]; then
			mysql -h $4 -P $5 -u $3 --password=$DB_PASS -e "CREATE DATABASE dbtemporal;"
			#log_errors $? "Creación de base de datos 'dbtemporal' (necesaria para la configuración) en MySQL, servidor $5"
		else
			su postgres -c "psql -h $5 -p $6 -d $3 -U $4 -c 'CREATE DATABASE dbtemporal;'"
		fi
	else
		DB_NAME="$6"
	fi
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush si standard --account-name="$CMS_USER" --account-pass="$CMS_PASS" \
	--db-url="$DBM://$3:$DB_PASS@$4:$5/$DB_NAME" --site-name=$SITE_NAME --account-mail=$8 -y"
	if [[ $9 == "Yes" ]]; then
		sed -i "s/\(^\s.*'database'.*=>\s\)'dbtemporal',/\1'$6',/" sites/default/settings.php
		if [[ $2 == "MySQL" ]]; then
			mysql -h $4 -P $5 -u $3 --password=$DB_PASS -e "DROP DATABASE dbtemporal;"
		else
			su postgres -c "psql -h $5 -p $6 -d $3 -U $4 -c 'DROP DATABASE dbtemporal;'"
		fi
	fi

	chown www-data:www-data sites/default/files/

	modulos_configuraciones "$1"

	jq -c -n --arg title "$SITE_NAME" --arg drup_admin "$CMS_USER" --arg drup_admin_pass "$CMS_PASS" \
	'{Title: $title, drup_admin:$drup_admin, drup_admin_pass:$drup_admin_pass}' \
	> ${10}/drupalInfo.json

}

SO=$1
DRUPAL_VERSION=$2
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
mkdir -p $PATH_INSTALL
install_dep "$SO" "$DBM" "$WEB_SERVER" "$DOMAIN_NAME" "$PATH_INSTALL"
chown $SUDO_USER:$SUDO_USER $PATH_INSTALL
TEMP_PATH="$(su $SUDO_USER -c "pwd")"
cd $PATH_INSTALL
drupal_installer "$DRUPAL_VERSION" "$DBM" "$DB_USER" "$DB_IP" "$DB_PORT"\
									"$DB_NAME" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION" "$DB_EXISTS"\
									"$TEMP_PATH"
