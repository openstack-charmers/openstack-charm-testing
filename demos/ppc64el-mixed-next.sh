#!/bin/bash -e
#
# Mixed Architecture Ubuntu OpenStack Validation Example:  ppc64el + x86_64
# ============================================================================
#
# Requires at least 7 amd64 nodes and at least 3 ppc64el nodes already
#   commissioned and ready in MAAS.
#
# The ppc64el machines should be set to HWE-W kernel in the MAAS UI.
#
# Necessary preparation for this script:
#   mkdir -vp ~/tools
#   cd ~/tools
#   git clone https://github.com/openstack-charmers/openstack-charm-testing.git
#   bzr branch lp:ubuntu-openstack-ci
#   bzr branch lp:juju-wait
#   cd openstack-charm-testing
#
# For deployment outside the Canonical OpenStack Engineering lab,
#   adjust IP settings in "~/tools/openstack-charm-testing/profiles/configure-ppc64el"
#   to fit the network environment.
#
# NOTE:  This validation is blocked on:
#   Bug #1566994: nova-scheduler not honoring glance image architecture properties
#   https://launchpad.net/bugs/1566994
#
# NOTE:  This deployment does not place ceph on ppc64el machines because one of the
#   three machines in the test lab uses multipath and:
#   Bug #1567036: disk device naming is unpredictable on multipath systems
#   https://launchpad.net/bugs/1567036
# ============================================================================


function f_query_and_save_cloud_diags_info(){
  # Query and save diags info
  juju stat --format tabular &> jstat-tabular.txt
  juju stat --format yaml &> jstat-yaml.txt
  nova hypervisor-list &> nova-hypervisor-list.txt
  nova service-list &> nova-service-list.txt
  nova list &> nova-list.txt
  neutron net-list &> neutron-net-list.txt
  neutron agent-list &> neutron-agent-list.txt
  glance image-list &> glance-image-list.txt
  keystone endpoint-list &> keystone-endpoint-list.txt
  keystone service-list &> keystone-service-list.txt
}



# The bundle to deploy
BUNDLE="$HOME/tools/openstack-charm-testing/bundles/ppc64/ppc64el-mixed-next.yaml"
EXPECTED_HYPERVISORS="6"

# The combo to deploy (Liberty or later recommended)
TARGET="trusty-liberty"
#TARGET="trusty-mitaka-proposed"
#TARGET="xenial-mitaka-proposed"

# MAAS tags to inject into the bundle.  This is specific
# to the needs of the lab and may need to be adjusted.
INJECT_TAGS="tags=uosci"

# No changes necessary here if prep is done as above
OCT="$HOME/tools/openstack-charm-testing"
CONSTRAINER="$HOME/tools/ubuntu-openstack-ci/tools/bundle_constrainer.py"
BUNDLE_TMP="${BUNDLE}-tagged"
SUBORDS="ceilometer-agent,cinder-ceph,neutron-api,neutron-openvswitch,ntp"
JUJU_WAIT="$HOME/tools/juju-wait/juju-wait -vw"

# And Go!
cd $OCT

# Inject MAAS tags into bundle to limit machine selection
$CONSTRAINER -yd -i $BUNDLE -o $BUNDLE_TMP --constraints $INJECT_TAGS -e $SUBORDS

# Bootstrap on x86
juju switch maas-trusty
juju bootstrap --constraints "arch=amd64 ${INJECT_TAGS}"

# Deploy
juju-deployer -v -c $BUNDLE_TMP $TARGET

# Wait for deployment to settle
$JUJU_WAIT

# Configure neutron, add images, install CLI tools,
# add security groups, tune flavors and quotas
./configure ppc64el

# Also add amd64 images
tools/images_amd64.sh

# Source the OpenStack credentials
. $OCT/novarc

# Poke the cloud to check basic API functionality.
# Some tables may be empty.  Expect all to exit 0.
nova list
keystone token-get
neutron net-list
glance image-list

# Confirm hypervisor count and health state
hv_up_count="$(nova hypervisor-list | grep up | grep enabled | wc -l)"
if (( $hv_up_count != $EXPECTED_HYPERVISORS)); then
  echo " ! Expected ${EXPECTED_HYPERVISORS} healthy hypervisors, found ${hv_up_count}"
  f_query_and_save_cloud_diags_info
  exit 1
fi

# Launch instances (The ssh key will be saved to ~/testkey.pem)
tools/instance_launch.sh 2 trusty-ppc64el
tools/instance_launch.sh 2 xenial-ppc64el
tools/instance_launch.sh 2 trusty
tools/instance_launch.sh 2 xenial

# Optionally check cirros images (no SSH via key, un/pw only)
#   FYI, cirros default login:  cirros  cubswin:)
#   tools/instance_launch.sh 2 cirros-ppc64el
#   tools/instance_launch.sh 2 cirros

# Assign floating IP addresses to all instances
tools/float_all.sh

# Gather info about the cloud
f_query_and_save_cloud_diags_info

# Check ICMP ping and SSH port connect to all
#   instances in the deployed cloud
tools/instance_ssh_ping_all.sh

# Optionally confirm by manually SSH to each instance, ex:
#   ssh -i ~/testkey.pem <floating-ip>
