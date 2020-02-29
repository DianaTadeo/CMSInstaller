#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador y configurador de Apache o Nginx en CentOS 6 y CentOS 7
## @version 1.0
##
## Este archivo permite instalar y configurar, ya sea Apache, o Nginx con WAF embebido


#Argumento 1: Version de CentOS
#Argumento 2: Tipo de web server a instalar ['Nginx' o 'Apache']
#Argumento 3: Version del web server


LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"


## @fn log_errors()
## @param $1 Salida de error
## @param $2 Mensaje de error o acierto
##
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : [ERROR] : $2 " >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2 " 	>> $LOG
	fi
}


## @fn install_apache()
## @brief Instalador de apache para CentOS
##
install_apache(){
	cmd="yum -y install httpd"
	$cmd
	log_errors $? "Instalacion de Apache: $cmd"
	[[ $1 == 'CentOS 6' ]] && sed -i "/localhost/s/$/ $(hostname)/" /etc/hosts && cmd="service httpd start"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl start httpd.service"
	$cmd
	log_errors $? "Iniciando Apache: $cmd"
	[[ $1 == 'CentOS 6' ]] && cmd="chkconfig httpd on"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl enable httpd.service"
	$cmd
	log_errors $? "Habilitando Apache: $cmd"
}


## @fn install_nginx()
## @brief Instalador de Nginx para CentOS
## @param $1 version de CentOS
## @param $2 version de Nginx
##
install_nginx(){
	cmd="yum -y install nginx-$2*"
	$cmd
	log_errors $? "Instalacion de Nginx: $cmd"
	[[ $1 == 'CentOS 6' ]] && cmd="service nginx start"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl start nginx"
	$cmd
	log_errors $? "Iniciando Nginx: $cmd"

	[[ $1 == 'CentOS 6' ]] && cmd="chkconfig nginx on"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl enable nginx"
	$cmd
	log_errors $? "Habilitando Nginx: $cmd"
}

## @fn install_apache_WAF()
## @brief Instalador de WAF con ModSecurity para apache
## @param $1 Version de CentOS
##
install_apache_WAF(){
	if [[ $1 == 'CentOS 7' ]];
	then
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
		cmd="yum install -y mod_security mod_security_crs"
		$cmd
		log_errors $? "Instalando Mod Security en Apache: $cmd"
		MOD_SECURITY_FILE="/etc/httpd/conf.d/mod_security.conf"
	else
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
		yum install gcc make libxml2 libxml2-devel httpd-devel pcre-devel curl-devel -y
		wget https://www.modsecurity.org/tarball/2.9.3/modsecurity-2.9.3.tar.gz
		tar xzf modsecurity-2.9.3.tar.gz
		cd modsecurity-2.9.3
		./configure
		make install
		cp modsecurity.conf-recommended /etc/httpd/conf.d/modsecurity.conf
		cp unicode.mapping /etc/httpd/conf.d
		echo "LoadModule security2_module modules/mod_security2.so" >> /etc/httpd/conf/httpd.conf
		echo "LoadModule unique_id_module modules/mod_unique_id.so" >> /etc/httpd/conf/httpd.conf
		cd -
		log_errors $? "Instalando Mod Security en Apache"
		MOD_SECURITY_FILE="/etc/httpd/conf.d/modsecurity.conf"
	fi

	sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" $MOD_SECURITY_FILE
	sed -i "s/SecResponseBodyAccess On/SecResponseBodyAccess Off/" $MOD_SECURITY_FILE

	[[ $1 == 'CentOS 6' ]] && cmd="service httpd restart"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl restart httpd"
	$cmd
	log_errors $? "Instalando ModSecurity en Apache: $cmd"
	locate=`pwd`
	cd /etc/httpd
	cmd="git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git"
	$cmd
	log_errors $? "Instalando ModSecurity en Apache: $cmd"

	cd owasp-modsecurity-crs
		cp crs-setup.conf.example crs-setup.conf
		echo "Include /etc/httpd/owasp-modsecurity-crs/crs-setup.conf" >> /etc/httpd/conf/httpd.conf
		echo "Include /etc/httpd/owasp-modsecurity-crs/rules/*.conf" >> /etc/httpd/conf/httpd.conf

		[[ $1 == 'CentOS 6' ]] && cmd="service httpd restart"
		[[ $1 == 'CentOS 7' ]] && cmd="systemctl restart httpd"
		$cmd
	log_errors $? "Reinicio de Apache con ModSecurity en Apache: $cmd"
	cd $locate
}

## @fn install_nginx_WAF()
## @brief Instalador de WAF con ModSecurity para Nginx
##
install_nginx_WAF(){
	if [[ $1 == 'CentOS 7' ]];
	then
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm
	else
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	fi

		cmd="yum install -y mod_security mod_security_crs"
	$cmd
	log_errors $? "Instalando Mod Security en Apache: $cmd"

	#sed -i "s/locate \/ {/SecRuleEngine DetectionOnly/SecRuleEngine On/" /etc/httpd/conf.d/default.conf
	#cmd="service httpd restart"
	#$cmd
	#log_errors $? "Instalando ModSecurity en Apache: $cmd"
	#locate=`pwd`
	#cd /etc/httpd
	#cmd="git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git"
	#$cmd
	#log_errors $? "Instalando ModSecurity en Apache: $cmd"

	#cd owasp-modsecurity-crs
		#cp crs-setup.conf.example crs-setup.conf

		#echo "Include /etc/httpd/owasp-modsecurity-crs/crs-setup.conf" >> /etc/nginx/conf/modSecurity.conf
		#echo "Include /etc/httpd/owasp-modsecurity-crs/rules/*.conf" >> /etc/nginx/conf/modSecurity.conf
		#ModSecurityEnabled on;
		#ModSecurityConfig /usr/local/nginx/modsecurity.conf;

		#cmd="service httpd restart"
		#$cmd
	#log_errors $? "Reinicio de Apache con ModSecurity en Apache: $cmd"
	#cd $locate
}

## @fn install_nginx_WAF_etc()
## @brief Instalador de WAF con ModSecurity para Nginx
## @param $1 version de CentOS
## @param $2 version de Nginx
##
install_nginx_WAF_etc(){
	# $1=CENTOS_VERSION ; $2=NGINX_VERSION
	yum groupinstall -y "Development Tools"
	yum install -y git httpd httpd-devel pcre pcre-devel libxml2 libxml2-devel curl curl-devel openssl openssl-devel libxslt-devel gd-devel perl-ExtUtils-Embed gperftools-devel GeoIP-devel
	log_errors $? "Instalando dependencias para Nginx: yum install -y git httpd httpd-devel pcre pcre-devel libxml2 libxml2-devel curl curl-devel openssl openssl-devel libxslt-devel gd-devel perl-ExtUtils-Embed gperftools-devel GeoIP-devel"
	if [[ $1 == 'CentOS 7' ]]; then
		git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
		cd ModSecurity
		git submodule init
		git submodule update
		./build.sh
		./configure
	else
		wget https://www.modsecurity.org/tarball/2.9.1/modsecurity-2.9.1.tar.gz
		tar xzf modsecurity-2.9.1.tar.gz
		cd modsecurity-2.9.1
		./configure --enable-standalone-module
	fi
	make
	log_errors $? "Comienza instalación de WAF para Nginx"
	make install
	log_errors $? "Instalación de WAF para Nginx"
	wget http://nginx.org/download/nginx-$2.tar.gz
	tar zxvf nginx-$2.tar.gz
	git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
	cd nginx-$2

	if [[ $1 == 'CentOS 7' ]]; then
			MOD_ENABLE="modsecurity "
			MOD_CONFIG="modsecurity_rules_file"
		./configure --add-dynamic-module=../ModSecurity-nginx --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_geoip_module --with-http_realip_module --with-stream_ssl_preread_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-http_auth_request_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-google_perftools_module --with-debug --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic' --with-ld-opt='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E'
		log_errors $? "Se configura Nginx para utilizar ModSecurity-nginx"
		make modules
		cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules
		sed -i "1 i\load_module modules/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf
		log_errors $? "Se carga módulo 'ngx_http_modsecurity_module.so' en '/etc/nginx/nginx.conf'"

		mkdir /etc/nginx/modsec

		wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended

		mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
	else
		MOD_ENABLE="ModSecurityEnabled"
		MOD_CONFIG="ModSecurityConfig"
		./configure --add-module=../nginx/modsecurity/ --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-debug --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --with-ld-opt=' -Wl,-E'
		log_errors $? "Se configura Nginx para utilizar ModSecurity-nginx"
		make && make install
		mkdir /etc/nginx/modsec
		cp ../modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
	fi

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

	#mv /etc/nginx/rules/REQUEST-949-BLOCKING-EVALUATION.conf /etc/nginx/rules/REQUEST-949-BLOCKING-EVALUATION.conf.false_positive
	if [[ $1 == 'CentOS 7' ]]; then
		sed -i "/http {/a \\\t$MOD_ENABLE on;\n\t$MOD_CONFIG \/etc\/nginx\/modsec\/modsecurity.conf;\n" /etc/nginx/nginx.conf
	else
		sed -i "/http {/a \\\n\tserver {\n\t\tlocation \/ {\n\t\t\t$MOD_ENABLE on;\n\t\t\t$MOD_CONFIG \/etc\/nginx\/modsec\/modsecurity.conf;\n\t\t}\n\t}" /etc/nginx/nginx.conf
	fi
	log_errors $? "Configuracion OWASP: $MOD_ENABLE on;$MOD_CONFIG /etc/nginx/modsec/modsecurity.conf"
	sed -i "s/SecAuditLogType Serial/SecAuditLogType Concurrent/" /etc/nginx/modsec/modsecurity.conf
	sed -i "s#SecAuditLog /var/log/modsec_audit.log#SecAuditLog /var/log/nginx/modsec_audit.log#" /etc/nginx/modsec/modsecurity.conf

	[[ $1 == "CentOS 7" ]] &&	CMD="systemctl restart nginx"
	[[ $1 == "CentOS 6" ]] &&	CMD="service nginx restart"
	$CMD
	log_errors $? "Se reinicia nginx: $CMD"

}

echo "===============================================" | tee -a $LOG
echo "     Inicia la instalacion de $2 $3" | tee -a $LOG
echo "===============================================" | tee -a $LOG

yum update -y
yum upgrade -y

if [[ $(whereis git | cut -f2 -d':') ]]; then
		echo $(git version)
		[[ $1 == "CentOS 6" ]] && yum install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm -y && yum install git -y
else
	[[ $1 == "CentOS 6" ]] && yum install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm -y
	yum install git -y
fi
if [[ $2 == 'Nginx' ]]; then
	install_nginx "$1" "$3"
	install_nginx_WAF_etc "$1" "$3"
else
	install_apache "$1"
	install_apache_WAF "$1"
fi
echo "==============================================="
echo "	  $2 $3 Fue instalado correctamente"
echo "==============================================="
