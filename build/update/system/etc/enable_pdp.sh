#!/system/bin/sh

echo "1" > /proc/sys/net/ipv4/ip_forward

pdpdns1=`getprop net.pdp0.dns1`
pdpdns2=`getprop net.pdp0.dns2`

bakdns1=`getprop net.pdp0.bakdns1`
bakdns2=`getprop net.pdp0.bakdns2`

echo "*****************"
echo "pdp dns 1 and 2"
echo $pdpdns1
echo $pdpdns1
echo "============"
echo "Previous dns 1 and 2"
echo $bakdns1
echo $bakdns1
echo "*****************"

# Delete Previous MobileAP NAT Setting
# Step 1 : Masquerading 
iptables -t nat -D POSTROUTING -o pdp0 -j MASQUERADE
iptables -t nat -D POSTROUTING -j ACCEPT

iptables -t nat -D PREROUTING -i wl0.1 -p tcp  --dport 53 -j DNAT --to $bakdns1:53
iptables -t nat -D PREROUTING -i wl0.1 -p udp  --dport 53 -j DNAT --to $bakdns1:53
iptables -t nat -D PREROUTING -i wl0.1 -p tcp  --dport 53 -j DNAT --to $bakdns2:53
iptables -t nat -D PREROUTING -i wl0.1 -p udp  --dport 53 -j DNAT --to $bakdns2:53

# Enable MobileAP NAT 
iptables -t nat -A POSTROUTING -o pdp0 -j MASQUERADE
iptables -t nat -A POSTROUTING -j ACCEPT

iptables -t nat -A PREROUTING -i wl0.1 -p tcp  --dport 53 -j DNAT --to $pdpdns1:53
iptables -t nat -A PREROUTING -i wl0.1 -p udp  --dport 53 -j DNAT --to $pdpdns1:53
iptables -t nat -A PREROUTING -i wl0.1 -p tcp  --dport 53 -j DNAT --to $pdpdns2:53
iptables -t nat -A PREROUTING -i wl0.1 -p udp  --dport 53 -j DNAT --to $pdpdns2:53

setprop net.pdp0.bakdns1 $pdpdns1
setprop net.pdp0.bakdns2 $pdpdns2

echo "=========================================="
echo "          IPTABLES -t nat -L              "
iptables -t nat -L
echo "=========================================="

exit 0
