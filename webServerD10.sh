#!/bin/bash
#url_cms: ip/CMS.tar

utilerias(){
	apt install vim wget curl -y
}

if [ $(id -u) -ne 0 ]
	then
		echo "Ejecuta como usuario root"
		exit
fi

url_cms=$1

# se instalan utilerías adicionales
utilerias
# se instala apache y php para montar el sitio web
apt install apache2 php7.0 libapache2-mod-php -y
a2enmod php7.3
systemctl restart apache2.service

# se descarga el tar del sitio web y se in
cd /var/www/html/
wget $url_cms
tar -xzvf CMS.tar

# utilería para manipular JSON
apt install jq -y
