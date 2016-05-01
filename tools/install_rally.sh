#!/bin/bash
# Install and configure rally

#set -ex

if [ -z $1 ]; then
    image="cirros"
else
	image=$1
fi

source novarc admin admin
# Gather vars for tempest template
image_name=$(glance image-list | grep $image | awk '{ print $4 }')

# Git rally, place the rendered rally template
[ -d rally ] || git clone https://github.com/openstack/rally
[ -d rally_scenarios ] || mkdir -p rally_scenarios

# Install rally
rally/install_rally.sh -y -d ~/rally

# Insert the image to use
for i in templates/rally/*.yaml; do
	file=`echo $i | sed s:^templates/rally/::`
	sed -e s:__IMAGE__:$image_name:g $i > rally_scenarios/$file
done

# Installing rally database
source ~/rally/bin/activate
rally-manage db recreate

# Creating environment
rally deployment create --fromenv --name=existing


echo
echo "Finished installing rally"
echo
echo "To run a task run the following command (for example): "
echo "source ~/rally/bin/activate"
echo "rally task start rally_scenarios/boot.yaml"



