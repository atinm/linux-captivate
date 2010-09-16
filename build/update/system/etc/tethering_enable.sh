#!/system/bin/sh

echo "1" > /proc/sys/net/ipv4/ip_forward

iptables -t nat -A POSTROUTING -o pdp0 -j MASQUERADE
iptables -t nat -A POSTROUTING -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -j ACCEPT

exit 0
