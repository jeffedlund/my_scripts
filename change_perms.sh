#!/usr/bin/env bash
#
# Modify file permissions within a given directory
#
# NOTES:
# 1) sets the group=wheel 
# 2) change permssions to match those of the directory's owner
#
PATH=/bin:/usr/bin:/usr/local/bin:/usr/java/current/bin:/opt/jdk_current/bin:.
#
# user needs to pass 1 argument to program
DIRECTORY=$1
# test if argument is valid
if [[ ! -d ${DIRECTORY} || -z ${DIRECTORY} ]]
then
  echo
  echo "  USAGE: $0 <directory_to_modify> "
  echo
  exit 1
fi
#
# Recursively change the group to be equal to 'wheel'
chgrp -R wheel ${DIRECTORY}
return_value=$?
if [[ "${return_value}" -ne "0" ]]
 then
  # assume user not current owner of directory, or it doesn't exist
  echo
  echo '  ERROR: Directory must exist, and you must be the current owner!'
  echo "  Exiting ...  with error: ${return_value} "
  echo
  exit ${return_value}
fi
#
# if test above passes, begin to modify permissions
#
for PERMS in r w x     # file perms to change: r=read, w=write, x=executable
do
  for FILETYPE in d f   # file type to search for: d=directory, f=normal_file
  do
     for FILEWITHTYPE in `find  ${DIRECTORY} -type ${FILETYPE} `
     do 
        if test -${PERMS}  ${FILEWITHTYPE}
        then 
           chmod g+${PERMS}  ${FILEWITHTYPE}
           rv=$?
           if [[ "${rv}" -ne "0" ]]
           then
             echo
             echo "  Exiting ...  with error: ${rv} "
             echo
             exit ${rv}
           fi
        fi
     done
  done
done
#
echo "Done."
exit 0
# script end
# created: 2011-12-24
# author:  J.E.
