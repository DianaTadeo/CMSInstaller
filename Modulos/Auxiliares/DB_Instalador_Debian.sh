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


LOG="`pwd`/../Log/Aux_Instalacion.log"

###################### Log de Errores ###########################
# $1: Salida de error											#
# $2: Mensaje de la instalacion									#
#################################################################
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : $2 : [ERROR]" >> $LOG
		exit_install
	else
		echo "[`date +"%F %X"`] : $2 : [OK]" 	>> $LOG
	fi
}

install_MySQL(){
	# $1=DBVersion; $2=DBExists; $3=DBName; $4=DBUser; $5=DBIP; $6=DBPort
	cmd="apt install mariadb-server -y"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	cmd="mysql_secure_installation"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	echo "Ingresa el password para ese usuario: "
	read -s userPass
	if [[ $2 == 'Yes']]; then
		mysql -h $5 -P $6 -u $4 --password=$userPass $3
		log_errors $? "Error al conectarse a la base de datos $3 en MySQL, servidor $5"
	else
		mysql -h $5 -P $6 -e "CREATE USER '$4' IDENTIFIED BY '$userPass';"
		log_errors $? "Error al crear al usuario $4 en MySQL, servidor $5"
		mysql -h $5 -P $6 -e "GRANT ALL PRIVILEGES ON *.* TO $4;"
		log_errors $? "Error al dar permisos al usuario $4 en MySQL, servidor $5"
		mysql -h $5 -P $6 -u $4 --password=$userPass -e "CREATE DATABASE $3;"
		log_errors $? "Error al crear la base de datos $3 en MySQL, servidor $5"
		mysql -h $5 -P $6 -e "FLUSH PRIVILEGES;"
		log_errors $? "Error en privilegios para el usuario $4 en MySQL, servidor $5"
}

install_PostregSQL(){
	# $1=DBVersion; $2=DBExists; $3=DBName; $4=DBUser; $5=DBIP; $6=DBPort
	cmd="apt-get install postgresql -y"
	$cmd
	log_errors $? "Instalacion de PostgreSQL: $cmd"
	if [[ $2 == 'Yes' ]]; then
		# solamente hace conexión a la BD existente
		su postgres -c "psql -h $5 -p $6 -d $3 -U $4"
		log_errors $? "Error al conectarse a la base de datos $3 en PostgreSQL, servidor $5"
	else
		su postgres -c "psql -h $5 -p $6 -c 'CREATE DATABASE $3;'"
		log_errors $? "Error al crear la base de datos $3 en PostgreSQL, servidor $5"
		echo "Ingresa el password para ese usuario: "
		read -s userPass
		su -c "psql -h $5 -p $6 -c \"CREATE USER $4 WITH PASSWORD '$userPass'\" " postgres
		log_errors $? "Error al crear al usuario $4 en PostgreSQL, servidor $5"
		su postgres -c "psql -h $5 -p $6 -c 'GRANT ALL PRIVILEGES ON DATABASE $3 TO $4;'"
		log_errors $? "Error en privilegios para el usuario $4 en PostgreSQL, servidor $5"
	fi
}

echo "==============================================="
echo "            Instalando $1"
echo "==============================================="

if [[ $1 == 'PostgreSQL' ]];
then
	install_PostregSQL $2 $3 $4 $5 $6 $7
else
	install_MySQL $2 $3 $4 $5 $6 $7
fi
echo "==============================================="
echo "      Se ha instalado correctamente"
echo "==============================================="
