#!/bin/bash

echo " + Attempting to start all instances."

for i in $(nova list | grep SHUT | awk '{ print $2 }');do echo $i; nova start $i; done
