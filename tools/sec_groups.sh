#!/bin/bash -ex
# Add sec groups for basic access

for port in 22 53 80 443; do
    openstack security group rule create default --protocol tcp --remote-ip 0.0.0.0/0 --dst-port $port --project admin ||:
done

openstack security group rule create default --protocol icmp --remote-ip 0.0.0.0/0 --project admin ||:

openstack security group rule list | egrep '22:22'

