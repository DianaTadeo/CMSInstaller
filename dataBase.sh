
#!/bin/bash -e
if [ $1 == 0 ];
then
	echo "++++ Instalando PostgreSQL ++++"
	#apt-get install postgresql -y
	read -p "Ingresa el nombre para la base de datos: " baseName
	#su postgresql -c "psql -c 'CREATE DATABASE $baseName;'"
	read -p "Ingresa el nombre de usuario administraddor de la base de datos: " userNom
	read  -sp 'Ingresa el password para ese usuario: ' userPass
	#su postgresql -c "psql -c 'CREATE USER $userName PASSWORD  $userPass;'"
	#su postgresql -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE $baseName TO b$userName;'"
else
	echo "++++ Instalando MySQL/MariaDB ++++"
	apt-get install mariadb-server
	mysql_secure_installation
