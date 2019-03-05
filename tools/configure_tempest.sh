#!/bin/bash

SWIFT_IP="10.245.161.162"

ksv=$(source rcs/openrc)
echo "ksv is: ${ksv}"
if [[ $ksv == *"3"* ]] ; then
	template="tempest-v3.conf.template"
else
	template="tempest.conf.template"
fi

source rcs/openrc

image_id=$(openstack image list | awk '/cirros\s/ {print $2}')
image_alt_id=$(openstack image list | awk '/cirros2\s/ {print $2}')

access=$(openstack --os-username demo --os-password pass --os-tenant-name demo ec2 credentials create | grep access | awk '{ print $4 }')
secret=$(openstack ec2 credentials show $access | grep secret | awk '{ print $4 }')

# Gather vars for tempest template
ext_net=$(neutron net-list | grep ext_net | awk '{ print $2 }')
router=$(neutron --os-project-name admin router-list | grep provider-router | awk '{ print $2}')
keystone_unit=$(juju status keystone|grep -i workload -A1|tail -n1|awk '{print $1}'|tr -d '*')
dashboard_unit=$(juju status openstack-dashboard|grep -i workload -A1|tail -n1|awk '{print $1}'|tr -d '*')
ncc_unit=$(juju status nova-cloud-controller|grep -i workload -A1|tail -n1|awk '{print $1}'|tr -d '*')
keystone=$(juju run --unit ${keystone_unit} "unit-get private-address")
dashboard=$(juju run --unit ${dashboard_unit} "unit-get private-address")
ncc=$(juju run --unit ${ncc_unit} "unit-get private-address")
http=${OS_AUTH_PROTOCOL:-http}
admin_password=${OS_PASSWORD:-openstack}
default_domain_id=$(openstack domain list | awk '/default/ {print $2}')
CIDR_PRIV=$(openstack subnet show $(openstack network list -f value|awk /private/'{print $3}') -f shell -c cidr|awk -F\" '{print $2}')

if [ "$(juju status swift 2>&1|grep Nothing)"  ] ;
then
	enable_swift="false"
else
	enable_swift="true"
fi

if [ "$(juju status heat 2>&1|grep Nothing)" ] ;
then
	enable_heat="false"
else
	enable_heat="true"
fi

# Insert vars into tempest conf
sed -e "s/__IMAGE_ID__/$image_id/g" -e "s/__IMAGE_ALT_ID__/$image_alt_id/g" \
    -e "s/__DASHBOARD__/$dashboard/g" -e "s/__KEYSTONE__/$keystone/g" \
    -e "s/__EXT_NET__/$ext_net/g" -e "s/__PROTO__/$http/g" \
    -e "s/__SWIFT__/$SWIFT_IP/g" \
    -e "s/__NAMESERVER__/$NAMESERVER/g" \
    -e "s/__CIDR_PRIV__/${CIDR_PRIV////\\/}/g" \
    -e "s/__NCC__/$ncc/g" -e "s/__SECRET__/$secret/g" -e "s/__ACCESS__/$access/g" \
    -e "s/__DEFAULT_DOMAIN_ID__/$default_domain_id/g" \
    -e "s/__HEAT_ENABLED__/${enable_heat}/g" \
    -e "s/__SWIFT_ENABLED__/${enable_swift}/g" \
    -e "s/__ADMIN_PASSWORD__/${admin_password}/g" \
    templates/tempest/${template} > tempest.conf

cp tempest.conf tempest/etc
cp templates/tempest/accounts.yaml tempest/etc
