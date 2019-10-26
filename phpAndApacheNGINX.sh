function isinstalled() {
        if apt -q list installed $pack &>/dev/null; then
                true
        else
                false
        fi
}

#apt -y install lsb-release apt-transport-https ca-certificates wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
#echo "debhttps://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
#apt update
#apt -y install php7.4
#apt-get install  php7.4-intl php7.4-mysql php7.4-curl php7.4-gd php7.4-soap php7.4-xml php7.4-zip php7.4-readline php7.4-opcache php7.4-json php7.4-gd -y apt-get 
val = $(dpkg --get-selections | grep nginx | wc -l)

if [ $val -gt 0 ]; then
	echo "si"
else
	echo "no"
fi

