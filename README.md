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

# other

-- block censys:

iptables -A INPUT -s 162.142.125.0/24 -j DROP

iptables -A INPUT -s 167.94.138.0/24 -j DROP

iptables -A INPUT -s 167.94.145.0/24 -j DROP

iptables -A INPUT -s 167.94.146.0/24 -j DROP

iptables -A INPUT -s 167.248.133.0/24 -j DROP

iptables -A INPUT -s 199.45.154.0/24 -j DROP

iptables -A INPUT -s 199.45.155.0/24 -j DROP

iptables -A INPUT -s 206.168.34.0/24 -j DROP

iptables -A INPUT -s 2602:80d:1000:b0cc:e::/80 -j DROP

iptables -A INPUT -s 2620:96:e000:b0cc:e::/80 -j DROP

iptables -A INPUT -s 2602:80d:1003::/112 -j DROP

iptables -A INPUT -s 2602:80d:1004::/112 -j DROP

iptables -A INPUT -p tcp --dport 80 -m string --string "CensysInspect/1.1" --algo bm -j DROP

iptables -A INPUT -p tcp --dport 443 -m string --string "CensysInspect/1.1" --algo bm -j DROP

-- after then:

sudo apt-get install iptables-persistent

sudo netfilter-persistent save

