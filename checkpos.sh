#!/usr/bin/env bash
#
# Program will check /usr/esig/work directory, on a remote host,
# to see when it was last written to.
#
# [ shell functions at top.  main program towards bottom of this file. ]
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/java/current/bin:/opt/jdk_current/bin
unalias -a 2>/dev/null
# GLOBAL VARIABLES
OS=`uname -s`
HOSTNAME=`hostname`
saveddir=`pwd`
PROGRAM_NAME=`basename $0`
LOG_FILE=/tmp/${PROGRAM_NAME}_${HOSTNAME}.log
ERROR_LOG=/tmp/${PROGRAM_NAME}_${HOSTNAME}.err
FOUND_LOG=/tmp/${PROGRAM_NAME}_${HOSTNAME}_found.txt
TMPDIR=/tmp
TEE_OPTS=' --append '

##############################################################  FUNCTION CALLS
# email_log args should be:  <ReturnValue = 0|1|2...>  <Subject>
function email_log ()
{
    local RETURNVALUE=$1
    local EMAIL_SUBJECT=$2
    #local EMAIL_ADDR='jedlund@thriftywhite.com'
    local EMAIL_ADDR='root@localhost.localdomain'
    local HOSTNAME=`hostname`
    local LOCAL_LOG_FILE=${LOG_FILE}.local
    /bin/echo -e "POS XML Message Report.\n" >  ${LOCAL_LOG_FILE}
    /bin/echo -e "TWRx hosts found with incorrect date in /usr/esig/work:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${FOUND_LOG} >>  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nComplete log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${LOG_FILE} >>  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nError log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${ERROR_LOG} >>  ${LOCAL_LOG_FILE}
    unix2dos ${LOCAL_LOG_FILE} >/dev/null 2>&1

    ## Ex.) To CC: a recipient, add "-c eps@thriftywhite.com" before EMAIL_ADDR
    nohup cat ${LOCAL_LOG_FILE} | mail -v \
          -s "FROM: ${HOSTNAME}: ${PROGRAM_NAME}: ${EMAIL_SUBJECT}" \
          -c dpeterson@thriftywhite.com msevertson@thriftywhite.com \
          ${EMAIL_ADDR} >> /tmp/${PROGRAM_NAME}_email.log  2>&1  &

    exitprog $RETURNVALUE
}

function checkhosts ()
{
    local TODAYSDATE=`date +"%b %e" | tr -s [:space:]`    # ex. "Aug 3"
    local twhost=
    local return_value=
    # run thru loop to check all systems with /usr/esig/work and Freedom POS
    for twhost in `cat /root/bin/hosts4poscheck.txt`
    do 
     echo -n "${twhost} " 2>&1 | tee ${LOG_FILE} ${TEE_OPTS}
     sudo ssh ${twhost} 'ls -la /usr/esig/work | grep "\ \.$" | tr -s [:space:]' 2>&1 | tee ${LOG_FILE} ${TEE_OPTS}
     return_value=$?
     if [[ "${return_value}" -ne "0" ]]
       then
       echo " ERROR: Cannot connect to ${twhost}"  2>&1 | tee ${ERROR_LOG} ${TEE_OPTS}
     fi
    done

    # create simple header for FOUND_LOG file
    echo "host  date" > ${FOUND_LOG}
    echo "----- ------- " >> ${FOUND_LOG}
    # search for any twhost entries that don't match todays date
    cat ${LOG_FILE} | awk '{print $1" "$7" "$8}' | grep -v "${TODAYSDATE}" >> ${FOUND_LOG}
    EMAIL_DATE=`date`
    email_log ${return_value} "CHECKPOS: Completed ${EMAIL_DATE}"
}

function exitprog ()
{
    cd $saveddir
    exit $1
}
## END OF FUNCTIONS
#############################################################################
#
####################
## RUN MAIN PROGRAM

# user must have root access
if [[ "$UID" -ne "0" ]]
then
  echo "User does NOT have root access!"  2>&1 | tee ${LOG_FILE} ${TEE_OPTS}
  email_log 1 "ERROR: ${PROGRAM_NAME}: NO ROOT ACCESS!"
fi

# clear log file and put timestamp
cat /dev/null > ${LOG_FILE}
cat /dev/null > ${ERROR_LOG}
echo "Running ${PROGRAM_NAME} ... " 2>&1 

# call function(s)
checkhosts

# finish program and email success
email_log 0 "Successfully executed program ${PROGRAM_NAME} ..."

####################
############## end of script
##
## CHANGES
## created 2012-08-03
##
## AUTHOR:  JE
##
