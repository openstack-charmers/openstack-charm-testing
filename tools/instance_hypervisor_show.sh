#!/bin/bash

echo " + Attempting to show hypervisor for each instance (admin required)."

for i in $(nova list | grep = | awk '{ print $2 }'); do
  hv="$(nova show $i | grep hyper | awk '{ print $4 }'; )"
  echo "${i}    ${hv}"
done
