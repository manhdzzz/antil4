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

# Cho phép kết nối localhost
iptables -A INPUT -i lo -j ACCEPT

# Cho phép các kết nối đã được thiết lập hoặc liên quan
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Giới hạn kết nối mới
iptables -A INPUT -p tcp -m state --state NEW -m limit --limit 1/s --limit-burst 2 -j ACCEPT

# Giới hạn kích thước gói tin
iptables -A INPUT -p tcp --dport 80 -m length --length 0:100 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m length --length 0:100 -j ACCEPT

# Thêm quy tắc cho phép các dải IP từ tệp vn.txt
while IFS= read -r ip_range
do
    echo "Adding rule for $ip_range"
    iptables -A INPUT -s $ip_range -j ACCEPT
done < "$IP_LIST"

# Đánh dấu các kết nối không hợp lệ vào blacklist
iptables -N BLACKLIST
iptables -A BLACKLIST -m limit --limit 1/m --limit-burst 1 -j LOG --log-prefix "BLACKLISTED: " --log-level 4
iptables -A BLACKLIST -j DROP

# Quy tắc để xử lý các kết nối không hợp lệ
iptables -A INPUT -p tcp -m length --length 101: -j BLACKLIST
iptables -A INPUT -p tcp -m state --state NEW -m limit --limit 5/m --limit-burst 5 -j BLACKLIST

# Quy tắc để xử lý các kết nối không phải từ IP trong vn.txt
iptables -A INPUT -j BLACKLIST

# Chặn tất cả các kết nối không hợp lệ trong 1 phút
iptables -A INPUT -m recent --set --name blacklist --rsource
iptables -A INPUT -m recent --update --seconds 60 --name blacklist --rsource -j DROP

echo "All rules applied. Blocking all other connections."
