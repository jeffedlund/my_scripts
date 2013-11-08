#!/usr/bin/env bash
#
#
for checkhost in `cat /mnt/save/jeff/hosts.check `
do
    echo $checkhost;
    result=`sudo ssh $checkhost "mkdir /opt/alchemy_update" 2>&1`
    rc=$?
    if [ "${rc}" -ne "0" ]
    then
        echo "Error with mkdir at ${checkhost} : $rc"
    fi
    echo "Result: $result"
done

