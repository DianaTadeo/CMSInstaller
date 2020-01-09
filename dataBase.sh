
#!/bin/bash -e
if [ $1 == 0 ];
then
	echo "++++ Instalando PostgreSQL ++++"
#	apt-get install postgresql -y
	read -p "Ingresa el nombre para la base de datos: " baseName
#	su postgres -c "psql -c 'CREATE DATABASE $baseName;'"
	read -p "Ingresa el nombre de usuario administraddor de la base de datos: " userName
	read  -sp "Ingresa el password para ese usuario: " userPass
	su -c "psql -c \"CREATE USER $userName WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE $baseName TO $userName;'"
else
	echo "++++ Instalando MySQL/MariaDB ++++"
	apt install mariadb-server -y
	echo "++++ Se ha instalado correctamente ++++"
	mysql_secure_installation
	read -p "Ingresa el nombre de la base de datos: " baseName
	read -p "In gresa el nombre de usuario administrador de la base de datos: " userName
	read -sp "Ingresa el password para ese usuario: " userPass
	mysql -e "CREATE USER '$userName' IDENTIFIED BY '$userPass';"
	mysql -e "GRANT ALL PRIVILEGES ON *.* TO $userName;"
	mysql -u $userName --password=$userPass -e "CREATE DATABASE $baseName;"
	mysql -e "FLUSH PRIVILEGES;"
fi
