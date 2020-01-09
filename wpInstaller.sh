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
echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "============================================"
echo "A robot is now installing WordPress for you."
echo "============================================"
#download wordpress
#curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
#tar -zxvf latest.tar.gz
#change dir to wordpress
#cd wordpress
mkdir /var/www/html/wordpress
#copy file to parent dir
#cp -rf . /var/www/html/wordpress
#move back to parent dir
#remove files from wordpress folder
#rm -R wordpress
cd /var/www/html/wordpress
#create wp config
#cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
#sed -i -e "s/database_name_here/$dbname/g" wp-config.php
#sed -i -e "s/username_here/$dbuser/g" wp-config.php
#sed -i -e "s/password_here/$dbpass/g" wp-config.php

#set WP salts
#perl -i -pe'
#  BEGIN {
#    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
#    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
#    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
#  }
#  s/put your unique phrase here/salt()/ge
#' wp-config.php

#create uploads folder and set permissions
#mkdir wp-content/uploads
#chmod 775 wp-content/uploads
#echo "Cleaning..."
#remove zip file
#rm latest.tar.gz
#remove bash script
#rm wp.sh
#chown -R www-data:www-data ../wordpress
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod u+x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
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
