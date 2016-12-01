#!/bin/bash -eu
series=${1-"xenial"}
release=${2-"newton"}
pocket=${3-""}

fout=`mktemp`
if [ -z "$series" ] || [ -z "$release" ] ; then
  cat next.yaml.template| sed -r "/\ssource:.+$/d"| sed -r "/\sopenstack-origin:.+$/d" > $fout
else
  cat next.yaml.template| sed -e "s/__SERIES__/$series/g" -e "s/__RELEASE__/$release/g" > $fout
  if [ -n "$pocket" ] ; then
      sed -i -r "s/__POCKET__/-$pocket/g" $fout
  else
      sed -i -r "s/__POCKET__//g" $fout
  fi
fi
cat $fout
rm $fout
