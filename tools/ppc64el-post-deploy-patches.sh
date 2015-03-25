#!/bin/bash -e
# NOTE(beisner): Contains workarounds for dealing with in-flight bugs
# related to libvirt and nova-compute on ppc64el.

echo " + Create patch and script files..."

# numa cell memory:
#   https://bugs.launchpad.net/ubuntu/+source/nova/+bug/1418187
#   https://review.openstack.org/#/c/160904/
#   https://github.com/openstack/nova/commit/291c1a1db1ab3ceccfac7a3c8312b6fdce3aaa84
patch_numa="$(mktemp)"
cat > "$patch_numa" << "--EOF1"
--- config.py.org   2015-03-25 15:07:17.087064000 +0000
+++ config.py   2015-03-25 15:07:22.963063966 +0000
@@ -152,7 +152,7 @@
                                                         **kwargs)

         self.id = None
-        self.memory = None
+        self.memory = 0
         self.mempages = []
         self.cpus = []
--EOF1

# nova-compute host pass-through No bug yet, need to resolve via the nova-compute charm
patch_passthrough="$(mktemp)"
cat > "$patch_passthrough" << "--EOF2"
--- /etc/nova/nova-compute.conf.dist    2015-02-06 14:03:04.274769382 +0000
+++ /etc/nova/nova-compute.conf 2015-02-06 14:03:05.938798786 +0000
@@ -2,3 +2,4 @@
 compute_driver=libvirt.LibvirtDriver
 [libvirt]
 virt_type=kvm
+cpu_mode=host-passthrough
--EOF2

# disable smt:  https://bugs.launchpad.net/cloud-archive/+bug/1419842
script_smt="$(mktemp)"
cat > "$script_smt" << "--EOF3"
#!/bin/sh
fail() { echo "FAIL:" "$@" 1>&2; exit 1; }

echo "smt:"
out=$(LANG=C ppc64_cpu --smt 2>&1)
if echo "$out" | grep -qi "is on"; then
    out=$(ppc64_cpu --smt=off 2>&1) || fail "set smt off: $out"
    echo "  disabled: $out"
else
    echo "  not on: $out"
fi
--EOF3

# apply changes to nova-compute unit
echo " + Copy files into n-c unit..."
juju scp $patch_numa nova-compute/0:patch_numa
juju scp $patch_passthrough nova-compute/0:patch_passthrough
juju scp $script_smt nova-compute/0:script_smt.sh

echo " + Script 1 (disable smt)..."
juju ssh nova-compute/0 "\
    sudo chmod +x /home/ubuntu/script_smt.sh &&\
    ls -alh /home/ubuntu &&\
    sudo /home/ubuntu/script_smt.sh"

echo " + Patch 1 (libvirt numa cell memory)..."
juju ssh nova-compute/0 "\
    sudo patch -bN /usr/lib/python2.7/dist-packages/nova/virt/libvirt/config.py < /home/ubuntu/patch_numa"

echo " + Patch 2 (nova compute libvirt cpu passthrough)..."
juju ssh nova-compute/0 "\
    sudo patch -bN /etc/nova/nova-compute.conf < /home/ubuntu/patch_passthrough"

echo " + Restart libvirt-bin and nova-compute services..."
juju ssh nova-compute/0 "\
    sudo service libvirt-bin restart &&\
    sudo service nova-compute restart"

rm -fv $patch_numa
rm -fv $patch_passthrough
rm -fv $script_smt1
