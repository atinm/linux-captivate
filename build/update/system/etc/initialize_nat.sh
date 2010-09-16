#!/system/bin/sh

echo "0" > /proc/sys/net/ipv4/ip_forward

bakdns1=`getprop net.pdp0.bakdns1`
bakdns2=`getprop net.pdp0.bakdns2`

echo "*****************"
echo "Previous dns 1 and 2"
echo $bakdns1
echo $bakdns1
echo "*****************"

# Delete Previous MobileAP NAT Setting
# Step 1 : Masquerading 
iptables -t nat -D POSTROUTING -o pdp0 -j MASQUERADE
iptables -t nat -D POSTROUTING -j ACCEPT

# DNS Setting
iptables -t nat -D PREROUTING -i wl0.1 -p tcp  --dport 53 -j DNAT --to $bakdns1:53
iptables -t nat -D PREROUTING -i wl0.1 -p udp  --dport 53 -j DNAT --to $bakdns1:53
iptables -t nat -D PREROUTING -i wl0.1 -p tcp  --dport 53 -j DNAT --to $bakdns2:53
iptables -t nat -D PREROUTING -i wl0.1 -p udp  --dport 53 -j DNAT --to $bakdns2:53

exit 0
