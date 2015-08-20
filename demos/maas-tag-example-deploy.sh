#!/bin/bash -e
#
# 11-Machine Bare Metal Example with MAAS Tagging & Service Placement
# ===================================================================
#   /!\ Not Reference Architecture: for Testing Only /!\
# lp:~1chb1n   irc:beisner   fn  #juju  or  #ubuntu-server
#
# See notes in bundle:  bundles/dev/11-default.yaml for scenario notes.


# Get pre-reqs, if not already installed
# ======================================
# sudo add-apt-repository ppa:juju/stable
# sudo apt-get update
# sudo apt-get install juju juju-deployer


# Prep dir & get testing bundles
# ==============================
# mkdir ~/tools
# cd ~/tools
# bzr branch lp:~1chb1n/openstack-charm-testing/metal-demo/ openstack-charm-testing
# cd ~/tools/openstack-charm-testing


# Bootstrap the juju environment in maas
# ======================================
time juju switch maas-trusty
time juju bootstrap --constraints "tags=gateway arch=amd64"
#  * At this point, 1 bare metal machine is allocated and deployed from
#    the maas cluster, and it was a machine tagged as 'gateway' to illustrate
#    that a specific piece of metal can be allocated for neutron-gateway,
#    as 2 NICs are required.  In this example, we co-locate neutron-gateway
#    on the bootstrap node (this may not always be possible in the future).


# Deploy juju-gui ahead of the other services for obervability
# ============================================================
juju deploy juju-gui --to lxc:0


# Deploy the stack
# ================
time juju-deployer -v -c bundles/dev/11-default.yaml -d trusty-kilo
#   * At this point, the stack is ready for use, but networking is not yet
#     configured, and there are not yet any images, users, tenants or sec groups.


# Wait for hooks and relations
# ============================
#   * Alternatively, watch juju debug-log for hooks and relations to settle.
sleep 120


# Configure the stack
# ===================
#   * Configures 2nd NIC on neutron-gateway unit, adds tenant, user, neutron router
#     neutron subnet, neutron network, and imports x86 glance images.
time ./configure dellstack
sleep 60


# Tune and check the stack
# ========================
#   * Sets quotas and overcommit levels very high, adds permissive security
#     groups, shrinks flavors to improve test density, launches a few instances,
#     gives them neutron floating IP addresses.
time ./tune-and-launch


# View the stack
# ==============
#   * Use juju status to learn the IP for the dashboard (horizon) and the juju guis.
time juju stat openstack-dashboard --format tabular
time juju stat juju-gui --format tabular
