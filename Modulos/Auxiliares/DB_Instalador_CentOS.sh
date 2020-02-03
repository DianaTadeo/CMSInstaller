#!/bin/bash
#########################################################
# Instalador de manejador de base de datos PostgreSQL y #
# MySQL para Centos 6 y 7                               #
#########################################################

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Nombre que se le pondra a la Base de Datos
# Argumento 3: Usuario para la Base de Datos
# Argumento 4: Servidor de la Base de Datos (localhost, ip, etc.)
# Argumento 5: Puerto de la Base de Datos

echo "==============================================="
echo "		  Instalando $1"
echo "==============================================="

install_PostgreSQL(){
	yum -y install postgresql-server postgresql-contrib
	postgresql-setup initdb
	systemctl start postgresql
	systemctl enable postgresql
	cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf-aux
	sed -i "s/ident/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/peer/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/md5/trust/" /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql
	su postgres -c "psql -h $4 -p $5 -c 'CREATE DATABASE $2;'"
    read  -sp "Ingresa el password para ese usuario: " userPass; echo -e "\n"
    su -c "psql -h $4 -p $5 -c \"CREATE USER $3 WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -h $4 -p $5 -c 'GRANT ALL PRIVILEGES ON DATABASE $2 TO $3;'"	
	rm /var/lib/pgsql/data/pg_hba.conf
	mv /var/lib/pgsql/data/pg_hba.conf-aux /var/lib/pgsql/data/pg_hba.conf
}

install_MySQL(){
	yum -y install mariadb-server
	systemctl start mariadb
	systemctl enable mariadb
	if [[ $(cat /etc/my.cnf | grep port) ]];
	then
		sed -i "s/.*port.*/port=$5/" /etc/my.cnf
	else
		echo "port=$5" >> /etc/my.cnf
	fi
	systemctl restart mysql.service
	mysql_secure_installation
	
        read -sp "Ingresa el password para el usuario de la Base de Datos: " userPass; echo -e "\n"
	read -sp "Ingresa el password de root en MySQL: " rootPass; echo -e "\n"
	mysql -h $4 -p $5 -u root --password=$rootPass -e "CREATE USER '$3' IDENTIFIED BY '$userPass';"
        mysql -h $4 -p $5 -u root --password=$rootPass -e "GRANT ALL PRIVILEGES ON *.* TO $3;"
        mysql -h $4 -p $5 -u $userName --password=$userPass -e "CREATE DATABASE $2;"
        mysql -h $4 -p $5 -u root --password=$rootPass -e "FLUSH PRIVILEGES;"	
}


if [[ $1 == 'PostgreSQL' ]];
then
	
    install_postgresql $2 $3 
else
	install_MySQL 
fi
echo "==============================================="
echo "         Instalacion completada"
echo "==============================================="

