#!/bin/bash
# Launch N quantity of XYZ instances
# Presumes glance images exist and have been imported using the
# accompanying configure script.

p_qty=$1
p_name=$2
if [ -z "$p_qty" ] || [ -z "$p_name" ]; then
  echo "Launches N quantity of XYZ instances."
  echo "Usage:  <this script> <qty of instances> <glance image name>"
  echo "   ex:  ./instance_launch.sh 2 precise"
  echo "   ex:  ./instance_launch.sh 10 cirros"
  echo "   ex:  ./instance_launch.sh 25 trusty"
  echo "   ex:  ./instance_launch.sh 10 vivid-ppc64el"
  echo "   Cirros will assume m1.cirros flavor."
  echo "   All others will use m1.small flabor."
  exit 1
fi

echo " + Keying nova and ~/testkey.pem..."
nova keypair-list | grep testkey &> /dev/null || { nova keypair-add testkey > ~/testkey.pem; chmod 600 ~/testkey.pem; }
nova keypair-list | grep testkey

echo " + Grabbing 'private' network ID..."
net_id=$(neutron net-list | awk '/private/ {print $2}')

echo " + Determining flavor to use..."
if [[ "${p_name}" == *cirros* ]]; then
  flavor="m1.cirros"
else
  flavor="m1.small"
fi

echo " + Nova booting ${p_qty} ${p_name} instances as flavor ${flavor}..."
for m in $(seq 1 $p_qty); do
  server_name="${p_name}$(date +'%H%M%S')"
  echo ${server_name} ${net_id}
  nova boot --image ${p_name} --flavor ${flavor} --key_name testkey --nic net-id=${net_id} $server_name
  sleep 60
done

echo " + Hint:  use ssh -i ~/testkey.pem ubuntu@<ip> to access new instances (may also need a floating IP)."
