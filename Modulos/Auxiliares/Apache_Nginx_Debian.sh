#!/bin/bash
##################################################
#Instalador de apache y Nginx para Debian 9 y 10 #
##################################################



#Argumento 1: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 2: Version del web server

LOG="`pwd`/../Log/Aux_Instalacion.log"

###################### Log de Errores ###########################
# $1: Salida de error											#
# $2: Mensaje de la instalacion									#
#################################################################
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : $2 : [ERROR]" >> $LOG
		exit_install
	else
		echo "[`date +"%F %X"`] : $2 : [OK]" 	>> $LOG
	fi
}

################## Instalacion de Nginx #########################
# $1: Version													#
#################################################################
install_nginx(){
	echo "deb http://nginx.org/packages/mainline/debian stretch nginx" >> /etc/apt/sources.list
	
	wget http://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	apt update
	
	echo "[`date +"%F %X"`] Instalando Nginx version $1"
	cmd="apt -y install nginx=$1"
	$cmd
	log_errors $? "Instalacion de Nginx"
	
	echo "[`date +"%F %X"`] Instalando dependencias de Nginx"
	cmd="apt -y install libtool autoconf build-essential libpcre3-dev zlib1g-dev libssl-dev libxml2-dev libgeoip-dev liblmdb-dev libyajl-dev libcurl4-openssl-dev libpcre++-dev pkgconf libxslt1-dev libgd-dev"
	$cmd
	log_errors $? "Instalacion de dependencias de Naginx"
	rm nginx_signing.key
}

#install_modsecurity_nginx(){
#	
#}


################## Instalacion de Apache ##########################
# $1: Version													  #
###################################################################
install_apache(){
	echo "deb http://security.debian.org jessie/updates main \ndeb http://security.debian.org stretch/updates main" >> /etc/apt/sources.list
	wget http://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	apt update
	
	echo "[`date +"%F %X"`] Instalando Apache version $1"
	cmd="apt -y install apache2-2.4.25-3+deb9u9"
	#cmd="apt-cache policy apache2"
	$cmd
	log_errors $? "Instalacion de Apache"
	
}
############# Instalacion de WAF para Apache ######################
# $1: Version													  #
###################################################################
install_apache_WAF(){
	echo "[`date +"%F %X"`] Instalando ModSecurity para Apache"
	cmd="apt-get -y install libapache2-mod-security2"
	$cmd
	log_errors $? "Configuracion de ModSecurity"
	
	systemctl restart apache2
	log_errors $? "Habilitando ModSecurity"
	
	if [ -f "/etc/modsecurity/modsecurity.conf-recommended" ]; then
			mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
		
	fi
	
	sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/modsecurity/modsecurity.conf
	sed -i "s/SecResponseBodyAccess On/SecResponseBodyAccess Off/" /etc/modsecurity/modsecurity.conf 
	cmd="a2enmod security2"
	$cmd
	log_command $? "Configurando ModSecurity"
	
	cmd="systemctl restart apache2"
	$cmd
	log_command $? "Configuracion de ModSecurity"

	sed -i "s/IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs\.load/#IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs\.load/" /etc/apache2/mods-enabled/security2.conf
	rm -rf /usr/share/modsecurity-crs
	git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs
	cp /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
	cp  /etc/apache2/mods-enabled/security2.conf /etc/apache2/mods-enabled/security2.conf.bak
	sed -i "s/IncludeOptional \/etc\/modsecurity\/\*\.conf/IncludeOptional \/etc\/modsecurity\/\*\.conf \n\tIncludeOptional \/usr\/share\/modsecurity-crs\/\*\.conf \n\tIncludeOptional \/usr\/share\/modsecurity-crs\/rules\/\*\.conf    /" /etc/apache2/mods-enabled/security2.conf

	cmd="systemctl restart apache2"
	$cmd
	log_command "$?" "Configuracion OWASP"
}

echo "==============================================="
echo "     Inicia la instalacion de $1 $2"
echo "==============================================="

apt-get update
apt-get upgrade
log_errors $? "Upgrade de paquetes"
apt -y install curl wget
log_errors $? "Instalacion de utilerias"
apt -y install lsb-release apt-transport-https ca-certificates
log_errors $? "Instalacion de extensiones"
#if [[ $1 == '' ]]; #Si es Debian 9
#then
#	wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
#	echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
#	apt update
#fi
#apt -y install php #php-mysql
if [[ $1 == 'Nginx' ]]; #n  de Nginx
then
	install_nginx $2

else
	install_apache $2
	#apt -y install apache2=$2 libapache2-mod-php
fi
chown -R www-data:www-data /var/www/html
#apt-get install  php7.4-intl php7.4-mysql php7.4-curl php7.4-gd php7.4-soap php7.4-xml php7.4-zip php7.4-readline php7.4-opcache php7.4-json php7.4-gd -y apt-get 

