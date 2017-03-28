#!/bin/bash -ex
for i in $(openstack server list | awk '/SHUTOFF/{ print $2 }');do openstack server start $i; done
