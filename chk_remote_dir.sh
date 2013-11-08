#!/usr/bin/env bash
#

for ll in `cat hosts.check`
 do echo $ll
 result=`sudo ssh $ll "ls -ld /ldm" 2>&1` 
 rc=$?
if [ "${rc}" -ne "0" ]
 then echo "$result"
 fi 
 done

