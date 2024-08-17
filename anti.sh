# Anti ddos tcp, syn flood, only allow 80 443 22 and VN
# MENJMOI COPYRIGHT DO NOT REUP
# PLS WORK RIGHT !!!
#!/bin/bash
IP_LIST="vn.txt"
BLACKLIST="blacklist"
# Xóa tất cả các quy tắc hiện tại
iptables -F
iptables -X
# Đặt chính sách mặc định
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
# Tạo chain BLACKLIST để quản lý các IP bị chặn
iptables -N BLACKLIST
iptables -A BLACKLIST -m limit --limit 1/m --limit-burst 1 -j LOG --log-prefix "BLACKLISTED: "
iptables -A BLACKLIST -j DROP
# Chặn các gói tin không hợp lệ
iptables -A INPUT -m conntrack --ctstate INVALID -j BLACKLIST
# Cho phép localhost
iptables -A INPUT -i lo -j ACCEPT
# Cho phép các kết nối đã thiết lập hoặc liên quan
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Bảo vệ chống SYN Flood
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 2 -j ACCEPT
# Giới hạn kích thước gói tin (0 đến 100 byte) cho HTTP và HTTPS
iptables -A INPUT -p tcp --dport 80 -m length --length 0:100 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m length --length 0:100 -j ACCEPT
# Thêm quy tắc cho phép các dải IP từ vn.txt
while IFS= read -r ip_range
do
    echo "Adding rule for $ip_range"
    iptables -A INPUT -s $ip_range -p tcp -m multiport --dports 80,443 -j ACCEPT
done < "$IP_LIST"
# Chặn tất cả các kết nối không thuộc IP trong vn.txt (dạng blacklist)
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j BLACKLIST
# Kiểm tra và chặn các IP spam gửi yêu cầu quá 2 lần/s
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set --name blacklist --rsource
iptables -A INPUT -p tcp --dport 80 -m recent --update --seconds 1 --hitcount 3 --name blacklist --rsource -j BLACKLIST
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --set --name blacklist --rsource
iptables -A INPUT -p tcp --dport 443 -m recent --update --seconds 1 --hitcount 3 --name blacklist --rsource -j BLACKLIST
# Kiểm tra các kết nối không hợp lệ và block 1 phút nếu không hợp lệ
iptables -A INPUT -p tcp -m length --length 101: -j BLACKLIST
iptables -A INPUT -p tcp -m state --state NEW -m recent --set --name blacklist --rsource
iptables -A INPUT -m recent --update --seconds 60 --name blacklist --rsource -j DROP
echo "All rules applied. Blocking all other connections."
