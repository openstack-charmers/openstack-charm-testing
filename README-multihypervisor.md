Multi-Hypervisor Scenario (LXD + KVM)
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
juju-deployer -vdB -c bundles/multi-hypervisor/default.yaml xenial-mitaka
```

### Configure 
Add images, add 2nd NIC to neutron-gateway instance, create tenant, tenant router, networks.
```
./configure multihypervisor
```

### Source the deployed overcloud nova credentials
```
. ~/tools/openstack-charm-testing/novarc
```

### Inspect and confirm the deployed cloud

```
glance image-list
+--------------------------------------+--------------------+-------------+------------------+-----------+--------+
| ID                                   | Name               | Disk Format | Container Format | Size      | Status |
+--------------------------------------+--------------------+-------------+------------------+-----------+--------+
| 91169c9a-aa5f-4cd3-bd60-120c7fa3d5d6 | trusty-disk1.img   | qcow2       | bare             | 258540032 | active |
| 9ecade03-de12-42ad-9a0e-f7b12f73c8fb | trusty-root.tar.xz | root-tar    | bare             | 123953936 | active |
+--------------------------------------+--------------------+-------------+------------------+-----------+--------+
```

```
nova hypervisor-list
+----+--------------------------------------+
| ID | Hypervisor hostname                  |
+----+--------------------------------------+
| 1  | juju-beis1-machine-19                |
| 2  | juju-beis1-machine-18                |
| 3  | juju-beis1-machine-16.openstacklocal |
| 4  | juju-beis1-machine-15.openstacklocal |
| 5  | juju-beis1-machine-14.openstacklocal |
| 6  | juju-beis1-machine-17                |
+----+--------------------------------------+
```

```
nova service-list
+----------------+-----------------------+----------+---------+-------+----------------------------+-----------------+
| Binary         | Host                  | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+----------------+-----------------------+----------+---------+-------+----------------------------+-----------------+
| nova-cert      | juju-beis1-machine-13 | internal | enabled | up    | 2015-11-30T20:05:04.000000 | -               |
| nova-scheduler | juju-beis1-machine-13 | internal | enabled | up    | 2015-11-30T20:05:05.000000 | -               |
| nova-conductor | juju-beis1-machine-13 | internal | enabled | up    | 2015-11-30T20:05:06.000000 | -               |
| nova-compute   | juju-beis1-machine-19 | nova     | enabled | up    | 2015-11-30T20:05:07.000000 | -               |
| nova-compute   | juju-beis1-machine-18 | nova     | enabled | up    | 2015-11-30T20:05:08.000000 | -               |
| nova-compute   | juju-beis1-machine-16 | nova     | enabled | up    | 2015-11-30T20:05:03.000000 | -               |
| nova-compute   | juju-beis1-machine-15 | nova     | enabled | up    | 2015-11-30T20:05:05.000000 | -               |
| nova-compute   | juju-beis1-machine-14 | nova     | enabled | up    | 2015-11-30T20:05:03.000000 | -               |
| nova-compute   | juju-beis1-machine-17 | nova     | enabled | up    | 2015-11-30T20:05:06.000000 | -               |
+----------------+-----------------------+----------+---------+-------+----------------------------+-----------------+
```

```
neutron net-list
+--------------------------------------+---------+------------------------------------------------------+
| id                                   | name    | subnets                                              |
+--------------------------------------+---------+------------------------------------------------------+
| cdfadc0d-be81-4d62-8e1c-ede821e98cfa | ext_net | b4da69d0-19a3-4e29-abb4-dbb809f34097 10.5.0.0/16     |
| 66a4df1e-f0ad-48bf-b2f8-005c41caa42f | private | 0fbba4b3-5471-4cd7-a9f9-3b04feece594 192.168.21.0/24 |
+--------------------------------------+---------+------------------------------------------------------+
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

### Create 3 new trusty (kvm) instances
```
./tools/instance_launch.sh 3 trusty-disk1.img
```

### Create 3 new trusty (lxd) instances
```
./tools/instance_launch.sh 3 trusty-root.tar.xz
```

### Watch the instances go ACTIVE
```
watch nova list
+--------------------------------------+--------------------------+--------+------------+-------------+-----------------------+
| ID                                   | Name                     | Status | Task State | Power State | Networks              |
+--------------------------------------+--------------------------+--------+------------+-------------+-----------------------+
| 9e1cc2f1-082f-4bec-9cdb-b99f3b010aeb | trusty-disk1.img210034   | ACTIVE | -          | Running     | private=192.168.21.9  |
| 038f63b8-62c1-4504-8f22-73d577500b34 | trusty-disk1.img210057   | ACTIVE | -          | Running     | private=192.168.21.10 |
| 31767f21-4558-401e-93bb-1e1cd8b3fc8a | trusty-disk1.img210120   | ACTIVE | -          | Running     | private=192.168.21.11 |
| 85cec6b1-fb39-4e9c-bb08-4cea3381a24c | trusty-root.tar.xz210148 | ACTIVE | -          | Running     | private=192.168.21.12 |
| c947e805-91e5-4b9d-bc93-41ab5b73a4fa | trusty-root.tar.xz210211 | ACTIVE | -          | Running     | private=192.168.21.13 |
| 3c46e502-793e-44a0-a66f-de68e20e19f5 | trusty-root.tar.xz210234 | BUILD  | spawning   | NOSTATE     | private=192.168.21.14 |
+--------------------------------------+--------------------------+--------+------------+-------------+-----------------------+
```

### Assign floating IP addresses
```
./tools/float_all.sh 
```

### Confirm floating IPs
```
nova list
+--------------------------------------+--------------------------+--------+------------+-------------+-----------------------------------+
| ID                                   | Name                     | Status | Task State | Power State | Networks                          |
+--------------------------------------+--------------------------+--------+------------+-------------+-----------------------------------+
| 9e1cc2f1-082f-4bec-9cdb-b99f3b010aeb | trusty-disk1.img210034   | ACTIVE | -          | Running     | private=192.168.21.9, 10.5.150.6  |
| 038f63b8-62c1-4504-8f22-73d577500b34 | trusty-disk1.img210057   | ACTIVE | -          | Running     | private=192.168.21.10, 10.5.150.4 |
| 31767f21-4558-401e-93bb-1e1cd8b3fc8a | trusty-disk1.img210120   | ACTIVE | -          | Running     | private=192.168.21.11, 10.5.150.1 |
| 85cec6b1-fb39-4e9c-bb08-4cea3381a24c | trusty-root.tar.xz210148 | ACTIVE | -          | Running     | private=192.168.21.12, 10.5.150.3 |
| c947e805-91e5-4b9d-bc93-41ab5b73a4fa | trusty-root.tar.xz210211 | ACTIVE | -          | Running     | private=192.168.21.13, 10.5.150.2 |
| 3c46e502-793e-44a0-a66f-de68e20e19f5 | trusty-root.tar.xz210234 | ACTIVE | -          | Running     | private=192.168.21.14, 10.5.150.5 |
+--------------------------------------+--------------------------+--------+------------+-------------+-----------------------------------+
```

### Confirm SSH access & connectivity to new instances
```
ssh -i ~/testkey.pem ubuntu@10.5.150.1 "uname -a"
Warning: Permanently added '10.5.150.1' (ECDSA) to the list of known hosts.
Linux trusty-disk1 3.13.0-68-generic #111-Ubuntu SMP Fri Nov 6 18:17:06 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
```
```
ssh -i ~/testkey.pem ubuntu@10.5.150.2 "uname -a"
Warning: Permanently added '10.5.150.2' (ECDSA) to the list of known hosts.
Linux trusty-root 4.2.0-18-generic #22-Ubuntu SMP Fri Nov 6 18:25:50 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
```

