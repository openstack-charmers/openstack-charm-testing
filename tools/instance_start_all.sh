#!/bin/bash
for i in $(openstack server list | awk '/=/{ print $2 }');do openstack server start $i; done
