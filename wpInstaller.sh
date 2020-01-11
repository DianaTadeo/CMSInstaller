#!/bin/bash -e
##############################################################
# Script para la instalacion de wordpress en Debian 9 y 10 y #
# CentOS 6 y 7                                               #
#############################################################

# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Servidor de base de datos (localhost, ip, etc..)
# Argumento 3: Usuario de la Base de Datos
# Argumento 4: Ruta de Instalacion de Wordpress
# Argumento 5: Url de Wordpress
# Argumento 6: Correo de notificaciones

# Se devuelve un archivo json con la informacion y credenciales 
# de la instalacion de Wordpress

clear
echo "==============================================="
echo "	Se inicia la instalacion de Wordpress"
echo "==============================================="

echo "Ingresa el password del usuario de la base de datos: "
read -s dbpass

mkdir $4
cd $4
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod u+x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --allow-root core download
wp --allow-root core config --dbhost=$2 --dbname=$1 --dbuser=$3 --dbpass=$dbpass
chmod 644 wp-config.php

echo "==============================================="
echo "   Se inicia la configuracion de Wordpress"
echo "==============================================="

echo "Ingresa el titulo de la pagina"
read -s title
echo "Ingresa un nombre de usuario para ser administrador"
read -s wp_admin
echo "Ingresa el password para este usuario"
read -sP wp_pass
wp --allow-root core install --url=$5 --title=$title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$6
mkdir wp-content/uploads
chmod 775 wp-content/uploads
wp --allow-root plugin install simple-login-captcha --activate
echo "==============================================="
echo "     Wordpress se instalo correctamente"
echo "==============================================="
fi
echo "{\"Title\": $title, \"wp_admin\": $wp_admin, \"wp_admin_pass\": $wp_pass }" > wpInfo.json
