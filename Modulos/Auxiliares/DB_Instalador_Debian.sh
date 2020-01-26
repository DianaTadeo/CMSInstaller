#!/bin/bash
#########################################################
# Instalador de manejador de base de datos PostgreSQL y #
# MySQL para Debian 9 y 10                              #
#########################################################

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Versión del manejador
# Argumento 3: Existencia de BD ['Yes' o 'No']
# Argumento 4: Nombre que se le pondra a la Base de Datos
# Argumento 5: Usuario para la Base de Datos
# Argumento 6: Servidor de la Base de Datos (localhost, ip, etc.)
# Argumento 7: Puerto del servidor de la Base de Datos
# Argumento 8: Version de Debian

LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"

###################### Log de Errores ###########################
# $1: Salida de error											#
# $2: Mensaje de la instalacion									#
#################################################################
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : $2 : [ERROR]" >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : $2 : [OK]" 	>> $LOG
	fi
}

install_MySQL(){
	# $1=DBVersion; $2=DBExists; $3=DBName; $4=DBUser; $5=DBIP; $6=DBPort
	cmd="apt install mariadb-server -y"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	sed -i "s/.*port.*/port = $6/" /etc/mysql/mariadb.conf.d/50-server.cnf
	systemctl restart mysql.service
	cmd="mysql_secure_installation"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	read -sp "Ingresa el password para el usuario '$4': " userPass; echo -e "\n"
	if [[ $2 == 'Yes' ]]; then
		mysql -h $5 -P $6 -u $4 --password=$userPass -e "\q"
		log_errors $? "Conexión a la base de datos '$3' en MySQL, servidor $5"
	else
		read -sp "Ingresa el password para el usuario 'root' de MySQL: " rootPass; echo -e "\n"
		mysql -h $5 -P $6 -u 'root' --password=$rootPass -e "CREATE USER '$4' IDENTIFIED BY '$userPass';"
		log_errors $? "Creación del usuario '$4' en MySQL, servidor '$5'"
		mysql -h $5 -P $6 -u 'root' --password=$rootPass -e "GRANT ALL PRIVILEGES ON *.* TO '$4';"
		log_errors $? "Permisos otorgador al usuario '$4' en MySQL, servidor '$5'"
		mysql -h $5 -P $6 -u 'root' --password=$rootPass -e "CREATE DATABASE $3;"
		log_errors $? "Creación de la base de datos '$3' en MySQL, servidor '$5'"
		mysql -h $5 -P $6 -u 'root' --password=$rootPass -e "FLUSH PRIVILEGES;"
		log_errors $? "Privilegios otorgados al usuario '$4' en MySQL, servidor '$5'"
	fi
}

install_PostregSQL(){
	# $1=DBVersion; $2=DBExists; $3=DBName; $4=DBUser; $5=DBIP; $6=DBPort $7=VerDebian
	cmd="apt-get install postgresql -y"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"
	if [[ $2 == 'Yes' ]]; then
		# solamente hace conexión a la BD existente
		su postgres -c "psql -h $5 -p $6 -d $3 -U $4 -c '\q'"
		log_errors $? "Conexión a la base de datos '$3' en PostgreSQL, servidor $5"
	else
		#Si es Debian 9
		if [[ $7 == '9' ]]; then
			sed -i "s/.*port.*/port = $6/" /etc/postgresql/9.6/main/postgresql.conf
			cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba_estable.conf
			chown postgres:postgres /etc/postgresql/9.6/main/pg_hba.conf
		    sed -i "s/peer/trust/" /etc/postgresql/9.6/main/pg_hba.conf
		    sed -i "s/md5/trust/" /etc/postgresql/9.6/main/pg_hba.conf
		#Si es Debian 10
		else
			sed -i "s/.*port.*/port = $6/" /etc/postgresql/11/main/postgresql.conf
			cp /etc/postgresql/11/main/pg_hba.conf /etc/postgresql/11/main/pg_hba_estable.conf
			chown postgres:postgres /etc/postgresql/11/main/pg_hba.conf
		    sed -i "s/peer/trust/" /etc/postgresql/11/main/pg_hba.conf
		    sed -i "s/md5/trust/" /etc/postgresql/11/main/pg_hba.conf
		fi
		systemctl restart postgresql
		log_errors $? "Reinicio de PostgreSQL: $cmd"
		read -sp "Ingresa el password para el usuario '$4': " userPass; echo -e "\n"
		echo "Inicia la creacion de la base de datos..."
		su postgres -c "psql -h $5 -p $6 -c 'CREATE DATABASE $3;'"
		log_errors $? "Creación de la base de datos $3 en PostgreSQL, servidor '$5'"
		su -c "psql -h $5 -p $6 -c \"CREATE USER $4 WITH PASSWORD '$userPass';\" " - postgres
		log_errors $? "Creación del usuario '$4' en PostgreSQL, servidor '$5'"
		su postgres -c "psql -h $5 -p $6 -c 'GRANT ALL PRIVILEGES ON DATABASE $3 TO $4;'"
		log_errors $? "Privilegios otorgador al usuario '$4' en PostgreSQL, servidor '$5"
		if [ $7 == 9 ]; then
			rm /etc/postgresql/9.6/main/pg_hba.conf
			mv /etc/postgresql/9.6/main/pg_hba_estable.conf /etc/postgresql/9.6/main/pg_hba.conf
			chown postgres:postgres /etc/postgresql/9.6/main/pg_hba.conf
		else
			rm /etc/postgresql/11/main/pg_hba.conf
			mv /etc/postgresql/11/main/pg_hba_estable.conf /etc/postgresql/11/main/pg_hba.conf
			chown postgres:postgres /etc/postgresql/11/main/pg_hba.conf
		fi
		
		cmd = "systemctl restart postgresql"
		$cmd
		log_errors $? "Reinicio de PostgreSQL: $cmd"
		echo "Instalacion completada exitosamente"
	fi
}

echo "==============================================="
echo "            Instalando $1"
echo "==============================================="

if [[ $1 == 'PostgreSQL' ]];
then
	install_PostregSQL "$2" "$3" "$4" "$5" "$6" "$7" "$8"
else
	install_MySQL "$2" "$3" "$4" "$5" "$6" "$7"
fi
echo "==============================================="
echo "      Se ha instalado correctamente"
echo "==============================================="
