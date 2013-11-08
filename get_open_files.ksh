#!/bin/ksh
###
### Pass in a mounted filesystem or a file and get the users
### and processes attached to that system.
###
### Demonstrates the use of 'fuser' and 'ps'.
###
### Arguments:
###   <type> - file|dir or filesystem
###   <arg>  - The file, directory or filesystem
###
### Formed from shell-me submittal
### Submitted by: Eric Steed
###

### Check we have 2 args
if [[ $# -lt 2 ]]; then
    print "\n Usage: get_open_files <file|dir|filesystem> <fs|file|dir> \n\n"
    exit 1;
fi

### Set the args to vars
type_of_check=${1}
item_to_check=${2}

### Test the types and do the correct command
if [[ "$type_of_check" = "file" || "$type_of_check" = "dir" ]]; then
    /bin/ps -fp `fuser $item_to_check 2> /dev/null| xargs | sed 's/ / -p /g'`
elif [[ "$type_of_check" = "filesystem" ]]; then
    /bin/ps -fp `fuser -c $item_to_check 2> /dev/null| xargs | sed 's/ / -p /g'`
else
    print "Invalid argument: ${type_of_check} \n"
    exit 1
fi

### Exit
exit 0;

##############################################################################
### This script is submitted to BigAdmin by a user of the BigAdmin community.
### Sun Microsystems, Inc. is not responsible for the
### contents or the code enclosed. 
###
###
### Copyright 2008 Sun Microsystems, Inc. ALL RIGHTS RESERVED
### Use of this software is authorized pursuant to the
### terms of the license found at
### http://www.sun.com/bigadmin/common/berkeley_license.html
##############################################################################
