#!/usr/bin/env bash
#
for ll in `cat hosts.check`
do 
    echo "Checking connectivity to host: $ll"
    ping -c1 $ll >/dev/null 2>&1
    rc=$?
    if [ $rc != 0 ]
    then 
        echo "$ll is down. Skipping..."
    else 
        sudo ssh $ll "ls -la /usr/esig/work |grep R"
    fi
done

