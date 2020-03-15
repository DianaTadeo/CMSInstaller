#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Script que realiza la generaci[on de backup de la base de datos
## @version 1.0
##


## @fn log_errors()
## Funcion para creacion de bitacora de errores
## @param $1 Salida de error
## @param $2 Mensaje de error o acierto
##
log_errors(){
	if [ $1 -ne 0 ]; then
		echo "[`date +"%F %X"`] : [ERROR] : $2 " >> $LOG
		exit 1
	else
		echo "[`date +"%F %X"`] : [OK] : $2 " 	>> $LOG
	fi
}


#Argumento 1: Tipo Manejador 'MySQL' o 'PostgreSQL'
#Argumento 2: Base de Datos
#Argumento 3: Usuario
#Argumento 4: Password
#Argumento 5: Host
0 1 	* *  mysqldump -h $5 -u $3 -p $4 $2 > /mnt/backups/$dataBase`date +"%F %X"`.sql
mysqldump -u USER -p products > /mnt/backups/$dataBase`date +"%F %X"`.sql
