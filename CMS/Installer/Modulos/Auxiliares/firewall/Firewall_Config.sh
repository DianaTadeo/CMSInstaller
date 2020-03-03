#!/bin/bash

## @file
## @author Rafael Alejandro Vallejo Fernandez
## @author Diana G. Tadeo Guillen
## @brief Generador de Firewall para CentOS 6, CentOS 7, Debian 9 y Debian 10
## @version 1.0
##
## Este archivo genera las reglas a traves de 'iptables' para permitir el funcionamiento del \
## servidor web y CMS

# Argumento 1: Sistema Operativo 'Debian 9', 'Debian 10', 'CentOS 6' o 'CentOS 7'
# Argumento 2: Puerto de Base de Datos
# Argumento 3: host de Base de Datos

LOG="`pwd`/Modulos/Log/Config_Server.log"

## @fn log_errors()
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

## @fn install_iptables_Centos()
## @param $1 Version de CentOS
## @brief Funcion que realiza la instalacion de iptables para CentOS
##
install_iptables_Centos(){
	if [[ $1 == 'CentOS 7' ]]; then
		cmd="systemctl stop firewalld"
		$cmd
		log_errors $? "Deshabilitando firewalld: $cmd"
		cmd="systemctl disable firewalld"
		$cmd
		log_errors $? "Deshabilitando firewalld: $cmd"
		cmd="systemctl mask --now firewalld"
		$cmd
		log_errors $? "Deshabilitando firewalld: $cmd"
		cmd="yum install -y iptables-services"
		$cmd
	else
		cmd="yum install -y iptables"
		$cmd
	fi

	log_errors $? "Instalando iptables: $cmd"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl start iptables" && $cmd && log_errors $? "Instalando iptables: $cmd"
	[[ $1 == 'CentOS 6' ]] && service iptables start

	#[[ $1 == 'CentOS 7' ]] && cmd="systemctl start iptables6"
	#[[ $1 == 'CentOS 6' ]] && cmd="service iptables6 start"
	#$cmd
	#log_errors $? "Instalando iptables: $cmd"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl enable iptables"
	[[ $1 == 'CentOS 6' ]] && cmd="chkconfig iptables on"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	#[[ $1 == 'CentOS 7' ]] && cmd="systemctl enable iptables6"
	#[[ $1 == 'CentOS 6' ]] && cmd="chkconfig iptables6 on"
	#$cmd
	#log_errors $? "Instalando iptables: $cmd"
	[[ $1 == 'CentOS 7' ]] && cmd="systemctl status iptables"
	[[ $1 == 'CentOS 6' ]] && cmd="service iptables status"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	#[[ $1 == 'CentOS 7' ]] && cmd="systemctl status iptables6"
	#[[ $1 == 'CentOS 6' ]] && cmd="service iptables6 status"
	#$cmd
	#log_errors $? "Instalando iptables: $cmd"
}

## @fn install_iptables_Debian()
## @brief Funcion que realiza la instalacion de iptables para Debian
##
install_iptables_Debian(){
	DEBIAN_FRONTEND=noninteractive apt \
	-o Dpkg::Options::=--force-confold \
	-o Dpkg::Options::=--force-confdef \
	-y install iptables iptables-persistent
	cmd="apt install -y iptables iptables-persistent"
	log_errors $? "Instalando iptables: $cmd"
}


## @fn rewrite()
## @brief Funcion que reemplaza los valores en el archivo iptables.v4 por los valores adecuados respecto a las instalaciones anteriores
## @param $1 Host donde se encuentra la base de datos
## @param $2 Puerto de la base de datos
##
rewrite(){
	IPTABLES_v4="./Modulos/Auxiliares/firewall/iptables.v4"
	SSH_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "ssh\|sshd" | cut -d":" -f2 | sort -n | uniq  | cut -d" " -f1)
	sed -i "s/SSHPORT/$SSH_PORT/g" $IPTABLES_v4
	if [[ $1 == 'localhost' ]];
	then
		sed -i "s/DBPORT/$2/g" $IPTABLES_v4
	else
		sed -i "s/-A INPUT -p tcp -m tcp --dport DBPORT -j ACCEPT/-A INPUT -p tcp -m tcp -s $1 --sport $2 -j ACCEPT/g" $IPTABLES_v4
		sed -i "s/-A OUTPUT -p tcp -m tcp --sport DBPORT -j ACCEPT/-A OUTPUT -p tcp -m tcp -d $1 --dport $2 -j ACCEPT/g" $IPTABLES_v4
	fi

	echo "# RED local " >>  $IPTABLES_v4
	ip route | cut -f1 -d' ' | grep "^[0-9]" | xargs printf "-A INPUT -s %s -p tcp -m tcp -j ACCEPT\n" >> $IPTABLES_v4
	ip route | cut -f1 -d' ' | grep "^[0-9]" | xargs printf "-A OUTPUT -d %s -p tcp -m tcp -j ACCEPT\n" >> $IPTABLES_v4

}



echo "==============================================="
echo "            Configurando Firewall"
echo "==============================================="


if [[ $1 == 'Debian 9' ]] || [[ $1 == 'Debian 10' ]]; then
	install_iptables_Debian
else
	install_iptables_Centos "$1"
fi
rewrite "$3" "$2"
[[ $1 == 'CentOS 6' ]] && sed -i "s/f2b-ssh/f2b-sshd/" ./Modulos/Auxiliares/firewall/iptables.v4
echo "COMMIT" >>  ./Modulos/Auxiliares/firewall/iptables.v4
echo "ATENCION: Se aplicaran las reglas de firewall por defecto. Revisar el archivo"
echo "          CMSInstaller/Modulos/Auxiliares/firewall/iptables.v4 si se desea"
echo "          asegurar de que las reglas sean correctas antes de aplicarse."
echo "-----------------------------Para proceder, presione [Enter]------------------"
read
iptables-restore < ./Modulos/Auxiliares/firewall/iptables.v4
