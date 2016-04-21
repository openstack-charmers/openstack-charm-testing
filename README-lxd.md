OpenStack w/ LXD Hypervisor Scenario
=====================================
An OpenStack-on-OpenStack example exercise.


### Get o-c-t bundle and scripts
```
mkdir -p ~/tools
bzr branch lp:openstack-charm-testing ~/tools/openstack-charm-testing
cd ~/./tools/openstack-charm-testing
```

### Deploy
Bootstrap, then deploy Wily + Liberty.
```
juju-deployer -vdB -c bundles/lxd/next.yaml xenial-mitaka
```

### Configure 
Add images, add 2nd NIC to neutron-gateway instance, create images, tenant, tenant router, networks.
```
./configure lxd
```

### Source the deployed overcloud nova credentials
```
. ~/tools/openstack-charm-testing/novarc
```

### Inspect and confirm the deployed cloud

```
glance image-list
```

```
nova hypervisor-list
```

```
nova service-list
```

```
neutron net-list
```

### Shrink flavors
Not required, but useful when testing density.
```
./tools/flavor_shrink.sh
```

### Set quotas really high
Not required, but allows drastic resource overcommits.
```
./tools/quota_million.sh
```

### Set security groups + MTU
Very permissive secgroups for testing, and lower instance MTU due to nested tunnels in cloud-on-cloud scenarios.
```
./tools/sec_groups.sh
```

### Create 3 new Trusty and 3 new Xenial lxd instances
```
./tools/instance_launch.sh 3 trusty-lxd
./tools/instance_launch.sh 3 xenial-lxd
```

### Watch the instances go ACTIVE
```
watch nova list
```

### Assign floating IP addresses
```
./tools/float_all.sh 
```

### Confirm floating IPs
```
nova list
```

### Confirm SSH access & connectivity to new instances
```
ssh -i ~/testkey.pem ubuntu@n.n.n.n "uname -a"
```
