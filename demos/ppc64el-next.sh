#!/bin/bash -e
#
# Ubuntu OpenStack Validation Example:  ppc64el
# ============================================================================
#
# Requires at least 3 ppc64el nodes already commissioned and ready in MAAS.
#
# The ppc64el machines should be set to HWE-W kernel in the MAAS UI.
#
# Ceph is excluded as three additional ppc64el machines would be necessary.
#
# For deployment outside the Canonical OpenStack Engineering lab,
#   adjust IP settings in "~/tools/openstack-charm-testing/profiles/configure-ppc64el"
#   to fit the network environment.
#
# Necessary preparation for this script:
#   mkdir -vp ~/tools
#   cd ~/tools
#   git clone https://github.com/openstack-charmers/openstack-charm-testing.git
#   bzr branch lp:ubuntu-openstack-ci
#   bzr branch lp:juju-wait
#   cd openstack-charm-testing
#
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
BUNDLE="$HOME/tools/openstack-charm-testing/bundles/ppc64/ppc64el-next.yaml"
EXPECTED_HYPERVISORS="2"

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

# Bootstrap on ppc64el
# Pin to a specific machine which has lower resources
juju switch maas-trusty
juju bootstrap --constraints "arch=ppc64el ${INJECT_TAGS},node-11c03686-9d7f-11e4-91da-d4bed9a84493"

# Deploy
juju-deployer -v -c $BUNDLE_TMP $TARGET

# Wait for deployment to settle
$JUJU_WAIT

# Configure neutron, add images, install CLI tools,
# add security groups, tune flavors and quotas
./configure ppc64el

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

# Delay for instances
sleep 120

# Optionally check cirros images (no SSH via key, un/pw only)
#   FYI, cirros default login:  cirros  cubswin:)
#   tools/instance_launch.sh 2 cirros-ppc64el

# Assign floating IP addresses to all instances
tools/float_all.sh

# Gather info about the cloud
f_query_and_save_cloud_diags_info

# Check ICMP ping and SSH port connect to all
#   instances in the deployed cloud
tools/instance_ssh_ping_all.sh

# Optionally confirm by manually SSH to each instance, ex:
#   ssh -i ~/testkey.pem <floating-ip>
