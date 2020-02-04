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
## @brief Funcion que realiza la instalacion de iptables para CentOS
##
install_iptables_Centos(){
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
	log_errors $? "Instalando iptables: $cmd"
	cmd="systemctl start iptables"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	cmd="systemctl start iptables6"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	cmd="systemctl enable iptables"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	cmd="systemctl enable iptables6"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	cmd="systemctl status iptables"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
	cmd="systemctl status iptables6"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
}

## @fn install_iptables_Debian()
## @brief Funcion que realiza la instalacion de iptables para Debian
##
install_iptables_Debian(){
	cmd="apt-get install -y iptables iptables-persistent"
	$cmd
	log_errors $? "Instalando iptables: $cmd"
}


## @fn rewrite()
## @brief Funcion que reemplaza los valores en el archivo iptables.v4 por los valores adecuados respecto a las instalaciones anteriores
## @param $1 Host donde se encuentra la base de datos
## @param $2 Puerto de la base de datos
##
rewrite(){
	SSH_PORT=$(lsof -nP -iTCP -sTCP:LISTEN | grep "ssh\|sshd" | cut -d":" -f2 | sort -n | uniq  | cut -d" " -f1)
	sed -i "/SSHPORT/$SSH_PORT/g" iptables.v4
	if [[ $1 == 'localhost' ]];
	then
		sed -i "/DBPORT/$2/g" iptables.v4
	else
		sed -i "/-A INPUT -i eth0 -p tcp -m tcp --dport DBPORT -m state --state ESTABLISHED -j ACCEPT/-A INPUT -i eth0 -p tcp -m tcp --sport $2 -m state --state ESTABLISHED -j ACCEPT/g" iptables.v4
		sed -i "/-A OUTPUT -o eth0 -p tcp -m tcp --sport DBPORT -m state --state NEW,ESTABLISHED -j ACCEPT/-A OUTPUT -o eth0 -p tcp -m tcp --dport $2 -m state --state NEW,ESTABLISHED -j ACCEPT/g" iptables.v4
	fi
	read -p "Ingresa el nombre de la interfaz de la red (eth0 default): " iface; echo -e "\n"
	if [[ $iface ]];
	then
		sed -i "/eth0/$iface/g" iptables.v4
	fi
}

echo "==============================================="
echo "            Configurando Firewall"
echo "==============================================="

if [[ $1 == 'Debian 9' ]] || [[ $1 == 'Debian 10' ]]; then
	install_iptables_Debian
else
	install_iptables_Centos
fi
rewrite $3 $2
iptables-restore < iptables.v4

