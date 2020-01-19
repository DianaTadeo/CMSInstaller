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
	# $1=SO; $2=DBM; $3=WEB_SERVER
	case $1 in
		'Debian 9' | 'Debian 10')
			if [[ $1 == 'Debian 9' ]]; then VERSION_NAME="stretch"
		else VERSION_NAME="buster"; fi
			apt install ca-certificates apt-transport-https gnupg -y
			wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
			echo "deb https://packages.sury.org/php/ $VERSION_NAME main" | tee /etc/apt/sources.list.d/php.list
			apt update
			apt install php7.1 php7.1-common \
			php7.1-gd php7.1-json php7.1-mbstring \
			php7.1-xml php7.1-zip unzip zip -y
			if [[ $2 == 'MySQL' ]]; then apt install php7.1-mysql -y;
			else apt install php7.1-pgsql -y; fi
			if [[ $3 == 'Apache' ]]; then
				apt install libapache2-mod-php7.1 -y
				a2enmod rewrite
				site_default_apache "Debian" "Apache"
			else
				site_default_apache "Debian" "Nginx"
			fi
			;;
		'CentOS 6' | 'CentOS 7')
			if [[ $1 == 'CentOS 6' ]]; then VERSION="6"; else VERSION="7"; fi
			yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$VERSION.noarch.rpm -y
			yum install http://rpms.remirepo.net/enterprise/remi-release-$VERSION.rpm -y
			yum install yum-utils -y
			yum-config-manager --enable remi-php71 -y
			yum install wget php php-mcrypt php-cli php-curl php-gd php-pdo php-xml php-mbstring unzip -y
			if [[ $2 == 'MySQL' ]]; then yum install php-mysql -y; else yum install php-pgsql -y; fi
#			if [[ $3 == 'Apache' ]]; then
#				yum install libapache2-mod-php -y
#				a2enmod rewrite;
#			fi
			;;
	esac
}

# Se permite .htacces para Drupal
site_default_apache(){
	if [[ $1 == 'Debian' ]]; then
		FILE_SITE="/etc/apache2/sites-available/000-default.conf"
		#sed -i "s#/var/www/html#$2#" /etc/apache2/apache2.conf
	else
		FILE_SITE="/etc/httpd/sites-available/000-default.conf"
	fi
	echo "
<VirtualHost *:80>
			DocumentRoot /var/www/html
			<Directory /var/www/>
					AllowOverride All
					Require all granted
			</Directory>

			ErrorLog ${APACHE_LOG_DIR}/error.log
			CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" | tee $FILE_SITE
	if [[ $1 == 'Debian' ]]; then
		systemctl restart apache2.service
	else
		systemctl restart httpd.service
	fi
}

# Verifica existencia de git, composer, drush
existencia(){
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
modulos(){
	 su $SUDO_USER -c "composer require drupal/captcha"
	 su $SUDO_USER -c "composer require drupal/business_responsive_theme"
}

drupal_installer(){
	# $1=CMS_VERSION; $2=DBM; $3=DB_USER; $4=DB_IP; $5=DB_PORT; $6=DB_NAME;
	# $7=DOMAIN_NAME; $8=EMAIL_NOTIFICATION
	if [[ $2 == 'MySQL' ]]; then DBM="mysql"; else DBM="pgsql"; fi
	existencia
	# Se instala drupal con Drush
	echo "Instalando drupal ######################################################"

	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush dl drupal-$1"
	# drush dl drupal-$1
	read -sp "Ingresa la contraseña del usuario '$3' de la BD: " DB_PASS; echo -e "\n"
	read -p "Ingresa el usuario para configurar Drupal: " CMS_USER
	read -sp "Ingresa la contraseña del usuario '$CMS_USER' para configurar Drupal: " CMS_PASS; echo -e "\n"
	cd drupal-$1
	su $SUDO_USER -c "$(su $SUDO_USER -c "composer config -g home")/vendor/bin/drush si standard --account-name="$CMS_USER" --account-pass="$CMS_PASS" \
	--db-url="$DBM://$3:$DB_PASS@$4:$5/$6" --site-name=$7 --account-mail=$8"
	#drush si standard --account-name="$CMS_USER" --account-pass="$CMS_PASS" \
	#--db-url="$2://$3:$DB_PASS@$4:$5/$6" --site-name=$7 --account-mail=$8
	#modulos
	if [[ $PATH_INSTALL != '/var/www/html' ]]; then
		ln -s "$PATH_INSTALL" /var/www/html/
	fi
	jq -c -n --arg title "$7" --arg drup_admin "$CMS_USER" --arg drup_admin_pass "$CMS_PASS" \
	'{Title: $title, drup_admin:$drup_admin, drup_admin_pass:$drup_admin_pass}' \
	> drupalInfo.json

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
install_dep "$SO" "$DBM" "$WEB_SERVER"
mkdir -p $PATH_INSTALL
chown $SUDO_USER:$SUDO_USER $PATH_INSTALL
cd $PATH_INSTALL
drupal_installer "$DRUPAL_VERSION" "$DBM" "$DB_USER" "$DB_IP" "$DB_PORT"\
									"$DB_NAME" "$DOMAIN_NAME" "$EMAIL_NOTIFICATION"
cd -
