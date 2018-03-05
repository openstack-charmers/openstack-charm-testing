#!/bin/bash -ex
# Give all instances a floating IP address.
# Requires >= Newton openstack client

# Fix for bug: https://bugs.launchpad.net/python-openstackclient/+bug/1747721
# --sfeole 2.22.2018


echo " + Floating all instances."

function get_ip_f() {
  # Get first unallocated floating IP
  openstack floating ip list | awk '/None/ { print $4 }' | head -n 1
}

fip_count=$(openstack floating ip list | awk '/None/ { print $4 }' | wc -l)
instances=$(openstack server list | grep ACTIVE | grep -v '\,' | awk '{ print $2 }')
inst_count=$(echo $instances | wc -w)

if [[ -z "$instances" ]]; then
  set +x
  echo " . It appears that no instance needs a floating IP."
  exit 0
fi

# Create floating IPs if necessary.
if (( $fip_count >= $inst_count)); then
  echo " . Already enough floating IPs."
else
  fip_diff=$(( $inst_count - $fip_count ))
  echo " + Creating $fip_diff more floating IPs."
  for m in $(seq 1 $fip_diff); do
    openstack floating ip create ext_net
  done
fi

# Allocate floating IPs to instances.
for instance in $instances; do
  ip_f=$(get_ip_f)
  echo " + Associating floating IP $ip_f to instance $instance."
  tenant_ip=$(openstack server list | grep $instance | awk -F'private=' '{ print $2 }' | awk '{ print $1 }')
  tenant_ip_portid=$(openstack port list -c ID -c fixed_ips | grep $tenant_ip | awk '{ print $2 }')
  openstack floating ip set --port $tenant_ip_portid $ip_f
done
