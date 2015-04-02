#!/bin/bash

echo " + Attempting to stop all instances."

for i in $(nova list | grep = | awk '{ print $2 }');do echo $i; nova stop $i; done
