#!/bin/bash

echo " + Attempting to ping and check ssh socket for all ACTIVE instances (must have floating IPs)."

[[ -z "$1" ]] && count=2 || count="$1"

for i in $(nova list | grep ACTIVE | awk '{ print $13 }'); do
  echo ==== $i ====
  nc -w $count $i 22 && echo "OK: ssh socket check" || echo "FAIL: ssh"
  ping -c $count $i &> /dev/null && echo "OK: ping" || echo "FAIL: ping"
done
