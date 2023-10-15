#!/bin/bash
docker_store='/mnt/docker/*'
longhorn_store='/ecs/*'
local_store='/mnt/local-storage/*'

/opt/cloudera/parcels/ECS/docker/docker container stop registry
/opt/cloudera/parcels/ECS/docker/docker container rm -v registry
/opt/cloudera/parcels/ECS/docker/docker image rm registry:2
cd /opt/cloudera/parcels/ECS/bin;                                                                      
sudo ./rke2-killall.sh;
sudo ./rke2-uninstall.sh;
sudo rm -rf /var/lib/docker_server/*;
sudo rm -rf /var/lib/rancher/*;
sudo rm -rf /var/lib/kubelet/*;
sudo rm -rf /etc/docker/certs.d/*;
echo "Deleting docker, local and longhorn storage";
sudo rm -rf ${docker_store};
sudo rm -rf ${local_store};
sudo rm -rf ${longhorn_store};
sudo systemctl stop iscsid;
#sudo yum -y erase iscsi-initiator-utils;
sudo rm -rf /var/lib/iscsi;
sudo rm -rf /etc/cni;
sudo rm -f /run/longhorn-iscsi.lock;
sudo rm -rf /run/k3s;
sudo rm -rf /run/containerd;
sudo rm -rf /var/lib/docker;
sudo rm -rf /var/log/containers;
sudo rm -rf /var/log/pods;
echo "Reset iptables to ACCEPT all, then flush and delete all other chains";
declare -A chains=(
[filter]=INPUT:FORWARD:OUTPUT
[raw]=PREROUTING:OUTPUT
[mangle]=PREROUTING:INPUT:FORWARD:OUTPUT:POSTROUTING
[security]=INPUT:FORWARD:OUTPUT
[nat]=PREROUTING:INPUT:OUTPUT:POSTROUTING
)
for table in "${!chains[@]}"; do
echo "${chains[$table]}" | tr : $"\n" | while IFS= read -r; do
sudo iptables -t "$table" -P "$REPLY" ACCEPT
done
sudo iptables -t "$table" -F
sudo iptables -t "$table" -X
done
sudo /usr/sbin/ifconfig docker0 down;
sudo /usr/sbin/ip link delete docker0;
sudo rm -rf /etc/sysconfig/iptables;