yum update
yum upgrade
yum install epel-release yum-utils
if [ $1 == 6 ];
then
	yum install centos-release-SCL
	yum install php54 php54-php php54-php-gd php54-php-mbstring
	yum install php54-php-mysqlnd
	mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php53.off
else
	yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	yum-config-manager --enable remi-php73	
	yum  -y install php php-fpm php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd
	systemctl start php-fpm
	systemctl enable php-fpm
fi 
if [[ $2 == 'n' ]];
then
	yum -y install nginx
	systemctl start nginx
	systemctl enable nginx
else
	yum -y install httpd
	systemctl start httpd.service
	systemctl enable httpd.service
fi
