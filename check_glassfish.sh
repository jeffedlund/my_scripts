#!/bin/sh
echo "Starting process the checks for glassfish java runtime"
#
# start of loop
#
LOG__FILE=/tmp/check_gf.out
email_error ()
{
  echo "App Server is NOT RUNNING on eps.thriftywhite.com" | mail -v \
        -s Glassfish_App_Server_NOT_RUNNING \
        -c me@mydomain.org root@localhost \
           jeff@localhost  >> ${LOG__FILE}  2>&1

  /sbin/service glassfish restart   >> ${LOG__FILE}  2>&1
  sleep 60   # sleep for 1 minutes before continuing loop
}


while true
do
	ps -ef | grep "[j]ava" | grep "glassfish\-v2\.1" >> /tmp/check_gf.out 2>&1
	if [ $? -ne 0 ]
	then
	  email_error
	fi
        sleep 5
done &
