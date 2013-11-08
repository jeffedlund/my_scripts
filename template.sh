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
saveddir=`pwd`
PROGRAM_NAME=`basename $0`
LOG_FILE=/tmp/${PROGRAM_NAME}_${HOSTNAME}.log
ERROR_LOG=/tmp/${PROGRAM_NAME}_${HOSTNAME}.err
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
    /bin/echo -e "${PROGRAM_NAME} Report.\n" >  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nComplete log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${LOG_FILE} >>  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nError log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${ERROR_LOG} >>  ${LOCAL_LOG_FILE}
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

# user must have root access
if [[ "$UID" -ne "0" ]]
then
  echo "User does NOT have root access!"  2>&1 | tee ${LOG_FILE} ${TEE_OPTS}
  email_log 1 "ERROR: ${PROGRAM_NAME}: NO ROOT ACCESS!"
fi

# clear log files
cat /dev/null > ${LOG_FILE}
cat /dev/null > ${ERROR_LOG}
echo "Running ${PROGRAM_NAME} ... " 2>&1 

# call function(s)


# finish program and email success
email_log 0 "Successfully executed program ${PROGRAM_NAME} ..."

####################
############## end of script
##
## CHANGES
## created ####-##-##
##
## AUTHOR: 
##
