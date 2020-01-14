
#!/bin/bash
#########################################################
# Instalador de manejador de base de datos PostgreSQL y #
# MySQL para Debian 9 y 10                              #
#########################################################

# Argumento 1: Tipo de manejador ['MySQL' o 'PostgreSQL']
# Argumento 2: Nombre que se le pondra a la Base de Datos
# Argumento 3: Usuario para la Base de Datos
# Argumento 4: Servidor de la Base de Datos (localhost, ip, etc.)

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
	cmd="apt install mariadb-server -y"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	cmd="mysql_secure_installation"
	$cmd
	log_errors $? "Instalacion de MySQL: $cmd"
	echo "Ingresa el password para ese usuario: "
	read -s userPass
	mysql -h $3 -e "CREATE USER '$2' IDENTIFIED BY '$userPass';"
	log_errors $? "Error al crear al usuario $2 en MySQL, servidor $3"
	mysql -h $3 -e "GRANT ALL PRIVILEGES ON *.* TO $3;"
	log_errors $? "Error al crear al usuario $2 en MySQL.], servidor $3"
	mysql -h $3 -u $2 --password=$userPass -e "CREATE DATABASE $1;"
	log_errors $? "Error al crear la base de datos $1 en MySQL, servidor $3"
	mysql -h $3 -e "FLUSH PRIVILEGES;"
	log_errors $? "Error en privilegios para el usuario $2 en MySQL, servidor $3"
}
install_PostregSQL(){
	apt-get install postgresql -y
	su postgres -c "psql -h $3 -c 'CREATE DATABASE $1;'"
	echo "Ingresa el password para ese usuario: " 
	read -s userPass
	su -c "psql -h $3 -c \"CREATE USER $2 WITH PASSWORD '$userPass'\" " postgres
	su postgres -c "psql -h $3 -c 'GRANT ALL PRIVILEGES ON DATABASE $1 TO $2;'"
}

echo "==============================================="
echo "            Instalando $1"
echo "==============================================="

if [[ $1 == 'PostgreSQL' ]];
then
	install_PostregSQL $2 $3 $4
else
	install_MySQL $2 $3 $4
fi
echo "==============================================="
echo "      Se ha instalado correctamente"
echo "==============================================="
