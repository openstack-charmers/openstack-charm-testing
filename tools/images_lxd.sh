#!/bin/bash -e
# Download LXD images and add to glance

# Download images if not already present
mkdir -p ~/images
[ -f ~/images/trusty-server-cloudimg-amd64-root.tar.gz  ] || {
	wget -O ~/images/trusty-server-cloudimg-amd64-root.tar.gz http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-root.tar.gz
}

sudo images_lxd_convert.sh ~/images/trusty-server-cloudimg-amd64-root.tar.gz \
	~/images/trusty-server-cloudimg-amd64-lxd.tar.gz

# Upload glance images to overcloud
glance image-create --name="trusty-lxd-amd64" --is-public=true --progress \
	 --container-format=bare --disk-format=qcow2 <  ~/images/trusty-server-cloudimg-amd64-lxd.tar.gz

