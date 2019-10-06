#!/bin/bash

#Se debe de copiar el programa a /var/www al ejecutarlo lo debe hacer un usuario normal con acceso a sudo, funciona para debian 8

function isinstalled() {
	if apt -q list installed $pack &>/dev/null; then
		true
	else
		false
  	fi
}

function isinstalled2 (){
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
if isinstalled git; then
	echo `git --version`
else
	echo "No se encuentra instalado git. Instalando"
	sudo apt install git
fi
if isinstalled composer; then
	echo `composer --version`
else
	echo "No se encuentra instalado composer. Instalando"
	sudo apt install curl
	#Obteniendo composer
	curl -sS https://getcomposer.org/installer | php
	sudo mv composer.phar /usr/local/bin/composer
	composer --version
fi
if isinstalled2 drush; then
	echo `drush --version`
else
	echo "No se encuentra instalado drush. Instalando"
	sudo wget https://github.com/drush-ops/drush/releases/download/8.0.1/drush.phar
	sudo php drush.phar core-status
	sudo chmod +x drush.phar
	sudo sudo mv drush.phar /usr/local/bin/drush
	echo $PATH
	drush init
fi
#######################################################
#####          Seccio de backup y update          #####
#######################################################


echo "Bienvenido, se muestran los directorios: "
c=0
#Se listan los directorios que estan en /var/www
for d in /var/www/*; do
        eval "var$c=$d";
        echo $c $d
        c=$((c+1));
done
now=$(date +%m-%d-%y-%H%M)

echo "Seleccione uno: "
read val
if [ $val -eq 0 ];
then
        echo "Se procede a realizar el backup de . Esto puede tardar unos minutos".
        #drupa={var0::-1}
        cd $var1
        sudo tar -czvf /tmp/drupal.$now.tar.gz ../
	cd -
	echo "El respaldo se se guardo en /tmp/drupal.$now.tar.gz"
	echo "Se procede a realizar la actualizacion."
	posdrup=$(find $var0 -name ".htaccess" | head -n 1| sed 's/\(.*\)\.\(htaccess\)/\1/')
	cd $posdrup
	sudo drush up --yes
	cd -
	echo "Revise la instalacion de drupal en su navegador y compruebe su funcionalidad, escoja una de las siguientes opciones: "
	echo "1.- Si funciona"
	echo "2.- No funciona, quiero regresar a la version anterior"
	read respuesta
	if [ $respuesta -eq 1 ];
	then
        	echo "Actualizado por el team dinamita"
	elif [ $respuesta -eq 2  ];
	then
        	echo "Regresando a la version anterior espere un momento"
        	echo /tmp/drupal.$now.tar.gz
		sudo rm -rf $var0
		sudo tar -xvf /tmp/drupal.$now.tar.gz -C /var/www/
		ls /var/www
	else
        	echo "Opcion no valida"
	fi

elif [ $val -eq 1 ];
then
        echo "Se procede a realizar el backup de $var1. Esto puede tardar unos minutos".
        #drupa={var0::-1}
	cd $var1
        sudo tar -czvf /tmp/drupal.$now.tar.gz ../
	echo "El respaldo se se guardo en /tmp/drupal.$now.tar.gz"
	cd -
	echo "Se procede a realizar la actualizacion."
	posdrup=$(find $var1 -name ".htaccess" | head -n 1| sed 's/\(.*\)\.\(htaccess\)/\1/')
	echo $posdrup
	cd $posdrup
	sudo drush up --yes
	cd -
	echo "Revise la instalacion de drupal en su navegador y compruebe su funcionalidad, escoja una de las siguientes opciones: "
	echo "1.- Si funciona"
	echo "2.- No funciona, quiero regresar a la version anterior"
	read respuesta

	if [ $respuesta -eq 1 ];
	then
		echo "Actualizado por el team dinamita"
	elif [ $respuesta -eq 2  ];
	then
        	echo "Regresando a la version anterior espere un momento"
        	echo /tmp/drupal.$now.tar.gz
		sudo rm -rf $var1
		sudo tar -xvf /tmp/drupal.$now.tar.gz -C /var/www/
		ls /var/www
	else
        	echo "Opcion no valida"
	fi
elif [[ $val -eq 2 ]]
then
        echo "Se procede a realizar el backup de . Esto puede tardar unos minutos".
        #drupa={var2::-1}
	cd $var1
        sudo tar -czvf /tmp/drupal.$now.tar.gz ../
	cd -
	echo "El respaldo se se guardo en /tmp/drupal.$now.tar.gz"

	echo "Se procede a realizar la actualizacion."
	posdrup=$(find $var2 -name ".htaccess" | head -n 1| sed 's/\(.*\)\.\(htaccess\)/\1/')
	echo $posdrup
	cd $posdrup
	sudo drush up --yes
	echo "Revise la instalacion de drupal en su navegador y compruebe su funcionalidad, escoja una de las siguientes opciones: "
	echo "1.- Si funciona"
	echo "2.- No funciona, quiero regresar a la version anterior"
	read respuesta

	if [ $respuesta -eq 1 ];
	then
        	echo "Actualizado por el team dinamita"
	elif [ $respuesta -eq 2  ];
	then
        	echo "Regresando a la version anterior espere un momento"
        	echo /tmp/drupal.$now.tar.gz
		sudo rm -rf $var2
		sudo tar -xvf /tmp/drupal.$now.tar.gz -C /var/www/
		ls /var/www
	else
        	echo "Opcion no valida"
	fi
elif [[ $val -eq 3 ]]
then
        echo "Se procede a realizar el backup de . Esto puede tardar unos minutos".
        #drupa={var3::-1}
        cd $var1
        sudo tar -czvf /tmp/drupal.$now.tar.gz ../
	cd -
	echo "El respaldo se se guardo en /tmp/drupal.$now.tar.gz"

	echo "Se procede a realizar la actualizacion."
	posdrup=$(find $var1 -name ".htaccess" | head -n 1| sed 's/\(.*\)\.\(htaccess\)/\1/')
	echo $posdrup
	cd $posdrup
	sudo drush up --yes
	echo "Revise la instalacion de drupal en su navegador y compruebe su funcionalidad, escoja una de las siguientes opciones de instalcion de drupal: "
	echo "1.- Si funciona"
	echo "2.- No funciona, quiero regresar a la version anterior"
	read respuesta

	if [ $respuesta -eq 1 ];
	then
        	"Actualizado por el team dinamita"
	elif [ $respuesta -eq 2  ];
	then
        	echo "Regresando a la version anterior espere un momento"
        	echo /tmp/drupal.$now.tar.gz
		sudo rm -rf $var3
		sudo tar -xvf /tmp/drupal.$now.tar.gz -C /var/www/
		ls /var/www
	else
        	echo "Opcion no valida"
	fi
fi


