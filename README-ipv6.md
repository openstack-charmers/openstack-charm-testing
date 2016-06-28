Openstack Charms with IPv6
==========================
How to deploy Openstack charms on an IPv6 network.

NOTE[0]: the percona-cluster charm includes a workaround for bug 1380747 which
         is intended to be removed once this issue is fixed upstream.

NOTE[1]: swift-proxy and neutron-gateway both require python-eventlet >= 0.17
         which only exists in distro as of Ubuntu Wily (Openstack Liberty).

Requirements
============
In order for IPv6 enabled charms to work, hosts much be configured with ipv6
addresses. For test purposes one case use radvd to automatically provide ipv6
addresses to nodes on your network so that you end up with something similar
to the following:
```
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:d3:99:81 brd ff:ff:ff:ff:ff:ff
    inet 10.5.0.77/16 brd 10.5.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 2001:db8:0:1:f816:3eff:fed3:9981/64 scope global dynamic 
       valid_lft 86147sec preferred_lft 14147sec
    inet6 fe80::f816:3eff:fed3:9981/64 scope link 
       valid_lft forever preferred_lft forever
```
NOTE: ensure that ipv6 privacy extensions are DISABLED since the charms do not
support this feature. Ubuntu server currently has them disabled by default and
desktop has them enabled.

Configuring RADVD
=================

1) Install

    sudo apt-get install radvd

2) Set gateway address (assuming eth0 throughout here)

    sudo ip addr add 2001:db8:0:1::2/64 dev eth0

3) Configure

    In /etc/radvd.conf:

    The prefix "2001:db8:0:1::/64" should be changed according to real network
    allocation e.g.

    interface eth0
    {
       AdvSendAdvert on;
       prefix 2001:db8:0:1::/64
       {
            AdvOnLink on;
            AdvAutonomous on;
       };
    };

4) sudo service radvd restart

5) Make sure ipv6 forwarding is enabled
```
    echo "net.ipv6.conf.all.forwarding = 1"| sudo tee /etc/sysctl.d/100-openstack-charms-ipv6.conf
    sudo sysctl -p /etc/sysctl.d/100-openstack-charms-ipv6.conf
```
6) Let IPv6 pass through the firewall
```
    sudo ip6tables -F
```
7) If you are deploying to Openstack, make sure your nova/neutron security
   group rules are allowing Ingress ICMP and TCP (./tools/sec_groups.sh)


Deploying the charms
====================

1) choose a bundle from:

  * bundles/ipv6/next-ipv6.yaml - deploys charms ipv6 from the development branches
  * bundles/ipv6/next-ipv6-ha.yaml - deploys charms as HA ipv6 from the development branches

2) Using one of the above do:
```
    juju-deployer -c <bundle> -d trusty-mitaka
```

3) Once complete, switch novarc to tools/ipv6/novarc and run ./configure <profile>

NOTE: if you are not deploying HA you'll need to set OS_AUTH_URL to the v6 address of your keystone unit

4) You can then run tests found in the tools/ipv6 directory

