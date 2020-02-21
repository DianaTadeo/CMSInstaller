#!/bin/bash -e
## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Instalador de manejador de base de datos MySQL y PostgreSQL
## @version 1.0
##
## Con instalacion de una base de datos en Debian 9 y Debian 10

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Versión del manejador
# Argumento 3: Existencia de BD ['Yes' o 'No']
# Argumento 4: Nombre que se le pondra a la Base de Datos
# Argumento 5: Usuario para la Base de Datos
# Argumento 6: Servidor de la Base de Datos (localhost, ip, etc.)
# Argumento 7: Puerto del servidor de la Base de Datos
# Argumento 8: Version de Debian

LOG="`pwd`/Modulos/Log/Aux_Instalacion.log"

## @fn log_errors()
## @param $1 Salida de error
## @param $2 Mensaje de error o acierto
##
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : [ERROR]: $2 " >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2 " 	>> $LOG
	fi
}

## @fn install_MySQL()
## @brief Funcion que realiza la instalacion de MySQL y creacion de base de datos
## @param $1 Version de manejador de base de datos a instalar
## @param $2 Pregunta si la base de datos ya existe
## @param $3 Nombre de la base de datos que se desea crear
## @param $4 Nombre de usuario de la base de datos que se desea crear
## @param $5 Host de la base de datos que se desea crear
## @param $6 Puerto al que se conecta el Manejador de la base de datos
##
install_MySQL(){
	# $1=DBVersion; $2=DBExists; $3=DBName; $4=DBUser; $5=DBHost; $6=DBPort
	cmd="apt install mariadb-server -y"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	sed -i "s/.*port.*/port = $6/" /etc/mysql/mariadb.conf.d/50-server.cnf
	systemctl restart mysql.service
	cmd="mysql_secure_installation"
	$cmd

	log_errors $? "Instalacion de MySQL: $cmd"

	if [[ $2 == 'Yes' ]]; then
		while true; do
			read -sp "Ingresa el password para el usuario '$4': " userPass; echo -e "\n"
			if [[ -n $userPass ]]; then
				mysql -h $5 -P $6 -u $4 --password=$userPass -e "\q"
				[[ $? == '0' ]] && break
			fi
		done
		log_errors $? "Conexión a la base de datos '$3' en MySQL, servidor $5"
	else
		while true; do
			read -sp "Ingresa el password para el usuario '$4': " userPass; echo -e "\n"
			if [[ -n $userPass ]]; then
				read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
				[[ "$userPass" == "$userPass2" ]] && userPass2="" && break
				echo -e "No coinciden!\n"
			fi
		done
		while true; do
			read -sp "Ingresa el password para el usuario 'root' de MySQL: " rootPass; echo -e "\n"
			if [[ -n $rootPass ]]; then
				mysql -h $5 -P $6 -u 'root' --password=$rootPass -e "\q"
				[[ $? == '0' ]] && break
			fi
		done
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

## @fn install_PostgreSQL()
## @brief Funcion que realiza la instalacion de PostgreSQL y creacion de base de datos
## @param $1 Version de manejador de base de datos a instalar
## @param $2 Pregunta si la base de datos ya existe
## @param $3 Nombre de la base de datos que se desea crear
## @param $4 Nombre de usuario de la base de datos que se desea crear
## @param $5 Host de la base de datos que se desea crear
## @param $6 Puerto al que se conecta el Manejador de la base de datos
## @param $7 Version de sistema operativo 'Debian 9' o 'Debian 10'
##
install_PostgreSQL(){
	# $1=DBVersion; $2=DBExists; $3=DBName; $4=DBUser; $5=DBHost; $6=DBPort $7=VerDebian
	#cmd="apt-get install postgresql-$1.* -y"
	cmd="apt-get install postgresql -y"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"
	if [[ $2 == 'Yes' ]]; then
		# solamente hace conexión a la BD existente
		while true; do
			read -sp "Ingresa el password para el usuario '$3': " userPass; echo -e "\n"
			if [[ -n $userPass ]]; then
				su postgres -c "PGPASSWORD="$userPass" psql -h $5 -p $6 -d $3 -U $4 -c '\q'"
				[[ $? == '0' ]] && break
			fi
		done
		log_errors $? "Conexión a la base de datos '$3' en PostgreSQL, servidor $5"
	else
		#Si es Debian 9
		echo $7
		if [[ $7 == 'Debian 9' ]]; then
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

		while true; do
			read -sp "Ingresa el password para el usuario '$4': " userPass; echo -e "\n"
			if [[ -n $userPass ]]; then
				read -sp "Ingresa nuevamente el password: " userPass2; echo -e "\n"
				[[ "$userPass" == "$userPass2" ]] && userPass2="" && break
				echo -e "No coinciden!\n"
			fi
		done

		echo "Inicia la creacion de la base de datos..."
		su postgres -c "psql -h $5 -p $6 -c 'CREATE DATABASE $3;'"
		log_errors $? "Creación de la base de datos $3 en PostgreSQL, servidor '$5'"
		su postgres -c "psql -h $5 -p $6 -c 'ALTER DATABASE '$3' SET bytea_output = 'escape';'"
		log_errors $? "Se configura bytea_output a 'escape' de la base de datos '$6'"
		su -c "psql -h $5 -p $6 -c \"CREATE USER $4 WITH PASSWORD '$userPass';\" " - postgres
		log_errors $? "Creación del usuario '$4' en PostgreSQL, servidor '$5'"
		su postgres -c "psql -h $5 -p $6 -c 'GRANT ALL PRIVILEGES ON DATABASE $3 TO $4;'"
		log_errors $? "Privilegios otorgador al usuario '$4' en PostgreSQL, servidor '$5"
		if [[ $7 == 'Debian 9' ]]; then
			rm /etc/postgresql/9.6/main/pg_hba.conf
			mv /etc/postgresql/9.6/main/pg_hba_estable.conf /etc/postgresql/9.6/main/pg_hba.conf
			chown postgres:postgres /etc/postgresql/9.6/main/pg_hba.conf
		else
			rm /etc/postgresql/11/main/pg_hba.conf
			mv /etc/postgresql/11/main/pg_hba_estable.conf /etc/postgresql/11/main/pg_hba.conf
			chown postgres:postgres /etc/postgresql/11/main/pg_hba.conf
		fi

		cmd="systemctl restart postgresql"
		$cmd
		log_errors $? "Reinicio de PostgreSQL: $cmd"
		echo "Instalacion completada exitosamente"
	fi
}

echo "===============================================" | tee -a $LOG
echo "		  					Instalando $1" | tee -a $LOG
echo "===============================================" | tee -a $LOG

if [[ $1 == 'PostgreSQL' ]];
then
	install_PostgreSQL "$2" "$3" "$4" "$5" "$6" "$7" "$8"
else
	install_MySQL "$2" "$3" "$4" "$5" "$6" "$7"
fi
echo "==============================================="
echo "      Se ha instalado correctamente"
echo "==============================================="
