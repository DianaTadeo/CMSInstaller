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
		echo "[`date +"%F %X"`] : [ERROR] : $2" >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2" 	>> $LOG
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
	cmd="systemctl start postgresql"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"
	cmd="systemctl enable postgresql"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"
	cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf-aux
	sed -i "s/ident/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/peer/trust/" /var/lib/pgsql/data/pg_hba.conf
	#sed -i "s/md5/trust/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/Environment=PGPORT=5432/Environment=PGPORT=$2/" /lib/systemd/system/postgresql.service
	[[ -f /usr/sbin/semanage ]] && /usr/sbin/semanage port -a -t postgresql_port_t -p tcp $2
	chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
	cmd="systemctl daemon-reload"
	$cmd
	log_errors $? "Configuracion de PostgreSQL: $cmd"
	cmd="systemctl restart postgresql"
	$cmd
	log_errors $? "Configuracion de PostgreSQL: $cmd"

	while true; do
					read -sp "Ingresa el password para el usuario '$3': " userPass; echo -e "\n"
					if [[ -n $userPass ]]; then
						read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
						[[ "$userPass" == "$userPass2" ]] && userPass2="" && break
						echo -e "No coinciden!\n"
					fi
	done
	su postgres -c "psql -h $4 -p $2 -c 'CREATE DATABASE $1;'"
	su postgres -c "psql -h $4 -p $2 -c 'ALTER DATABASE '$1' SET bytea_output = 'escape';'"
	su -c "psql -h $4 -p $2 -c \"CREATE USER $3 WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -h $4 -p $2 -c 'GRANT ALL PRIVILEGES ON DATABASE $1 TO $3;'"
	rm /var/lib/pgsql/data/pg_hba.conf
	mv /var/lib/pgsql/data/pg_hba.conf-aux /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/\(^host.*\)ident/\1md5/" /var/lib/pgsql/data/pg_hba.conf
	chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
				cmd="systemctl daemon-reload"
				$cmd
	log_errors $? "Configuracion de PostgreSQL: $cmd [Revise archivo pg_hba.conf]"
				cmd="systemctl restart postgresql"
				$cmd
}



## @fn install_MySQL()
## @brief Funcion que realiza la instalacion de MySQL y creacion de base de datos
## @param $1 Nombre de la base de datos que se desea crear
## @param $2 Puerto de la base de datos para conectarse
## @param $3 Nombre de usuario de la base de datos que se desea crear
## @param $4 Host de la base de datos que se desea crear
##
install_MySQL(){
	cmd="yum -y install mariadb-server"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	cmd="systemctl start mariadb"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	cmd="systemctl enable mariadb"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	if [[ $(cat /etc/my.cnf | grep port) ]];
	then
				 sed -i "s/.*port.*/port=$1/" /etc/my.cnf
							 sed -i "s/\[mysqld\]/\[mysqld\]\nport=$2/" /etc/my.cnf.d/server.cnf
	else
				 echo "[mysqld]\nport=$2" >> /etc/my.cnf
							 sed -i "s/\[mysqld\]/\[mysqld\]\nport=$2/" /etc/my.cnf.d/server.cnf
	fi
	[[ -f /usr/sbin/semanage ]] && /usr/sbin/semanage port -a -t mysqld_port_t -p tcp $2
				cmd="systemctl daemon-reload"
	$cmd
	log_errors $? "Configuracion de MySQL: $cmd"
	cmd="systemctl restart mariadb.service"
	$cmd
	log_errors $? "Configuracion de MySQL: $cmd [Revise archivos /etc/my.cnf y /etc/my.cnf.d/server.cnf]"
	mysql_secure_installation

	while true; do
					read -sp "Ingresa el password para el usuario '$3': " userPass; echo -e "\n"
					if [[ -n $userPass ]]; then
						read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
						[[ "$userPass" == "$userPass2" ]] && userPass2="" && break
						echo -e "No coinciden!\n"
					fi
	done

	while true; do
		read -sp "Ingresa el password para el usuario 'root' de MySQL: " rootPass; echo -e "\n"
		if [[ -n $rootPass ]]; then
			mysql -h $4 -P $2 -u root --password=$rootPass -e "\q"
			[[ $? == '0' ]] && break
		fi
	done

	mysql -h $4 -P $2 -u root --password=$rootPass -e "CREATE USER '$3' IDENTIFIED BY '$userPass';"
	mysql -h $4 -P $2 -u root --password=$rootPass -e "GRANT ALL PRIVILEGES ON *.* TO $3;"
	mysql -h $4 -P $2 -u $3 --password=$userPass -e "CREATE DATABASE $1;"
	mysql -h $4 -P $2 -u root --password=$rootPass -e "FLUSH PRIVILEGES;"
	# Para moodle
	mysql -h $4 -P $2 -u root --password=$rootPass -e "SET GLOBAL innodb_file_format=Barracuda;"
	mysql -h $4 -P $2 -u root --password=$rootPass -e "SET GLOBAL innodb_file_per_table=ON;"
	mysql -h $4 -P $2 -u root --password=$rootPass -e "SET GLOBAL innodb_large_prefix=ON;"
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
