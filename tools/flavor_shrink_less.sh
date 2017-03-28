#!/bin/bash
# Shrink flavors for density testing

echo " + Shrinking flavors."
nova flavor-delete m1.tiny ||:
nova flavor-delete m1.small ||:
nova flavor-delete m1.medium ||:
nova flavor-delete m1.large ||:
nova flavor-delete m1.xlarge ||:
nova flavor-create --ephemeral 20 --is-public True m1.tiny 1 512 20 1
nova flavor-create --ephemeral 20 --is-public True m1.small 2 3072 20 2
nova flavor-create --ephemeral 40 --is-public True m1.medium 3 4096 40 2
nova flavor-create --ephemeral 60 --is-public True m1.large 4 6144 60 2
nova flavor-create --ephemeral 80 --is-public True m1.xlarge 5 8192 80 2

# FYI, the defaults:
#+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
#| ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
#+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
#| 1  | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
#| 2  | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
#| 3  | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
#| 4  | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
#| 5  | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
#| 6  | m1.cirros | 64        | 1    | 0         |      | 1     | 1.0         | True      |
#+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+

# And the new values:
#+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
#| ID | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
#+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
#| 1  | m1.tiny   | 512       | 20   | 20        |      | 1     | 1.0         | True      |
#| 2  | m1.small  | 1536      | 20   | 20        |      | 1     | 1.0         | True      |
#| 3  | m1.medium | 2048      | 40   | 40        |      | 2     | 1.0         | True      |
#| 4  | m1.large  | 4096      | 60   | 60        |      | 2     | 1.0         | True      |
#| 5  | m1.xlarge | 8192      | 80   | 80        |      | 2     | 1.0         | True      |
#| 6  | m1.cirros | 64        | 1    | 0         |      | 1     | 1.0         | True      |
#+----+-----------+-----------+------+-----------+------+-------+-------------+-----------+
