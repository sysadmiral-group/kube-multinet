# kube-multinet


- kube-mn-master0 - 10.128.0.5, 192.168.1.4, 10.44.1.4
- kube-mn-n0-0 - 192.168.1.5
- kube-mn-n1-0 - 10.44.1.5

https://cloud.google.com/vpc/docs/create-use-multiple-interfaces 



```
gcloud compute ssh kube-mn-master0
```
```
sudo ifconfig eth1 192.168.1.4 netmask 255.255.255.255 broadcast 192.168.1.4 mtu 1460
echo "1 rt1" | sudo tee -a /etc/iproute2/rt_tables
sudo ip route add 192.168.1.1 src 192.168.1.4 dev eth1 table rt1
sudo ip route add default via 192.168.1.1 dev eth1 table rt1
sudo ip rule add from 192.168.1.4/32 table rt1
sudo ip rule add to 192.168.1.4/32 table rt1
```

```
sudo ifconfig eth2 10.44.1.4 netmask 255.255.255.255 broadcast 10.44.1.4 mtu 1460
echo "2 rt2" | sudo tee -a /etc/iproute2/rt_tables
sudo ip route add 10.44.1.1 src 10.44.1.4 dev eth2 table rt2
sudo ip route add default via 10.44.1.1 dev eth2 table rt2
sudo ip rule add from 10.44.1.4/32 table rt2
sudo ip rule add to 10.44.1.4/32 table rt2
```