
////CentOS


sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld
sudo yum install iptables-services
sudo systemctl start iptables
sudo systemctl start iptables6
sudo systemctl enable iptables
sudo systemctl enable iptables6
sudo systemctl status iptables
sudo systemctl status iptables6



////Debian9/10

apt-get install -y iptables iptables-persistent

iptables-restore < rules.v4
