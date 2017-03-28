#!/bin/bash -ex
# Known good with client: openstack 3.7.0
for i in $(openstack server list | awk '/ACTIVE/{ print $9 }'); do
  nc -vzw 2 $i 22
  ping -c 2 $i
done
