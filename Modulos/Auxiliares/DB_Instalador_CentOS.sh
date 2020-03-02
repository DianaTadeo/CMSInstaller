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
# Argumento 6: Existencia de BD ['Yes' o 'No']
# Argumento 7: Versión del manejador
# Argumento 8: Versión de CentOS [6 ó 7]

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

echo "===============================================" | tee -a $LOG
echo "		  Instalando $1" | tee -a $LOG
echo "===============================================" | tee -a $LOG


## @fn install_PostgreSQL()
## @brief Funcion que realiza la instalacion de PostgreSQL y creacion de base de datos
## @param $1 Nombre de la base de datos que se desea crear
## @param $2 Puerto de la base de datos para conectarse
## @param $3 Nombre de usuario de la base de datos que se desea crear
## @param $4 Host de la base de datos que se desea crear
## @param $5 Pregunta si la base de datos ya existe
## @param $6 Version de manejador de base de datos a instalar
## @param $7 Version de CentOS
##
install_PostgreSQL(){
	[[ "$7" == 'CentOS 6' ]] && VERSION="6"
	[[ "$7" == 'CentOS 7' ]] && VERSION="7"
	yum install "https://download.postgresql.org/pub/repos/yum/reporpms/EL-$VERSION-x86_64/pgdg-redhat-repo-latest.noarch.rpm" -y
	#yum -y install postgresql-server postgresql-contrib
	pgsqlVersion=$(echo $6 | cut -d"." -f1,2 | sed "s/\.//")
	yum -y install postgresql$pgsqlVersion-server
	#postgresql-setup initdb
	if [[ $7 == "CentOS 7" ]]; then
		[[ $pgsqlVersion =~ 1.* ]] && /usr/pgsql-$6/bin/postgresql-$pgsqlVersion-setup initdb
		[[ $pgsqlVersion =~ 9.* ]] && /usr/pgsql-$6/bin/postgresql$pgsqlVersion-setup initdb
	else
		service postgresql-$6 initdb
	fi
	[[ $7 == 'CentOS 6' ]] && cmd="service postgresql-$6 start"
	[[ $7 == 'CentOS 7' ]] && cmd="systemctl start postgresql-$6"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"

	[[ $7 == 'CentOS 6' ]] && cmd="chkconfig postgresql-$6 on"
	[[ $7 == 'CentOS 7' ]] && cmd="systemctl enable postgresql-$6"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"
	if [[ $5 == 'Yes' ]]; then
		# solamente hace conexión a la BD existente
		while true; do
			read -sp "Ingresa el password para el usuario '$3': " userPass; echo -e "\n"
			if [[ -n $userPass ]]; then
				su postgres -c "PGPASSWORD="$userPass" psql -h $4 -p $2 -d $1 -U $3 -c '\q'"
				[[ $? == '0' ]] && break
			fi
		done
		log_errors $? "Conexión a la base de datos '$3' en PostgreSQL, servidor $5"
	else
		cp /var/lib/pgsql/$6/data/pg_hba.conf /var/lib/pgsql/$6/data/pg_hba.conf-aux
		sed -i "s/ident/trust/" /var/lib/pgsql/$6/data/pg_hba.conf
		sed -i "s/peer/trust/" /var/lib/pgsql/$6/data/pg_hba.conf
		#sed -i "s/md5/trust/" /var/lib/pgsql/$6/data/pg_hba.conf
		#sed -i "s/Environment=PGPORT=5432/Environment=PGPORT=$2/" /lib/systemd/system/postgresql.service
		sed -i "s/^#port = 5432/port = $2/" /var/lib/pgsql/$6/data/postgresql.conf
		[[ -f /usr/sbin/semanage ]] && /usr/sbin/semanage port -a -t postgresql_port_t -p tcp $2
		chown postgres:postgres /var/lib/pgsql/$6/data/pg_hba.conf
		[[ $7 == 'CentOS 6' ]] && cmd=""
		[[ $7 == 'CentOS 7' ]] && cmd="systemctl daemon-reload"
		$cmd
		log_errors $? "Configuracion de PostgreSQL: $cmd"
		[[ $7 == 'CentOS 6' ]] && cmd="service postgresql-$6 restart"
		[[ $7 == 'CentOS 7' ]] && cmd="systemctl restart postgresql-$6"
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
		rm /var/lib/pgsql/$6/data/pg_hba.conf
		mv /var/lib/pgsql/$6/data/pg_hba.conf-aux /var/lib/pgsql/$6/data/pg_hba.conf
		sed -i "s/\(^host.*\)ident/\1md5/" /var/lib/pgsql/$6/data/pg_hba.conf
		chown postgres:postgres /var/lib/pgsql/$6/data/pg_hba.conf
					[[ $7 == 'CentOS 6' ]] && cmd=""
					[[ $7 == 'CentOS 7' ]] && cmd="systemctl daemon-reload"
					$cmd
		log_errors $? "Configuracion de PostgreSQL: $cmd [Revise archivo pg_hba.conf]"
					[[ $7 == 'CentOS 6' ]] && cmd="service postgresql-$6 start"
					[[ $7 == 'CentOS 7' ]] && cmd="systemctl start postgresql-$6"
					$cmd
	fi
}



## @fn install_MySQL()
## @brief Funcion que realiza la instalacion de MySQL y creacion de base de datos
## @param $1 Nombre de la base de datos que se desea crear
## @param $2 Puerto de la base de datos para conectarse
## @param $3 Nombre de usuario de la base de datos que se desea crear
## @param $4 Host de la base de datos que se desea crear
## @param $5 Pregunta si la base de datos ya existe
## @param $6 Version de manejador de base de datos a instalar
## @param $7 Version de CentOS
##
install_MySQL(){
	if [[ $7 == 'CentOS 6' ]]; then
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
		cmd="yum --enablerepo=remi,remi-test -y install mysql-server-$6*"
	else
		cmd="yum -y install mariadb-server-$6*"
	fi
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	[[ $7 == 'CentOS 6' ]] && cmd="service mysqld start"
	[[ $7 == 'CentOS 7' ]] && cmd="systemctl start mariadb"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	[[ $7 == 'CentOS 6' ]] && cmd="chkconfig mysqld on"
	[[ $7 == 'CentOS 7' ]] && cmd="systemctl enable mariadb"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	if [[ $5 == 'Yes' ]]; then
		while true; do
			read -sp "Ingresa el password para el usuario '$3': " userPass; echo -e "\n"
			if [[ -n $userPass ]]; then
				mysql -h $4 -P $2 -u $3 --password=$userPass -e $1 "\q"
				[[ $? == '0' ]] && break
			fi
		done
		log_errors $? "Conexión a la base de datos '$1' en MySQL, servidor $4"
	else
		if [[ $(cat /etc/my.cnf | grep port) ]];
		then
					 sed -i "s/.*port.*/port=$1/" /etc/my.cnf
								 sed -i "s/\[mysqld\]/\[mysqld\]\nport=$2/" /etc/my.cnf.d/server.cnf
		else
					 echo -e "[mysqld]\nport=$2" >> /etc/my.cnf
								 #sed -i "s/\[mysqld\]/\[mysqld\]\nport=$2/" /etc/my.cnf.d/server.cnf
		fi
		[[ -f /usr/sbin/semanage ]] && /usr/sbin/semanage port -a -t mysqld_port_t -p tcp $2
					[[ $7 == 'CentOS 6' ]] && cmd=""
					[[ $7 == 'CentOS 7' ]] && cmd="systemctl daemon-reload"
		$cmd
		log_errors $? "Configuracion de MySQL: $cmd"
		[[ $7 == 'CentOS 6' ]] && cmd="service mysqld restart"
		[[ $7 == 'CentOS 7' ]] && cmd="systemctl restart mariadb.service"
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
	fi
}

if [[ $1 == 'PostgreSQL' ]];
then
		install_PostgreSQL "$2" "$3" "$4" "$5" "$6" "$7" "$8"
else
		install_MySQL "$2" "$3" "$4" "$5" "$6" "$7" "$8"
fi
echo "==============================================="
echo "         Instalacion completada"
echo "==============================================="
