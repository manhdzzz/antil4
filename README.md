sudo apt-get update
sudo apt-get install iptables

rm anti.sh
wget https://raw.githubusercontent.com/manhdzzz/antil4/main/anti.sh
rm vn.txt
wget https://raw.githubusercontent.com/manhdzzz/antil4/main/vn.txt
chmod +x anti.sh
sudo ./anti.sh
sudo apt-get install iptables-persistent

sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6
sudo netfilter-persistent save
sudo iptables -L -v
