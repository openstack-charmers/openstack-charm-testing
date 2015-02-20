#!/bin/bash
# Set n-g mtu; add sec groups for basic access

juju set neutron-gateway instance-mtu=1300
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default udp 53 53 0.0.0.0/0
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
nova secgroup-add-rule default tcp 443 443 0.0.0.0/0
nova secgroup-add-rule default tcp 3128 3128 0.0.0.0/0

