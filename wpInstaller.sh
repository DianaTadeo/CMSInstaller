#!/bin/bash -e
clear
echo "============================================"
echo "WordPress Install Script"
echo "============================================"
echo "Database Name: "
read -e dbname
echo "Database User: "
read -e dbuser
echo "Database Password: "
read -s dbpass
#echo "run install? (y/n)"
#read -e run
#if [ "$run" == n ] ; then
#exit
#else
#echo "============================================"
#echo "A robot is now installing WordPress for you."
#echo "============================================"
#mkdir /var/www/html/wordpress
#cd /var/www/html/wordpress
#wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
#chmod u+x wp-cli.phar
#mv wp-cli.phar /usr/local/bin/wp
wp --allow-root core download
wp --allow-root core config --dbhost=localhost --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass
chmod 644 wp-config.php
echo "Ingresa la url de la pagina de wordpress"
read -e url
echo "Ingresa el titulo de la pagina"
read -e title
echo "Ingresa un nombre de usuario para ser administrador"
read -e wp_admin
echo "Ingresa el password para este usuario"
read -e wp_pass
echo "Ingresa un correo para este usuario"
read -e mail
wp --allow-root core install --url=$url --title=$title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$mail
mkdir wp-content/uploads
chmod 775 wp-content/uploads

wp --allow-root plugin install simple-login-captcha --activate
echo "========================="
echo "Installation is complete."
echo "========================="
fi
