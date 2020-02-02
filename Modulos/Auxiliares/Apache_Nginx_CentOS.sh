#!/bin/bash
#################################################
#Instalador de apache y Nginx para CentOS 6 y 7	#
#################################################


#Argumento 1: Version de CentOS
#Argumento 2: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 3: Version del web server


LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"

###################### Log de Errores ###########################
# $1: Salida de error											#
# $2: Mensaje de la instalacion									#
#################################################################
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : [ERROR] : $2 " >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2 " 	>> $LOG
	fi
}

install_apache(){
	cmd="yum -y install httpd"
	$cmd
	log_errors $? "Instalacion de Apache: $cmd"
	cmd="systemctl start httpd.service"
	$cmd
	log_errors $? "Iniciando Apache: $cmd"
	cdm="systemctl enable httpd.service"
	$cmd
	log_errors $? "Habilitando Apache: $cmd"
}

install_nginx(){
	cmd="yum -y install nginx"
	$cmd
	log_errors $? "Instalacion de Nginx: $cmd"
	cmd="systemctl start nginx"
	$cmd
	log_errors $? "Iniciando Nginx: $cmd"
	cdm="systemctl enable nginx"
	$cmd
	log_errors $? "Habilitando Nginx: $cmd"
}

install_apache_WAF(){
	if [[ $1 == 'CentOS 7' ]];
	then
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
	else
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	fi
	
	cmd="yum install -y mod_security mod_security_crs"
	$cmd
	log_errors $? "Instalando Mod Security en Apache: $cmd"
	
	sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/httpd/conf.d/mod_security.conf
	cmd="service httpd restart"
	$cmd
	log_errors $? "Instalando ModSecurity en Apache: $cmd"
	locate=`pwd`
	cd /etc/httpd
	cmd="git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git"
	$cmd
	log_errors $? "Instalando ModSecurity en Apache: $cmd"
	
	cd modsecurity-crs
    cp modsecurity_crs_10_setup.conf.example modsecurity_crs_10_config.conf
    echo Include modsecurity-crs/modsecurity_crs_10_config.conf >> /etc/httpd/conf/httpd.conf
    echo Include modsecurity-crs/base_rules/*.conf >> /etc/httpd/conf/httpd.conf
    
    cmd="service httpd restart"
    $cmd
	log_errors $? "Reinicio de Apache con ModSecurity en Apache: $cmd"
	cd $locate
}

install_nginx_WAF(){
	if [[ $1 == 'CentOS 7' ]];
	then
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
	else
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	fi
	
	cmd="yum install -y mod_security mod_security_crs"
	$cmd
	log_errors $? "Instalando ModSecurity en Nginx: $cmd"
	
	sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/nginx/conf.d/nginx.conf
	cmd="service httpd restart"
	$cmd
	log_errors $? "Instalando ModSecurity en Nginx: $cmd"
	locate=`pwd`
	cd /etc/nginx
	cmd="git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git"
	$cmd
	log_errors $? "Instalando ModSecurity en Nginx: $cmd"
	cd modsecurity-crs
    cp modsecurity_crs_10_setup.conf.example modsecurity_crs_10_config.conf
    echo Include modsecurity-crs/modsecurity_crs_10_config.conf >> /etc/nginx/conf/modSecurity.conf
    echo Include modsecurity-crs/base_rules/*.conf >> /etc/nginx/conf/modSecurity.conf
    ModSecurityEnabled on;
    ModSecurityConfig /usr/local/nginx/modsecurity.conf;
    
    cmd="service httpd restart"
    $cmd
	log_errors $? "Reinicio de Apache con ModSecurity en Apache: $cmd"
	cd $locate
}



echo "==============================================="
echo "     Inicia la instalacion de $2 $3"
echo "==============================================="
yum update
yum upgrade
#yum install epel-release yum-utils -y
#if [ $1 == 6 ];
#then
#	yum install centos-release-SCL
#	yum install php54 php54-php php54-php-gd php54-php-mbstring
#	yum install php54-php-mysqlnd3
#	mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php53.off
#else
#	yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
#	yum-config-manager --enable remi-php73	
#	yum  -y install php php-fpm php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd
#	systemctl start php-fpm
#	systemctl enable php-fpm
#fi 
if [[ $2 == 'Nginx' ]];
then
	install_nginx
	install_nginx_WAF $1
else
	install_apache
	install_apache_WAF $1

fi
echo "==============================================="
echo "	  $2 $3 Fue instalado correctamente"
echo "==============================================="
