
#!/bin/bash
#########################################################
# Instalador de manejador de base de datos PostgreSQL y #
# MySQL para Debian 9 y 10                              #
#########################################################

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Nombre que se le pondra a la Base de Datos
# Argumento 3: Usuario para la Base de Datos
# Argumento 4: Servidor de la Base de Datos (localhost, ip, etc.)

echo "==============================================="
echo "            Instalando $1"
echo "==============================================="

if [[ $1 == 'PostgreSQL' ]];
then
	apt-get install postgresql -y
	su postgres -c "psql -h $4 -c 'CREATE DATABASE $2;'"
	echo "Ingresa el password para ese usuario: " 
	read -sP userPass
	su -c "psql -h $4 -c \"CREATE USER $3 WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -h $4 -c 'GRANT ALL PRIVILEGES ON DATABASE $2 TO $3;'"
else
	apt install mariadb-server -y
	mysql_secure_installation
	read -sp "Ingresa el password para ese usuario: " userPass
	mysql -h $4 -e "CREATE USER '$3' IDENTIFIED BY '$userPass';"
	mysql -h $4 -e "GRANT ALL PRIVILEGES ON *.* TO $4;"
	mysql -h $4 -u $3 --password=$userPass -e "CREATE DATABASE $2;"
	mysql -h $4 -e "FLUSH PRIVILEGES;"
fi
echo "==============================================="
echo "      Se ha instalado correctamente"
echo "==============================================="
