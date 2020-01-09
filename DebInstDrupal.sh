#!/bin/bash

#Se debe de copiar el programa a /var/www al ejecutarlo lo debe hacer un usuario normal con acceso a sudo, funciona para debian 8

function isinstalled() {
	if apt -q list installed $pack &>/dev/null; then
		true
	else
		false
  	fi
}

function isinstalledDrush (){
	$pack --version > /dev/null 2>&1
	DRUSH=$?
	if [[ $DRUSH -ne 0 ]]; then 
		false
	else
		true
	fi
}

######################################################
#####      Seccion para revisar dependencias     #####
######################################################
echo "Se revisa si existen las siguientes dependencias..."
apt install php -y
apt install curl -y
apt install composer -y

if isinstalled git; then
	echo `git --version`
else
	echo "No se encuentra instalado git. Instalando"
	apt install git
fi
if isinstalled composer; then
	echo `composer --version`
else
	echo "No se encuentra instalado composer. Instalando"
	#Obteniendo composer
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
	composer --version
	export PATH="$HOME/.composer/vendor/bin:$PATH"
fi
composer create-project drupal-composer/drupal-project:8.x-dev drupal-composer-build --stability dev --no-interaction

if isinstalledDrush drush; then
	echo `drush --version`
else
	echo "No se encuentra instalado drush. Instalando"
	wget https://github.com/drush-ops/drush/releases/download/8.0.1/drush.phar
	php drush.phar core-status
	chmod +x drush.phar
	mv drush.phar /usr/local/bin/drush
	echo $PATH
	drush init
	composer global update
	drush --version
fi


