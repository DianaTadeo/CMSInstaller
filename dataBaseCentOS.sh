if [ $1 == 0 ];
then
	yum -y install postgresql-server postgresql-contrib
	postgresql-setup initdb
	systemctl start postgresql
	systemctl status postgresql
	systemctl enable postgresql
	read -p "Ingresa el nombre de la base de datos: " baseName
	su postgres -c "psql -c 'CREATE DATABASE $baseName;'"
        read -p "Ingresa el nombre de usuario administraddor de la base de datos: " userName
        read  -sp "Ingresa el password para ese usuario: " userPass
        su -c "psql -c \"CREATE USER $userName WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE $baseName TO $userName;'"
    
else
	yum -y install mariadb-server
	systemctl start mariadb
	systemctl status mariadb
	systemctl enable mariadb
	mysql_secure_installation
	read -p "Ingresa el nombre de la base de datos: " baseName
        read -p "In gresa el nombre de usuario administrador de la base de datos: " userName
        read -sp "Ingresa el password para ese usuario: " userPass
	read -p "Ingresa el password de root en MySQL: " rootPass
	mysql -u root --password=$rootPass -e "CREATE USER '$userName' IDENTIFIED BY '$userPass';"
        mysql -u root --password=$rootPass -e "GRANT ALL PRIVILEGES ON *.* TO $userName;"
        mysql -u $userName --password=$userPass -e "CREATE DATABASE $baseName;"
        mysql -u root --password=$rootPass -e "FLUSH PRIVILEGES;"
fi
