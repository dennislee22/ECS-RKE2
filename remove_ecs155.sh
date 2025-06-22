#!/bin/bash

docker_store='/mnt/docker'
longhorn_store='/ecs/longhorn'
local_store='/ecs/cdw'

/opt/cloudera/parcels/ECS/docker/docker container stop registry || true
/opt/cloudera/parcels/ECS/docker/docker container rm -v registry || true
/opt/cloudera/parcels/ECS/docker/docker image rm registry:2 || true

#cd /opt/cloudera/parcels/ECS/bin
#sudo ./rke2-uninstall.sh

sudo rm -rf \
    /var/lib/docker_server/* \
    /var/lib/rancher/* \
    /var/lib/kubelet/* \
    /var/lib/ecs/* \
    /etc/docker/certs.d/* \
    "${docker_store}" \
    "${local_store}" \
    "${longhorn_store}" \
    /var/lib/iscsi \
    /etc/cni \
    /run/longhorn-iscsi.lock \
    /run/k3s \
    /run/containerd \
    /var/lib/docker \
    /var/log/containers \
    /var/log/pods

sudo systemctl stop iscsid || true
sudo iptables -F
sudo iptables -X
sudo ip link delete docker0 || true
sudo rm -rf /etc/sysconfig/iptables
echo "Please reboot the node."
echo "After successful reboot, ensure the iptables list is empty prior to installing ECS."
