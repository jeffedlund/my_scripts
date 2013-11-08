#!/bin/sh
#
for hosts in `cat ~/save/hosts.check`
 do   
    echo "Checking connectivity to host: ${hosts}"
    ping -c1 ${hosts} >/dev/null 2>&1
    rc=$?
    if [ $rc != 0 ]
    then   
        echo "${hosts} is possibly down. Skipping..."
    else 
       # Check process
        echo -n "Process running? : "
        sudo ssh ${hosts} 'ps -ef |grep -i "[p]rocess" '
        echo
       # Check for files in certain directory
        echo -n "Files in /usr/out/tmp ? : "
        sudo ssh ${hosts} 'ls -a /usr/out/tmp |grep "[A-Z]" '
        echo
    fi
 done

# end of script
