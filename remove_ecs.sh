#!/bin/bash

# Modify the values of the following parameters as per your environment.
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
sudo rm -rf /var/lib/ecs/*;
sudo rm -rf /etc/docker/certs.d/*;
sudo rm -rf ${docker_store};
sudo rm -rf ${local_store};
sudo rm -rf ${longhorn_store};
sudo systemctl stop iscsid;
sudo rm -rf /var/lib/iscsi;
sudo rm -rf /etc/cni;
sudo rm -f /run/longhorn-iscsi.lock;
sudo rm -rf /run/k3s;
sudo rm -rf /run/containerd;
sudo rm -rf /var/lib/docker;
sudo rm -rf /var/log/containers;
sudo rm -rf /var/log/pods;
sudo iptables -F;
sudo iptables -X;
sudo /usr/sbin/ifconfig docker0 down;
sudo /usr/sbin/ip link delete docker0;
sudo rm -rf /etc/sysconfig/iptables;
echo "Please reboot the node."
echo "After successful reboot, ensure the iptables list is empty prior to installing ECS."
