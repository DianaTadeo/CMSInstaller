#!/bin/bash -e
##############################################################
# Script para la instalacion de wordpress en Debian 9 y 10 y #
# CentOS 6 y 7                                               #
#############################################################

# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Servidor de base de datos (localhost, ip, etc..)
# Argumento 3: Usuario de la Base de Datos
# Argumento 4: Puerto de la base de Datos
# Argumento 5: Ruta de Instalacion de Wordpress
# Argumento 6: Url de Wordpress
# Argumento 7: Correo de notificaciones
# Argumento 8: 'PostgreSQL' | 'MySQL'
# Argumento 9: 'Nginx' |'Apache'
# Argumento 10: 'CentOS' | 'Debian'
# Se devuelve un archivo json con la informacion y credenciales 
# de la instalacion de Wordpress
instalacion_WP(){
	#$1=DBName $2=DBHost $3=DBUser $4=DBPort $5=WPDirRoot $6=DBManager $7=WebServer $8=OS
	clear
	echo "==============================================="
	echo "	Se inicia la instalacion de Wordpress"
	echo "==============================================="

	echo "Ingresa el password del usuario de la base de datos: "
	read -s dbpass
	mkdir $5
	cd $5
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod u+x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	wp --allow-root core download
	wp --allow-root core config --dbhost=$2:$4 --dbname=$1 --dbuser=$3 --dbpass=$dbpass
	if [[ $6 == 'PostgreSQL' ]]; then
		apt-get install php-pgsql php-mysql -y
		wget https://downloads.wordpress.org/plugin/wppg.1.0.1.zip
		unzip wppg.1.0.1.zip
		mv wppg $5/wp-content/plugins/
		rm wppg.1.0.1.zip
		cp $5/wp-content/plugins/wppg/pg4wp/db.php $5/wp-content/
		sed -i 's/wp-content\/pg4wp/wp-content\/plugins\/wppg\/pg4wp/' $5/wp-content/db.php
		#sed -i 's/database_name_here/$1/' $5/wordpress/wp-config.php
		#sed -i 's/username_here/$3/' $5/wordpress/wp-config.php
		#sed -i 's/password_here/$dbpass/' $5/wordpress/wp-config.php
		#sed -i 's/localhost/$2:$4/' $5/wordpress/wp-config.php
		
	fi
	chmod 644 wp-config.php
	chown -R www-data:www-data $5
	if [[ $7 == 'Apache' ]]; then
		if [[ $8 == 'Debian' ]]; then
			systemctl restart apache2
		else
			systemctl restart httpd
		fi
	else
		systemctl restart nginx
	fi
}

configuracion_WP(){
	# $1=Url $2=mail
	echo "==============================================="
	echo "   Se inicia la configuracion de Wordpress"
	echo "==============================================="

	echo "Ingresa el titulo de la pagina"
	read -s title
	echo "Ingresa un nombre de usuario para ser administrador"
	read -s wp_admin
	echo "Ingresa el password para este usuario"
	read -sp wp_pass
	wp --allow-root core install --url=$1 --title=$title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$2
	mkdir wp-content/uploads
	chmod 775 wp-content/uploads
	wp --allow-root plugin install simple-login-captcha --activate
	wp --allow-root plugin install 
	echo "==============================================="
	echo "     Wordpress se instalo correctamente"
	echo "==============================================="
	echo "{\"Title\": $title, \"wp_admin\": $wp_admin, \"wp_admin_pass\": $wp_pass }" > wpInfo.json
}

echo "======Se va a instalar con $1=DBName $2=DBHost $3=DBUser $4=DBPort $5=WPDirRoot $8=DBManager $9=WebServer $10=OS\n"
instalacion_WP "$1" "$2" "$3" "$4" "$5" "$8" "$9" "$10"
echo "======Se va a configurar con $6=Url $7=mail\n"
configuracion_WP "$6" "$7"
