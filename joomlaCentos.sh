#mkdir /var/www/html/joomla
#cd /var/www/html/joomla
#composer require nesbot/carbon
#composer global require joomlatools/console
#export PATH="$PATH:~/.composer/vendor/bin"
#export PATH=$PATH:~/.config/composer/vendor/bin/
echo "Ingresa la base de datos"
read db
echo "Ingresa el usuario de esa base de datos"
read userDB
echo "Ingresa el password"
read passDB
joomla site:create --use-webroot-dir=/var/www/html/joomla --mysql-login=$userDB:$passDB --mysql-database=$db foobar

