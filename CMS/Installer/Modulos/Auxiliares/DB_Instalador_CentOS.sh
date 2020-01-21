#!/bin/bash
#########################################################
# Instalador de manejador de base de datos PostgreSQL y #
# MySQL para Centos 6 y 7                               #
#########################################################

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Nombre que se le pondra a la Base de Datos
# Argumento 3: Usuario para la Base de Datos
# Argumento 4: Servidor de la Base de Datos (localhost, ip, etc.)

echo "==============================================="
echo "		  Instalando $1"
echo "==============================================="
if [[ $1 == 'PostgreSQL' ]];
then
	yum -y install postgresql-server postgresql-contrib
	postgresql-setup initdb
	systemctl start postgresql
	systemctl status postgresql
	systemctl enable postgresql
	su postgres -c "psql -h $4 -c 'CREATE DATABASE $2;'"
        read  -sp "Ingresa el password para ese usuario: " userPass
        su -c "psql -h $4 -c \"CREATE USER $3 WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -h $4 -c 'GRANT ALL PRIVILEGES ON DATABASE $2 TO $3;'"
    
else
	yum -y install mariadb-server
	systemctl start mariadb
	systemctl status mariadb
	systemctl enable mariadb
	mysql_secure_installation
        read -sp "Ingresa el password para ese usuario: " userPass
	read -sp "Ingresa el password de root en MySQL: " rootPass
	mysql -h $4 -u root --password=$rootPass -e "CREATE USER '$3' IDENTIFIED BY '$userPass';"
        mysql -h $4 -u root --password=$rootPass -e "GRANT ALL PRIVILEGES ON *.* TO $3;"
        mysql -h $4 -u $userName --password=$userPass -e "CREATE DATABASE $2;"
        mysql -h $4 -u root --password=$rootPass -e "FLUSH PRIVILEGES;"
fi
echo "==============================================="
echo "         Instalacion completada"
echo "==============================================="

