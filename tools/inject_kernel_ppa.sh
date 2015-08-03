#!/bin/sh

p_ppa=$1
p_hwe=$2
if [ -z "$p_ppa" ]; then
  echo "Inject kernel via PPA"
  echo "Usage: $0 <public PPA> <hwe series>"
  echo "Ex:	$0 ppa:canonical-kernel-team/ppa"
  echo "	$0 ppa:canonical-kernel-team/ppa lts-vivid"
  exit 1
fi

juju run --all "
  # if not in a container inject kernel
  if ! cat /proc/1/cgroup | grep -q lxc; then
    sudo apt-add-repository $p_ppa -y
    sudo apt-get update -yq
    if [ -n "$p_hwe" ]; then
      sudo apt-get install -yq linux-generic-$p_hwe
    fi
    sudo apt-get dist-upgrade -yq
    sudo reboot
  fi
"
