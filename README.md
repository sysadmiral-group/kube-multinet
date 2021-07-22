# kube-multinet

## GCP Network
- kube-mn-master0 - 10.128.0.5, 192.168.1.3, 10.44.1.3 - centos8
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc fq_codel state UP group default qlen 1000
    link/ether 42:01:0a:80:00:06 brd ff:ff:ff:ff:ff:ff
    inet 10.128.0.6/32 scope global dynamic noprefixroute eth0
       valid_lft 2486sec preferred_lft 2486sec
    inet6 fe80::fb85:5d1a:d559:3120/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc fq_codel state UP group default qlen 1000
    link/ether 42:01:c0:a8:01:03 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.3/32 scope global dynamic noprefixroute eth1
       valid_lft 2486sec preferred_lft 2486sec
    inet6 fe80::9ac3:c4a7:cf55:9888/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc fq_codel state UP group default qlen 1000
    link/ether 42:01:0a:2c:01:03 brd ff:ff:ff:ff:ff:ff
    inet 10.44.1.3/32 scope global dynamic noprefixroute eth2
       valid_lft 2486sec preferred_lft 2486sec
    inet6 fe80::9418:2db1:2c7a:64f1/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
- kube-mn-n0-0 - 192.168.1.5 0 centos7
```
ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1460 qdisc mq state UP group default qlen 1000
    link/ether 42:01:c0:a8:01:05 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.5/32 brd 192.168.1.5 scope global noprefixroute dynamic eth0
       valid_lft 2848sec preferred_lft 2848sec
    inet6 fe80::3006:b59e:2aac:82b1/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
- kube-mn-n1-0 - 10.44.1.5 - ubuntu
```

```

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

## Container Runtime
https://kubernetes.io/docs/setup/production-environment/container-runtimes/

### Kernel and modprobe
```
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

### docker on centos
```
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-ce-cli containerd.io
systemctl start docker
```

### docker on ubuntu
```
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
rm -f /usr/share/keyrings/docker-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

```

### Setting SystemdCgroup 
[recommended by Kubernetes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers)

### for containerd 
add to `/etc/containerd/config.toml`
```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]

  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```
```
systemctl restart containerd
```

### for docker
```
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```
```
systemctl restart docker
```
## kubeadm

### Prerequisites
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin
- swap disabled

### install utilities
#### centos
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```
### ubuntu
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## init
- copy kubeadm-init.yaml to master + replace token
```
kubeadm init --conf kubeadm-init.yaml
```

```
mkdir .kube
cp /etc/kubernetes/admin.conf ~/.kube/config
```

```
kubectl get nodes -owide
NAME              STATUS     ROLES                  AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
kube-mn-master0   NotReady   control-plane,master   6m38s   v1.21.3   192.168.1.3   <none>        CentOS Linux 8   4.18.0-305.10.2.el8_4.x86_64   docker://20.10.7
```
```
kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-558bd4d5db-cfd56                  0/1     Pending   0          5m29s
kube-system   coredns-558bd4d5db-j9rfd                  0/1     Pending   0          5m29s
kube-system   etcd-kube-mn-master0                      1/1     Running   0          5m42s
kube-system   kube-apiserver-kube-mn-master0            1/1     Running   0          5m42s
kube-system   kube-controller-manager-kube-mn-master0   1/1     Running   0          5m42s
kube-system   kube-proxy-m9qwp                          1/1     Running   0          5m29s
kube-system   kube-scheduler-kube-mn-master0            1/1     Running   0          5m42s
```

## join
```
  kubeadm join kube-mn-master0:6443 --token ****** \
	--discovery-token-ca-cert-hash sha256:******
```

## troubleshooting
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/

## install flannel
```
kubectl apply -f kube/flannel/*yaml
```

## get nodes
```
kubectl get nodes -owide
NAME              STATUS   ROLES                  AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                 CONTAINER-RUNTIME
kube-mn-master0   Ready    control-plane,master   83m   v1.21.3   10.44.1.3     <none>        CentOS Linux 8          4.18.0-305.10.2.el8_4.x86_64   docker://20.10.7
kube-mn-n0-0      Ready    <none>                 46m   v1.21.3   192.168.1.5   <none>        CentOS Linux 7 (Core)   3.10.0-1160.31.1.el7.x86_64    docker://20.10.7
kube-mn-n1-0      Ready    <none>                 31m   v1.21.3   10.44.1.5     <none>        Ubuntu 20.04.2 LTS      5.8.0-1038-gcp                 docker://20.10.7
```