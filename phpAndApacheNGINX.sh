apt-get update
apt-get upgrade
apt-get -y install curl wget
apt -y install lsb-release apt-transport-https ca-certificates
if [ $1 == 9 ]; #Si es Debian 9
then
	wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
	echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
	apt update
fi
apt -y install php #php-mysql
if [[ $2 == 'n' ]]; #n  de Nginx
then
	apt -y install nginx
else
	apt -y install apache2 libapache2-mod-php
fi
#apt-get install  php7.4-intl php7.4-mysql php7.4-curl php7.4-gd php7.4-soap php7.4-xml php7.4-zip php7.4-readline php7.4-opcache php7.4-json php7.4-gd -y apt-get 

