#!/usr/bin/env bash
#
# Description:
# Find longest idle session/login and ask user okay to terminate.
#
# [ shell functions at top. ]
# [ main program towards bottom of this file. ]
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
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
function find_user_with_days ()
{
    # find 1 user that has been idle for 1 day or more
    # ignore /dev/tty users
    local FOUNDRESULT1=`w -s \
            | tail -n +3 \
            | grep -v tty \
            | awk 'BEGIN{FIELDWIDTHS="9 9 16 8 20"}{print $1,$2,$4,$5}' \
            | grep days \
            | sort -nr -k3 \
            | head -n1 `

    # Header
    #  14:54:00 up 10 days,  6:22, 18 users,  load average: 0.18, 0.14, 0.15
    # USER     TTY      FROM               IDLE WHAT

    # Example output
    # --------------
    # jeff     pts/1    :0.0             57days bash
    echo "FOUNDRESULT1=\"${FOUNDRESULT1}\""
}

function find_user_with_hours ()
{
    # find 1 user that has been idle for 1 hour or more
    local FOUNDRESULT2=`finger \
            | grep -v tty \
            | awk 'BEGIN{FIELDWIDTHS="10 11 7 8 13 11 18"}{print $1$3$4$5}' \
            | grep "\ \ [0-9]*\:[0-9][0-9]\ \ " \
            | sed -e 's/\([0-9]*\)\:\([0-9][0-9]\)/\1\.\2/' \
            | sort -nr -k3 \
            | head -n1 `

    # Header
    # Login     Tty      Idle  Login Time
    # Example output
    # --------------
    # pharmacy  pts/9    3.07  Feb  8 10:36

    echo "FOUNDRESULT2=\"${FOUNDRESULT2}\""
}

# email_log args should be:  <ReturnValue = 0|1|2...>  <Subject>
function email_log ()
{
    local RETURNVALUE=$1
    local EMAIL_SUBJECT=$2
    local EMAIL_ADDR='jedlund@thriftywhite.com'
    local HOSTNAME=`hostname`
    local LOCAL_LOG_FILE=${LOG_FILE}.local
    /bin/echo -e "${PROGRAM_NAME} Report.\n" >  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nComplete log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${LOG_FILE} >>  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nError log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${ERROR_LOG} >>  ${LOCAL_LOG_FILE}
    unix2dos ${LOCAL_LOG_FILE} >/dev/null 2>&1

    ## Ex.) To CC: a recipient, add "-c eps@thriftywhite.com" before EMAIL_ADDR
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
clear
# user must have root access
if [[ "$UID" -ne "0" ]]
then
  echo "User does NOT have root access!"  2>&1 | tee ${LOG_FILE} ${TEE_OPTS}
  #email_log 1 "ERROR: ${PROGRAM_NAME}: NO ROOT ACCESS!"
fi

# clear log files
cat /dev/null > ${LOG_FILE}
cat /dev/null > ${ERROR_LOG}
echo "Running ${PROGRAM_NAME} ... " 2>&1

# call function(s)
find_user_with_days
find_user_with_hours

# finish program and email success
#email_log 0 "Successfully executed program ${PROGRAM_NAME} ..."

####################
############## end of script
##
## CHANGES
## created 2013-02-08
##
## AUTHOR: JE
##
