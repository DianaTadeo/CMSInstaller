#!/bin/bash
#################################################
#Instalador de apache y Nginx para CentOS 6 y 7	#
#################################################


#Argumento 1: Version de CentOS
#Argumento 2: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 3: Version del web server

echo "==============================================="
echo "     Inicia la instalacion de $2 $3"
echo "==============================================="
yum update
yum upgrade
#yum install epel-release yum-utils
#if [ $1 == 6 ];
#then
#	yum install centos-release-SCL
#	yum install php54 php54-php php54-php-gd php54-php-mbstring
#	yum install php54-php-mysqlnd3
	mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php53.off
#else
#	yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
#	yum-config-manager --enable remi-php73	
#	yum  -y install php php-fpm php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd
#	systemctl start php-fpm
#	systemctl enable php-fpm
#fi 
if [[ $2 == 'Nginx' ]];
then
	yum -y install nginx-$3
	systemctl start nginx
	systemctl enable nginx
else
	yum -y install httpd-$3
	systemctl start httpd.service
	systemctl enable httpd.service
fi
echo "==============================================="
echo "	  $2 $3 Fue instalado correctamente"
echo "==============================================="
