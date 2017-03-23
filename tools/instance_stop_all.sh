#!/bin/bash -ex
for i in $(openstack server list | awk '/ACTIVE/{ print $2 }');do openstack server stop $i; done

