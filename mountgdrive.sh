#!/bin/sh
#
# Description:
# mount CIFS filesystem that is on Windows Domain
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
unalias -a 2>/dev/null
CIFS_SHARE_FQDN="//fileshare.website.org/data"
####################
## RUN MAIN PROGRAM

# user must have root access
if [[ "$UID" -ne "0" ]]
then
  echo "Error: You must have root access to run this command!"  
  exit 1
fi
echo
echo "Instructions:"
echo "-------------"
echo "You will need to provide your Domain, Username, and Password (below)."
echo "** Do not use your Linux username **"
echo

read -p "Enter your Windows Domain> " windomain
read -p "Enter your Windows username> " username
read -s -p "Enter your Windows password> " password
echo
# run mount with username/password provided
mount -t cifs -o rw,domain=${windomain},user=${username},password=${password}  \
                                                            ${CIFS_SHARE_FQDN}  \
                                                            /mnt/windrive
rc=$?
if [ $rc != 0 ]
then
   echo "Error: mount failed!"
   exit 2
else
   echo "Mount is successful!"
fi
#
exit 0

