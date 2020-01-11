!/bin/bash
##################################################
#Instalador de apache y Nginx para Debian 9 y 10 #
##################################################


#Argumento 1: Version de Debian
#Argumento 2: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 3: Version del web server

echo "==============================================="
echo "     Inicia la instalacion de $2 $3"
echo "==============================================="

apt-get update
apt-get upgrade
apt-get -y install curl wget
apt -y install lsb-release apt-transport-https ca-certificates
#if [[ $1 == '' ]]; #Si es Debian 9
#then
#	wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
#	echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
#	apt update
#fi
#apt -y install php #php-mysql
if [[ $2 == 'Nginx' ]]; #n  de Nginx
then
	apt -y install nginx=$3
	apt -y install libtool autoconf build-essential libpcre3-dev zlib1g-dev libssl-dev libxml2-dev libgeoip-dev liblmdb-dev libyajl-dev libcurl4-openssl-dev libpcre++-dev pkgconf libxslt1-dev libgd-dev
	cd /opt
	git clone --depth 100 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
	cd ModSecurity
	git submodule init
	git submodule update
	sh build.sh
	./configure
	make
	make install

else
	apt -y install apache2=$3 libapache2-mod-php
fi
#apt-get install  php7.4-intl php7.4-mysql php7.4-curl php7.4-gd php7.4-soap php7.4-xml php7.4-zip php7.4-readline php7.4-opcache php7.4-json php7.4-gd -y apt-get 

