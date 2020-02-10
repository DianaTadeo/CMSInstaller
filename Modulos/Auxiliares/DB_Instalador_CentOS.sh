#!/bin/bash
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de manejador de base de datos MySQL y PostgreSQL
## @version 1.0
##
## Con instalacion de una base de datos en CentOS 6 y CentOS 7

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Nombre que se le pondra a la Base de Datos
# Argumento 3: Puerto de la Base de Datos
# Argumento 4: Usuario para la Base de Datos
# Argumento 5: Servidor de la Base de Datos (localhost, ip, etc.)


LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"

## @fn log_errors()
## @param $1 Salida de error
## @param $2 Mensaje de error o acierto
##
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : $2 : [ERROR]" >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : $2 : [OK]" 	>> $LOG
	fi
}

echo "==============================================="
echo "		  Instalando $1"
echo "==============================================="


## @fn install_PostgreSQL()
## @brief Funcion que realiza la instalacion de PostgreSQL y creacion de base de datos
## @param $1 Nombre de la base de datos que se desea crear
## @param $2 Puerto de la base de datos para conectarse
## @param $3 Nombre de usuario de la base de datos que se desea crear
## @param $4 Host de la base de datos que se desea crear
##
install_PostgreSQL(){
	yum -y install postgresql-server postgresql-contrib
	postgresql-setup initdb
	systemctl start postgresql
	systemctl enable postgresql
	cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf-aux
	sed -i "s/ident/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/peer/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/md5/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/Environment=PGPORT=5432/Environment=PGPORT=$2/" /lib/systemd/system/postgresql.service
	/usr/sbin/semanage port -a -t postgresql_port_t -p tcp $2
	chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
	systemctl daemon-reload
	systemctl restart postgresql
	su postgres -c "psql -h $4 -p $2 -c 'CREATE DATABASE $1;'"
	read  -sp "Ingresa el password para ese usuario: " userPass; echo -e "\n"
	su -c "psql -h $4 -p $2 -c \"CREATE USER $3 WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -h $4 -p $2 -c 'GRANT ALL PRIVILEGES ON DATABASE $1 TO $3;'"	
	rm /var/lib/pgsql/data/pg_hba.conf
	mv /var/lib/pgsql/data/pg_hba.conf-aux /var/lib/pgsql/data/pg_hba.conf
}



## @fn install_MySQL()
## @brief Funcion que realiza la instalacion de MySQL y creacion de base de datos
## @param $1 Nombre de la base de datos que se desea crear
## @param $2 Puerto de la base de datos para conectarse
## @param $3 Nombre de usuario de la base de datos que se desea crear
## @param $4 Host de la base de datos que se desea crear
##
install_MySQL(){
	yum -y install mariadb-server
	systemctl start mariadb
	systemctl enable mariadb
	if [[ $(cat /etc/my.cnf | grep port) ]];
	then
	       sed -i "s/.*port.*/port=$1/" /etc/my.cnf
               sed -i "s/\[mysqld\]/\[mysqld\]\nport=$2/" /etc/my.cnf.d/server.cnf
	else
	       echo "[mysqld]\nport=$2" >> /etc/my.cnf
               sed -i "s/\[mysqld\]/\[mysqld\]\nport=$2/" /etc/my.cnf.d/server.cnf
	fi
	/usr/sbin/semanage port -a -t mysqld_port_t -p tcp $2
        systemctl daemon-reload
	systemctl restart mariadb.service
	mysql_secure_installation
        read -sp "Ingresa el password para el usuario de la Base de Datos: " userPass; echo -e "\n"
	read -sp "Ingresa el password de root en MySQL: " rootPass; echo -e "\n"
	mysql -h $4 -P $2 -u root --password=$rootPass -e "CREATE USER '$3' IDENTIFIED BY '$userPass';"
        mysql -h $4 -P $2 -u $userName --password=$userPass -e "CREATE DATABASE $1;"
        mysql -h $4 -P $2 -u root --password=$rootPass -e "GRANT ALL PRIVILEGES ON *.* TO $3;"
        mysql -h $4 -P $2 -u root --password=$rootPass -e "FLUSH PRIVILEGES;"	
}


if [[ $1 == 'PostgreSQL' ]];
then
	
    install_PostgreSQL $2 $3 $4 $5 
else
    install_MySQL $2 $3 $4 $5 
fi
echo "==============================================="
echo "         Instalacion completada"
echo "==============================================="

