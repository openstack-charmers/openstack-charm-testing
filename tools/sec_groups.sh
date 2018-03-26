#!/bin/bash -ex
# Add sec groups for basic access to all profiles
secgroup=${1:-`openstack security group list |grep default| awk '{print $2}'`}

for group in $secgroup; do

    for port in 22 53 80 443; do
        openstack security group rule create $group --proto tcp --src-ip 0.0.0.0/0 --dst-port $port ||:
    done

    openstack security group rule create $group --proto icmp --src-ip 0.0.0.0/0 ||:
done

