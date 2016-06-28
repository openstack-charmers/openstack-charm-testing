#!/bin/bash -eu
cat <<- EOF | xargs -l juju ssh mysql/0 
set -x; dpkg -S percona-toolkit &>/dev/null && exit 0; \\
echo "Installing percona-toolkit"; \\
sudo apt-get update; \\
sudo apt-get install percona-toolkit --yes 2>/dev/null
EOF

services=( cinder neutron glance nova keystone )
if (($# > 0)); then services=( $1 ); fi

echo "Checking grants"
for db in ${services[@]}; do
    echo -e "\n== $db =="
    juju ssh mysql/0 pt-show-grants -uroot -pubuntu 2>/dev/null| grep $db
    ((${#services[@]} > 1)) && echo "" && read -p "Next? [ENTER] "
done
