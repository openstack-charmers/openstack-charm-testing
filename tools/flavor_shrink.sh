#!/bin/bash
# Shrink flavors for density testing

echo " + Shrinking flavors."
nova flavor-delete m1.small
nova flavor-delete m1.medium
nova flavor-create --ephemeral 0 --is-public True m1.small 2 512 20 1
nova flavor-create --ephemeral 0 --is-public True m1.medium 3 1024 40 2
