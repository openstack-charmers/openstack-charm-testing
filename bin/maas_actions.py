#!/usr/bin/env python3

# A script to use to release, lock and/or unlock MAAS machines for 
# a specific owner, specific tags and specific architecture
#
# Recommendation: when running a MOSCI job, lock MAAS nodes so they can't be released
# During the teardown stage, all MAAS machines will be unlocked so they can be re-used
# Urgent or mandatory MOSCI jobs can use --force to unlock and release all MAAS machines
#
# Lock and Unlock will only work if the API key provided has admin permissions

import sys, os
import argparse
import bson 
import json
from pprint import pprint
from apiclient import maas_client

os.environ['HTTP_PROXY'] = ""
os.environ['http_proxy'] = ""

parser = argparse.ArgumentParser(description="Release, lock or unlock a maas machine:"
                                             "-o and at least one of -r, -l, -u required. "
                                             "MAAS admin permissions required to lock/unlock.")
parser.add_argument('-a', '--arch', help="architecture to match")
parser.add_argument('-c', '--count', help="count machines in Ready state, matching arch and tags", action="store_true")
parser.add_argument('-m', '--maashost', help="MAAS hostname (api v2 support only)", required=True)
parser.add_argument('-k', '--key', help="MAAS api key", required=True)
parser.add_argument('-t', '--tags', help="primary tag to match")
parser.add_argument('--output', help="show machine id after displaying count", action="store_true")
parser.add_argument('--status', help="system status to match")
parser.add_argument('-s', '--system_id', help="system id")
parser.add_argument('--getips', help="show ip addresses after interface id", action="store_true")
parser.add_argument('-o', '--owner', help="owner name", required=True)
parser.add_argument('-r', '--release', help="release this machine", action="store_true")
parser.add_argument('-l', '--lock', help="lock this machine (add locked tag)", action="store_true")
parser.add_argument('-u', '--unlock', help="unlock this machine (remove locked tag)", action="store_true")
parser.add_argument('--list', help="just list machines", action="store_true")
parser.add_argument('-i', '--interfaces', help="interfaces=machine_id - get machine detail")
parser.add_argument('-f', '--force', help="release and unlock this machine regardless of lock status", action="store_true")
parser.add_argument('--additional', help="one additional tag")
parser.add_argument('--deploy', help="deploy to --system_id id", action="store_true")
args = parser.parse_args()

# Check that an action has been specified
if not args.getips and not args.deploy and not args.release and not args.lock and not args.unlock and not args.list and not args.interfaces and not args.count:
    print("At least one of: -r, -l, -u, --list, --count are required")
    sys.exit(100)

# If releasing, make sure we have tags and arch or system id
if (args.release or args.list or args.count) and (not args.tags or not args.arch) and not args.system_id:
    print (args)
    print("Can't list, count or release machines without tags and arch or system id")
    sys.exit(101)

# Lock or unlock one specific host
if (args.lock or args.unlock) and not args.system_id:
    print("Can't lock or unlock without specifying system id")
    sys.exit(102)

# Can't lock and unlock at the same time
if args.lock and args.unlock:
    print("Refusing to lock and unlock a machine, only specify one")
    sys.exit(103)

# Just list the nodes
if args.list or args.count:
    args.release == False
    args.lock == False
    args.unlock == False

# Machines with tag "locked" will not be released unless --force is specified
# Set this manually via the MAAS web UI or with an admin API key
TAGS=args.tags
ARCH=args.arch
OWNER=args.owner
APIKEY=args.key
MAAS_URL="http://" + args.maashost + "/MAAS/api/2.0"
ADD_TAGS=args.additional
SYSTEM_ID=args.system_id
if args.status == "":
    STATUS="not ready"
else:
    STATUS = args.status

#print ("Trying to find machines which match the following:\ntags: {}, arch: {}, owner: {}, maas url: {}\n".format(TAGS,ARCH,OWNER,MAAS_URL))

auth = maas_client.MAASOAuth(*APIKEY.split(":"))
client = maas_client.MAASClient(auth, maas_client.MAASDispatcher(), MAAS_URL)

def getSysIds(tags=TAGS,owner=OWNER,arch=ARCH,additional=ADD_TAGS,status=STATUS):
    id = []
    result = client.get(u"tags/" + TAGS + "/", "machines")
    data = str(result.read(), "utf8")
    jdata = json.loads(data)
    for item in jdata:
        if additional is not None:
            if item["owner"] == owner and arch in item["architecture"] and additional in item["tag_names"]:
                if not args.force and "locked" in item["tag_names"]:
                    print ("{} found (locked)".format(item["system_id"]))
                else:
                    id.append(item["system_id"])
        else:
            if item["owner"] == owner and arch in item["architecture"]:
                if not args.force and "locked" in item["tag_names"]:
                    print ("{} found (locked)".format(item["system_id"]))
                else:
                    id.append(item["system_id"])
    return id

def CountAvailable(tags=TAGS,arch=ARCH,output=False):
    id = []
    result = client.get(u"tags/" +TAGS + "/", "machines")
    data = str(result.read(), "utf8")
    jdata = json.loads(data)
    for item in jdata:
        if item["owner"] == None and arch in item["architecture"] and item["status_name"] == "Ready":
            id.append(item["system_id"])
    return id

def getInterfaces(id=args.interfaces):
    result = client.get(u"nodes/" + id + "/interfaces/")
    data = str(result.read(), "utf8")
    jdata = json.loads(data)
    interfaces = []
    for item in jdata:
        for iface in item["links"]:
            if "subnet" in iface:
                if not args.getips:
                    print(item["name"])
                else:
                    try:
                        print("{}, {}".format(item["name"],item["links"][0]["ip_address"]))
                    except KeyError as e:
                        print("{}, No_IP_Assigned".format(item["name"]))

def getIPs():
    interfaces=getInterfaces(id=args.system_id)

#    for interface in interfaces:
#        print("Interface: {}".format(interface))
#        print("SysID: {}".format(args.system_id))
#        result = client.get(u"nodes/" + args.system_id + "/interfaces/" + str(interface))
#        print(result)
#        sys.exit()

def Deploy(system_id):
    result = client.post(u"machines/" + system_id + "/", "deploy")

def Release(**system_id):
    if system_id['system_id'] == None:
        found = getSysIds()
    else:
        found = {system_id['system_id']}
    if found == []:
        print ("No machines found to release")
        sys.exit(0)
    print ("Found these ID's to release: {}".format(found))
    for system in found:
        print ("Releasing {}".format(system))
        client.post(u"machines/" + system + "/", "release")

def Lock(system_id=SYSTEM_ID):
    # Requires admin permissions
    client.post(u"tags/locked/", "update_nodes", "add" + system_id)

def Unlock():
    # Requires admin permissions
    client.post(u"tags/locked/", "update_nodes", "add" + system_id)

if args.interfaces:
    getInterfaces()

if args.release:
    Release(system_id=args.system_id)

if args.lock:
    Lock()

if args.unlock:
    Unlock()

if args.count:
    found = CountAvailable()
    if not found:
        print ("0")
    else:
        print (len(found))
        if args.output:
            print('\n'.join(found))

if args.list:
    found = getSysIds()
    if not found:
        sys.exit(0)
    else:
        print ("Found these unlocked systems:")
        for system in found:
            print (system)

if args.deploy:
    Deploy(args.system_id)


