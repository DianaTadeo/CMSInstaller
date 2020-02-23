#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador y configurador de Apache o Nginx en Debian 9 y 10
## @version 1.0
##
## Este archivo permite instalar y configurar, ya sea Apache, o Nginx con WAF embebido


#Argumento 1: Version de Debian
#Argumento 2: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 3: Version del web server

LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"

## @fn log_errors()
## @param $1 Salida de error
## @param $2 Mensaje de error o acierto
##
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : [ERROR] : $2" >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2" 	>> $LOG
	fi
}

## @fn install_nginx()
## @brief Instalador de Nginx para Debian
## @param $1 version
##
install_nginx(){
		cd /opt
		wget http://nginx.org/download/nginx-1.12.0.tar.gz
		tar -zxf nginx-1.12.0.tar.gz
		cd nginx-1.12.0
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

## @fn install_nginx_apt()
## @brief Instalador de Nginx para Debian
## @param $1 Version de Debian
## @param $1 Version de Nginx
##
install_nginx_apt(){
	# $1=DEBIAN_VERSION; $2=WEBSERVER_VERSION
	apt install curl gnupg2 ca-certificates lsb-release -y

	if [[ $1 == "Debian 10" ]]; then
		echo "deb http://nginx.org/packages/debian buster nginx" \
		| sudo tee /etc/apt/sources.list.d/nginx.list
		log_errors $? "Repostorio para instalar nginx: deb http://nginx.org/packages/debian buster nginx"
		curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
	else
		wget -q https://packages.sury.org/nginx/apt.gpg -O- | sudo apt-key add -
		echo "deb https://packages.sury.org/nginx/ stretch main" | sudo tee /etc/apt/sources.list.d/nginx.list
		log_errors $? "Repostorio para instalar nginx: deb https://packages.sury.org/nginx/ stretch main"
	fi
	apt update
	log_errors $? "Actualización de la lista de paquetes disponibles: apt update"
	apt install -y nginx=$2* nginx-extras
	log_errors $? "Instalación de nginx: apt install -y nginx=$2*"

}

## @fn install_apache()
## @brief Instalador de Apache para Debian
## @param $1 Version Debian
## @param $2 Version Apache
##
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

## @fn install_apache_WAF()
## @brief Instalador de WAF con ModSecurity para apache
##
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

## @fn install_nginx_WAF_etc()
## @brief Instalador de WAF con ModSecurity para Nginx
## @param $1 version de Debian
## @param $2 version de Nginx
##
install_nginx_WAF_etc(){
	# $1=DEBIAN_VERSION ; $2=NGINX_VERSION
	apt install -y git zlibc zlib1g zlib1g-dev libgeoip-dev libgeoip1 git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev automake pkgconf libxslt-dev libgd-dev
	log_errors $? "Instalando dependencias para Nginx: apt install -y git zlibc zlib1g zlib1g-dev libgeoip-dev libgeoip1 git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev automake pkgconf libxslt-dev libgd-dev"
	git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
	cd ModSecurity
	git submodule init
	git submodule update
	./build.sh
	./configure
	make
	log_errors $? "Comienza instalación de WAF para Nginx"
	make install
	log_errors $? "Instalación de WAF para Nginx"
	git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
	wget http://nginx.org/download/nginx-$2.tar.gz
	tar zxvf nginx-$2.tar.gz
	cd nginx-$2
	#./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
	./configure --add-dynamic-module=../ModSecurity-nginx --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-mail=dynamic --with-mail_ssl_module

	log_errors $? "Se configura Nginx para utilizar ModSecurity-nginx"
	make modules
	cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules
	sed -i "1 i\load_module modules/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf
	log_errors $? "Se carga módulo 'ngx_http_modsecurity_module.so' en '/etc/nginx/nginx.conf'"

	mkdir /etc/nginx/modsec

	wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended

	mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
	cp ../unicode.mapping /etc/nginx/modsec/

	git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
	cd owasp-modsecurity-crs/

	cp -R rules/ /etc/nginx/
	cp crs-setup.conf.example /etc/nginx/modsec/crs-setup.conf
	echo "#Load OWASP Config
Include crs-setup.conf
#Load all other Rules
Include /etc/nginx/rules/*.conf
#Disable rule by ID from error message
#SecRuleRemoveById 92035" >> /etc/nginx/modsec/modsecurity.conf

	sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf

	mv /etc/nginx/rules/REQUEST-921-PROTOCOL-ATTACK.conf /etc/nginx/rules/REQUEST-921-PROTOCOL-ATTACK.example

	sed -i '/http {/,/}/s/^\(}\)/\tserver { \n\t\tmodsecurity on;\n\t\tmodsecurity_rules_file \/etc\/nginx\/modsec\/modsecurity.conf;\n\t}\n\1/' /etc/nginx/nginx.conf
	log_errors $? "Configuracion OWASP: modsecurity on;modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf"
	systemctl restart nginx
	log_errors $? "Se reinicia nginx: systemctl restart nginx"

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

apt update
DEBIAN_FRONTEND=noninteractive apt \
-o Dpkg::Options::=--force-confold \
-o Dpkg::Options::=--force-confdef \
-y upgrade
log_errors $? "Upgrade de paquetes"

apt -y install lsb-release apt-transport-https ca-certificates
log_errors $? "Instalacion de extensiones"

if [ $(which git) ]; then
		echo $(git version)
else
		apt install git -y
fi

if [[ $2 == 'Nginx' ]];
then
	install_nginx_apt "$1" "$3"
	install_nginx_WAF_etc "$1" "$3"
else
	install_apache $1 $3
	install_apache_WAF
fi
chown -R www-data:www-data /var/www/html
