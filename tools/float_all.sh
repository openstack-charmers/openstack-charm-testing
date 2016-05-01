#!/bin/bash
# Give all instances a floating IP address.

echo " + Floating all instances."

function get_ip_f() {
  # Get first unallocated floating IP
  local var=$(nova floating-ip-list | grep '\-  ' | awk '{ print $4 }' | head -n 1)
  echo $var
}

fips=$(nova floating-ip-list | grep '\-  ' | awk '{ print $2 }')
fip_count=$(echo $fips | wc -w)

instances=$(nova list | grep ACTIVE | grep -v '\,' | awk '{ print $2 }')
inst_count=$(echo $instances | wc -w)

if [[ -z "$instances" ]]; then
  echo " . It appears that no instances need a floating IP."
  exit 0
fi

# Create floating IPs if necessary.
if (( $fip_count >= $inst_count)); then
  echo " . Already enough floating IPs."
else
  fip_diff=$(( $inst_count - $fip_count ))
  echo " + Creating $fip_diff more floating IPs."
  for m in $(seq 1 $fip_diff); do
    nova floating-ip-create
  done
fi

# Allocate floating IPs to instances.
for i in $instances; do
  ip_f=$(get_ip_f)
  echo " + Associating floating IP $ip_f to instance $i."
  nova floating-ip-associate $i $ip_f
done
