#!/system/bin/sh

echo "1" > /proc/sys/net/ipv4/ip_forward

iptables -F
iptables -F -t nat
iptables -A FORWARD -o wl0.1 -j ACCEPT
iptables -A FORWARD -o eth0 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -j ACCEPT

exit 0
