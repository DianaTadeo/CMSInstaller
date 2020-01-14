#!/bin/bash
##################################################
#Instalador de apache y Nginx para Debian 9 y 10 #
##################################################


#Argumento 1: Version de Debian
#Argumento 2: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 3: Version del web server

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
		cd /opt
		wget http://nginx.org/download/nginx-1.12.0.tar.gz
		tar -zxf nginx-$1.tar.gz
		cd nginx-$1
		cmd="apt-get install -y git zlibc zlib1g zlib1g-dev libgeoip-dev libgeoip1 git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev automake pkgconf"
		$cmd
		log_errors $? "Instalando dependencias para Nginx: $cmd"
		./configure --user=www-data --group=www-data --with-pcre-jit --with-debug --with-http_ssl_module --with-http_realip_module --add-module=/opt/ModSecurity-nginx
		make
		cmd="make install"
		$cmd
		log_errors $? "Compilando...: $cmd"
	#echo "deb http://nginx.org/packages/mainline/debian stretch nginx" >> /etc/apt/sources.list
	
	#wget http://nginx.org/keys/nginx_signing.key
	#apt-key add nginx_signing.key
	#apt update
	
	#echo "[`date +"%F %X"`] Instalando Nginx version $1"
	#cmd="apt -y install nginx=$1"
	#$cmd
	#log_errors $? "Instalacion de Nginx"
	
	#echo "[`date +"%F %X"`] Instalando dependencias de Nginx"
	#cmd="apt -y install libtool autoconf build-essential libpcre3-dev zlib1g-dev libssl-dev libxml2-dev libgeoip-dev liblmdb-dev libyajl-dev libcurl4-openssl-dev libpcre++-dev pkgconf libxslt1-dev libgd-dev"
	#$cmd
	#log_errors $? "Instalacion de dependencias de Naginx"
	#rm nginx_signing.key
}

#install_modsecurity_nginx(){
#	
#}


################## Instalacion de Apache ##########################
# $1: Version Debian
# $2: Version Apache													  #
###################################################################
install_apache(){
	#if [[ $1 == "Debian 9" ]]; then
	#echo "deb http://ssecurity.debian.org stretch/updates main \n deb http://security.debian.org buster/updates" >> /etc/apt/sources.list
	#else
	#echo "deb http://security.debian.org jessie/updates main \ndeb http://security.debian.org stretch/updates main" >> /etc/apt/sources.list
	#fi
	#wget http://nginx.org/keys/nginx_signing.key
	#apt-key add nginx_signing.key
	apt update
	
	echo "[`date +"%F %X"`] Instalando Apache version $1"
	cmd="apt -y install apache2"
	#cmd="apt-cache policy apache2"
	$cmd
	log_errors $? "Instalacion de Apache: $cmd"
	
}
############# Instalacion de WAF para Apache ######################
###################################################################
install_apache_WAF(){
	echo "[`date +"%F %X"`] Instalando ModSecurity para Apache"
	cmd="apt-get -y install libapache2-mod-security2"
	$cmd
	log_errors $? "Instalacion de ModSecurity: $cmd"
	
	systemctl restart apache2
	log_errors $? "Habilitando ModSecurity: $cmd"
	
	if [ -f "/etc/modsecurity/modsecurity.conf-recommended" ]; then
		mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
		
	fi
	
	sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/modsecurity/modsecurity.conf
	sed -i "s/SecResponseBodyAccess On/SecResponseBodyAccess Off/" /etc/modsecurity/modsecurity.conf 
	cmd="a2enmod security2"
	$cmd
	log_errors $? "Habilitando ModSecurity: $cmd"
	
	cmd="systemctl restart apache2"
	$cmd
	log_errors $? "Iniciando de ModSecurity: $cmd"

	sed -i "s/IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs\.load/#IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs\.load/" /etc/apache2/mods-enabled/security2.conf
	rm -rf /usr/share/modsecurity-crs
	git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs
	cp /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
	cp  /etc/apache2/mods-enabled/security2.conf /etc/apache2/mods-enabled/security2.conf.bak
	sed -i "s/IncludeOptional \/etc\/modsecurity\/\*\.conf/IncludeOptional \/etc\/modsecurity\/\*\.conf \n\tIncludeOptional \/usr\/share\/modsecurity-crs\/\*\.conf \n\tIncludeOptional \/usr\/share\/modsecurity-crs\/rules\/\*\.conf    /" /etc/apache2/mods-enabled/security2.conf

	cmd="systemctl restart apache2"
	$cmd
	log_errors "$?" "Configuracion OWASP: $cmd"
}
############# Instalacion de WAF para Nginx ######################
###################################################################
install_nginx_WAF(){
		cd /opt
		#Downloading ModSecurity
		git clone https://github.com/SpiderLabs/ModSecurity
		cd ModSecurity
		git checkout -b v3/master origin/v3/master
		#Compiling ModSecurity
		sh build.sh
		git submodule init
		git submodule update
		cmd="./configure"
		$cmd
		log_command $? "Instalando WAF para Nginx: $cmd"
		cmd="make"
		$cmd
		log_command $? "Instalando WAF para Nginx: $cmd"
		cmd="make install"
		$cmd
		log_command $? "Instalacion de WAF para Nginx: $cmd"

		#Modsecurity and nginx Connector
		cd /opt/
		git clone https://github.com/SpiderLabs/ModSecurity-nginx.git
		
		cp /opt/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
		ln -s /usr/local/nginx/sbin/nginx /bin/nginx
		mkdir /usr/local/nginx/conf/sites-available
		mkdir /usr/local/nginx/conf/sites-enabled
		mkdir /usr/local/nginx/conf/ssl 
		mkdir /etc/nginx
		ln -s /usr/local/nginx/conf/ssl /etc/nginx/ssl
		cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.bak
		sed -i "s/#user  nobody;/user www-data;/" /usr/local/nginx/conf/nginx.conf
		sed -ie '$s/}/include \/usr\/local\/nginx\/conf\/sites-enabled\/\*;\n}/' /usr/local/nginx/conf/nginx.conf
		wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
		chmod +x /etc/init.d/nginx
		cmd="update-rc.d nginx defaults"
		$cmd
		log_command $? "Configurando Nginx: $cmd"
		cmd="service nginx start"
		$cmd
		log_command $? "Conectanto Niginx con ModSecurity: $cmd"

		cd /opt/
		git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
		cd owasp-modsecurity-crs/

		cp -R rules/ /usr/local/nginx/conf/ 
		cp /opt/owasp-modsecurity-crs/crs-setup.conf.example /usr/local/nginx/conf/crs-setup.conf
		echo "#Load OWASP Config
	Include crs-setup.conf
	#Load all other Rules
	Include rules/*.conf
	#Disable rule by ID from error message
	#SecRuleRemoveById 920350" >> /usr/local/nginx/conf/modsecurity.conf

		sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /usr/local/nginx/conf/modsecurity.conf
		mv /usr/local/nginx/conf/rules/REQUEST-921-PROTOCOL-ATTACK.conf /usr/local/nginx/conf/rules/REQUEST-921-PROTOCOL-ATTACK.conf.example
		sed -i 's/#charset koi8-r;/#charset koi8-r;\n\tmodsecurity on;/' /usr/local/nginx/conf/nginx.conf
		sed -i '0,/location \/ {/s/location \/ {/location \/ {\n\tmodsecurity_rules_file \/usr\/local\/nginx\/conf\/modsecurity.conf;/' /usr/local/nginx/conf/nginx.conf

		cmd="service nginx reload"
		$cmd
		log_command $? "Configuracion de ModSecurity: $cmd"
}

echo "==============================================="
echo "     Inicia la instalacion de $2 $3"
echo "==============================================="

apt-get update
apt-get upgrade
log_errors $? "Upgrade de paquetes"
apt -y install curl wget
if [[ $1 == 'Debian 9' ]]; #Si es Debian 9
then
	wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
	echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
	apt update
fi
apt -y install php php-mysql
log_errors $? "Instalacion de utilerias"
apt -y install lsb-release apt-transport-https ca-certificates
log_errors $? "Instalacion de extensiones"


if [[ $2 == 'Nginx' ]]; 
then
	install_nginx $1 $3
	install_nginx_WAF
else
	install_apache $1 $3
	install_apache_WAF
fi
chown -R www-data:www-data /var/www/html
#apt-get install  php7.4-intl php7.4-mysql php7.4-curl php7.4-gd php7.4-soap php7.4-xml php7.4-zip php7.4-readline php7.4-opcache php7.4-json php7.4-gd -y apt-get 

