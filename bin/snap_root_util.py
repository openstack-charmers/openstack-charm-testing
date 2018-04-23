#!/usr/bin/env python3
#This script will restore the snapshot /dev/system/snap-root back to the disk,
#and Reboot the host, so that it's clean for the next set of tests
#Usage:   python3 lv.py         ------    To Create lvsnap
#         python3 lv.py -r      ------    To Restore snap-root to disk


from sys import exit

# Exit codes used for --check:
# 0 - OK to restore
# 1 - curretly restoring 
# 2 - no snapshot found (create a new one)

from time import sleep
import subprocess
import argparse

def get_lv_size():
    lv_getsize_cmd = ["sudo", "pvs", "--noheadings", "-o", "pv_name,pv_used,pv_free", "--units=g", "--nosuffix"]
    size = 0
    try:
        result = subprocess.check_output(lv_getsize_cmd).splitlines()
        for line in result:
            line = line.decode('utf-8').split()
            if line[1] == '0':
                size = size + float(line[2])
        return size
    except Exception as e:
        print(e)

def lvcreate():
    if args.force or check_snapshot() == 2:
        lvcreate_cmd = ["sudo", "lvcreate", "-L" + str(get_lv_size()) + "G", "-s", "-n", "snap-root", "/dev/system/root"]
        try:
            subprocess.run(lvcreate_cmd)
            return 0 
        except Exception as e:
            print("lvcreate has failed")
            print(e)
    else:
        print ("Existing snapshot found, not creating a new one")
        exit(2)

def lvrestore():
    if args.force or check_restoring() == 0:
        lvrestore_cmd = ["sudo", "-i", "lvconvert", "--merge", "/dev/system/snap-root"]
        try:
            subprocess.run(lvrestore_cmd)
            return 0 
        except Exception as e:
            print("lvrestore has failed")
            print(e)
    else:
        print("Snapshot seems to be restoring, not trying again")
        exit(1)

def check_snapshot():
    check_cmd = ["sudo", "dmsetup", "status"]
    output = subprocess.check_output(check_cmd).splitlines()
    found = None
    for line in output:
        if "snap--root" in line.decode('utf-8') and not "cow" in line.decode('utf-8'):
            found = True
            out = line.decode('utf-8').split()
            if out[3] == "error":
                print("snap--root in error, probably still restoring")
                return 1
            size = out[4].split('/')[0]
            print("snap root found, size is {}".format(size))
            return int(size)
    if not found:
        print("snap root not found, you may want to create a new one")
        return 2
         

def check_restoring():
    firstcheck = check_snapshot()
    if firstcheck == 2:
        exit(2)
    print("waiting 60 seconds for snapshot deltas...")
    sleep(60)
    secondcheck = check_snapshot()
    diff = secondcheck - firstcheck
    print ("Difference is: {}".format(diff))
    if diff >= 0:
        print ("No change to filesystem, or growing: probably OK to restore")
        return 0
    if diff < 0:
        print ("snap--root is shrinking, so its probably restoring. Do not restore")
        return 1 

parser = argparse.ArgumentParser()

parser.add_argument('-r', '--restore',
                    help="restore snap-root",
                    required=False,
                    action='store_true')
parser.add_argument('-c', '--create',
                    help="restore snap-root",
                    required=False,
                    action='store_true')
parser.add_argument('-x', '--check',
                   help="check for snap-root size",
                   required=False,
                   action='store_true')
parser.add_argument('-f', '--force',
                   help="force restore or create attempt",
                   required=False,
                   action='store_true')

args = parser.parse_args()


if args.check:
    exit(check_restoring())

if args.create:
    lvcreate()

if args.restore:
    lvrestore()
