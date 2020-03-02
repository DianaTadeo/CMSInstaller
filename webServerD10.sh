#!/bin/bash

utilerias(){
	# Instalación de utilerías para realizar la configuración del sitio web y adicionales
	# jq -> utilería para manipular JSON
	# expect -> utilería para automatizar scripts interactivos
	apt install vim wget curl subversion jq expect -y
}

web_server_apache(){
	# Instalación de apache y php
	apt install apache2 php7.3 libapache2-mod-php -y
	a2enmod php7.3
	systemctl enable apache2
	systemctl restart apache2.service
}

recaptcha_setup(){
	# Configuración de reCAPTCHA necesario para el funcionamiento del sitio web
	echo -e "\n\nInstrucciones para obtener el par de claves \
(pública y privada) necesarias para la configuración.\n\
Inicia sesión en el siguiente sitio con tu cuenta de Google y rellena el formulario: \
https://www.google.com/u/2/recaptcha/admin/create\n\n
NOTA: Utilizar reCAPTCHA v2 y nombre de dominio: '$1'.\n\
Una vez que el par de claves se generó. Procede a copiarlas en el script cuando \
se te soliciten."
	read -p "Continuar con la configuración del reCAPTCHA [S\n]: " RESP
	if [ -z "$RESP" ]; then RESP="S"; fi
	if [[ $RESP =~ s|S ]]; then
		while true; do
			echo "Primer clave"
			read -p "Public key: " reCAPTCHA_PUB_KEY
			[ -n "$reCAPTCHA_PUB_KEY" ] && break
		done
		while true; do
			echo "Segunda clave"
			read -p "Private key: " reCAPTCHA_PRIV_KEY
			[ -n "$reCAPTCHA_PRIV_KEY" ] && break
		done
		sed -i "s#CLAVE_DE_SITIO_WEB_AQUI#$reCAPTCHA_PUB_KEY#" index.html
		sed -i "s#CLAVE_SECRETA_AQUI#$reCAPTCHA_PRIV_KEY#" assets/settings.php
		systemctl restart apache2
		echo -e "\n\nEl sitio '$1' está listo"
	else
		echo "\n\nDeberás configurar el reCAPTCHA de forma manual (de lo contrario \
el formulario no funcionará):\
https://www.google.com/u/2/recaptcha/admin/create colocando \
la clave pública en la línea 'CLAVE_DE_SITIO_WEB_AQUI' del archivo \
'$2/$1/index.html'  y  la clave privada en la línea \
'CLAVE_SECRETA_AQUI' del archivo '$2/$1/assets/settings.php"
	fi
}

if [ $(id -u) -ne 0 ]
	then
		echo -e "Ejecuta como usuario root.\nUsage: sudo ./webServerD10.sh"
		exit
fi


echo "Para configurar el sitio web es obligatorio contar con una cuenta de Google \
y poder realizar la configuración del reCAPTCHA (Se mostrarán las instrucciones \
más adelante)"
read -p "Continuar con la configuración del sitio [S\n]: " RESP
if [ -z "$RESP" ]; then RESP="S"; fi
[[ ! $RESP =~ S|s|Y|y ]] && echo "Ejecuta nuevamente el script cuando tengas tu cuenta de Google." && exit


# se instalan utilerías necesarias y adicionales
utilerias
# se instala apache y php para montar el sitio web
web_server_apache

SO="Debian 10"
WEB_SERVER="Apache"
WEB_USER="www-data"

while true; do
	read -p "Ingresa la ruta de instalación para el sitio web ['/var/www/html' por defecto]: " PATH_INSTALL
	if [ -z "$PATH_INSTALL" ]; then PATH_INSTALL="/var/www/html"; else mkdir -p $PATH_INSTALL; fi
	[[ -d $PATH_INSTALL ]] && break
done

read -p "Ingresa el nombre de dominio para el sitio web ['cmsinstaller.com' por defecto]: " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then DOMAIN_NAME="cmsinstaller.com"; fi

cd $PATH_INSTALL

# descarga directorio CMS/ (dispomible en el repositorio de github del proyecto)
# svn export https://github.com/USER/PROJECT/trunk/PATH DEST
svn export https://github.com/DianaTadeo/CMSInstaller/trunk/CMS $DOMAIN_NAME

cd $DOMAIN_NAME/Installer

mkdir -p ./Modulos/Log
chmod +x ./Modulos/InstaladoresCMS/virtual_host_apache.sh ./Modulos/Auxiliares/Web_Configuration_Sec.sh ./Modulos/InstaladoresCMS/openssl_req.exp
bash ./Modulos/InstaladoresCMS/virtual_host_apache.sh "$SO" "$DOMAIN_NAME" "$PATH_INSTALL"
bash ./Modulos/Auxiliares/Web_Configuration_Sec.sh "$SO" "$WEB_SERVER" "$DOMAIN_NAME"
rm -r ./Modulos/Log/

sed -i "s#Header set Content-Security-Policy.*#Header set Content-Security-Policy \"script-src 'self' 'unsafe-inline' 'unsafe-eval' ajax.googleapis.com https://apis.google.com https://www.google.com/recaptcha/api.js https://www.gstatic.com/recaptcha/releases/61bII03-TtCmSUR7dw9MJF9q/recaptcha__en.js https://code.jquery.com/jquery-3.2.1.js;\"#" /etc/apache2/conf-enabled/security.conf
systemctl restart apache2

cd ..
chown -R $WEB_USER:$WEB_USER Downloads/ files/ hashes/ Installer/
find . -type f -exec chmod 644 {} +
find . -type d -exec chmod 755 {} +

recaptcha_setup "$DOMAIN_NAME" "$PATH_INSTALL"
