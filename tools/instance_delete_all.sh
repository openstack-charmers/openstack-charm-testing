#!/bin/bash -ex
if [[ -z "$WORKSPACE" ]]; then
  set +x
  echo -e "\n/!\ This script will delete all nova instances it can find, which is dangerous.  It is intended
    to be used from Jenkins test automation.  If you really wish to use it, set a WORKSPACE env var
    to allow it to run."
  exit 1
fi

for i in $(openstack server list | awk '/=/{ print $2 }');do openstack server delete $i --wait; done

