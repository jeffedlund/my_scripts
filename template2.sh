#!/usr/bin/env bash
#
# Description:
#
# [ shell functions at top. ]
# [ main program towards bottom of this file. ]
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/java/current/bin:/opt/jdk_current/bin
unalias -a 2>/dev/null
# GLOBAL VARIABLES
OS=`uname -s`
HOSTNAME=`hostname`
PRG=$0
saveddir=`pwd`
PROGRAM_NAME=`basename $0`
LOG_FILE=/tmp/${PROGRAM_NAME}_${HOSTNAME}_${OS}.log
ERROR_LOG=/tmp/${PROGRAM_NAME}_${HOSTNAME}_${OS}.err
TMPDIR=/tmp
TEE_OPTS=' --append '

##############################################################  FUNCTION CALLS
# email_log args should be:  <ReturnValue = 0|1|2...>  <Subject>
function email_log ()
{
    local RETURNVALUE=$1
    local EMAIL_SUBJECT=$2
    local EMAIL_ADDR='me@mydomain.com'
    local HOSTNAME=`hostname`
    local LOCAL_LOG_FILE=${LOG_FILE}.local
    /bin/echo -e "${PROGRAM_NAME} report from: ${HOSTNAME}\nPlease review!\n" >  ${LOCAL_LOG_FILE}
    cat  ${LOG_FILE} >>  ${LOCAL_LOG_FILE}
    unix2dos ${LOCAL_LOG_FILE} >/dev/null 2>&1

    ## Ex.) To CC: a recipient, add "-c me2@mydomain.com" before EMAIL_ADDR
    nohup cat ${LOCAL_LOG_FILE} | mail -v \
          -s "FROM: ${HOSTNAME}: ${PROGRAM_NAME}: ${EMAIL_SUBJECT}" \
          ${EMAIL_ADDR} >> /tmp/${PROGRAM_NAME}_email.log  2>&1  &

    exitprog $RETURNVALUE
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
cd `dirname $PRG`
# test for correct number of arguments
if [[ $# -ne 1 ]]
then
  echo "Usage:  $0  <arguments...> "  2>&1 | tee ${LOG_FILE} ${TEE_OPTS}
  email_log 1 "Incorrect number of arguments."
fi
# clear log file and put timestamp
date > ${LOG_FILE}
echo "Starting ${PROGRAM_NAME} ... " 2>&1 | tee ${LOG_FILE} ${TEE_OPTS}




# finish program and email success
email_log 0 "Successfully executed program ${PROGRAM_NAME} ..."
####################
############## end of script
##
## CHANGES
## 
##
## AUTHOR:  
##
