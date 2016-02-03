#!/bin/bash
# Set n-g mtu; add sec groups for basic access

juju set neutron-gateway instance-mtu=1300
for port in 22 80 443 3128; do
	nova secgroup-add-rule default tcp $port $port 0.0.0.0/0
	nova secgroup-add-rule default tcp $port $port ::/0
done
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 ::/0
nova secgroup-add-rule default udp 53 53 0.0.0.0/0
nova secgroup-add-rule default udp 53 53 ::/0

