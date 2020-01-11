!/bin/bash
#########################################
#Instalador de joomla para CentOS 6 y 7 #
#########################################


# Argumento 1: Nombre de la Base de Datos
# Argumento 2: Usuario de la Base de Datos
# Argumento 3: Servidor de la base de Datos (localhost, ip, etc.)
# Argumento 4: Ruta de instalacion de joomla
# Argumento 5: Version de Joomla
echo "==============================================="
echo "     Inicia la instalacion de $2 $3"
echo "==============================================="


composer require nesbot/carbon
composer global require joomlatools/console
#export PATH="$PATH:~/.composer/vendor/bin"
export PATH=$PATH:~/.config/composer/vendor/bin/
echo "Ingresa la base de datos"
read db
echo "Ingresa el usuario de esa base de datos"
read userDB
echo "Ingresa el password"
read passDB
joomla site:create --use-webroot-dir=$4 --mysql-login=$2:$passDB --mysql-database=$1 foobar
