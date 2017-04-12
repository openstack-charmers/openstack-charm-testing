#!/bin/bash -e

openstack flavor list

for i in $(openstack server list | grep = | awk '{ print $2 }'); do
  hv="$(openstack server show $i | grep flavor | awk '{ print $4 }'; )"
  echo "${i}    ${hv}"
done
