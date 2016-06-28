#!/bin/bash -eu 
services=(
    openstack-dashboard
    keystone
    glance
    nova-cloud-controller
    neutron-api
    cinder
    swift-proxy
    mysql
)

echo "== PERCONA =="
juju ssh mysql/0 "mysql -uroot -pubuntu -e \"show status like 'wsrep_cluster%';\""

echo "== CEPH =="
juju ssh ceph/0 sudo ceph -s

echo "== HACLUSTERS =="
echo "Checking ${services[@]}"
for service in ${services[@]}; do
  echo -e "\n== $service =="
  juju ssh $service/0 sudo crm status 2>/dev/null
done

