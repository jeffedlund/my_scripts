#!/bin/sh -x
#
# Description:
#   Modify a /etc/hosts entry on a Linux server
#              ex.)
#              192.168.165.119 lp067
#              # (change to)
#              192.168.220.119 lp067
#
# Usage:
#      chhosts.sh [printer_queue_name] [new_ip_address]
#    ex.)
#      chhosts.sh  lp067  192.168.220.119
#
# New printer assignments:
## S46: lp046: 192.168.220.26
## S53: lp053: 192.168.220.42
## S67: lp067: 192.168.220.119
## 

PATH=/usr/local/bin:/usr/bin:/bin:/sbin
unalias -a 2>/dev/null
# GLOBAL VARIABLES
OS_RELEASE=`uname -r`
HOSTNAME=`hostname`
PROGRAM_NAME=`basename $0`
TMPDIR=/tmp
LOG=${TMPDIR}/${PROGRAM_NAME}_${HOSTNAME}.log
ERROR_LOG=${TMPDIR}/${PROGRAM_NAME}_${HOSTNAME}.err
##############################################################  FUNCTION CALLS
# email_log args should be:  <Subject_of_email>
function email_log ()
{
    local EMAIL_SUBJECT=$1
    local EMAIL_ADDR='jedlund@thriftywhite.com'
    local HOSTNAME=`hostname`
    local LOCAL_LOG_FILE=${LOG}.local
    /bin/echo -e "${PROGRAM_NAME} Report.\n" >  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nComplete log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${LOG} >>  ${LOCAL_LOG_FILE}
    /bin/echo -e "\n\nError log:\n" >>  ${LOCAL_LOG_FILE}
    cat  ${ERROR_LOG} >>  ${LOCAL_LOG_FILE}
    unix2dos ${LOCAL_LOG_FILE} >/dev/null 2>&1

    ## Ex.) To CC: a recipient, add "-c eps@thriftywhite.com" before EMAIL_ADDR
    nohup cat ${LOCAL_LOG_FILE} | mail -v \
          -s "FROM: ${HOSTNAME}: ${PROGRAM_NAME}: ${EMAIL_SUBJECT}" \
          ${EMAIL_ADDR} >> /tmp/${PROGRAM_NAME}_email.log  2>&1  &

    return 0
}

# modify_hosts args should be:  <printer_queue_name> <new_ip_address>
function modify_hosts()
{
    local PRINTER=$1
    local IP_ADDR=$2
    local ETC_HOSTS=/etc/hosts
    # Backup file first
    cp -f ${ETC_HOSTS} ${ETC_HOSTS}.chhosts.old 2>> ${ERROR_LOG}
    # find line # where printer is found in file
    # ex.) grep -n lp067 /etc/hosts|cut -d: -f1
    local LINENUMBER=`grep -n ${PRINTER} ${ETC_HOSTS} | cut -d: -f1`
    if [ -z $LINENUMBER ]
    then
        /bin/echo -e "Printer: ${PRINTER} NOT FOUND in ${ETC_HOSTS} " >> ${LOG}
        /bin/echo -e >> ${LOG}
        /bin/echo -e "${ETC_HOSTS} file not modified." >> ${LOG}
        /bin/echo -e >> ${LOG}
        return 3
    fi
    if [ -w $ETC_HOSTS ]     # if exists and write permission is granted
    then
        # replace just the 3rd octet in IP address 
        # sed  -e "${LINENUMBER}s/\.165\./\.220\./" ${ETC_HOSTS}.chhosts.old > ${ETC_HOSTS} 2>> ${ERROR_LOG}
        # or replace whole line
        sed  -e "${LINENUMBER}s/^.*$/${IP_ADDR}\ ${PRINTER}/" ${ETC_HOSTS}.chhosts.old > ${ETC_HOSTS} 2>> ${ERROR_LOG}
        ERROR_ONE=$?
        if [ $ERROR_ONE != 0 ]   # check for errors reported by sed
        then
            /bin/echo -e "errors while modifying ${ETC_HOSTS}" >> ${LOG}
            /bin/echo -e >> ${LOG}
            /bin/echo -e "Original file name saved as: ${ETC_HOSTS}.chhosts.old" >> ${LOG}
            /bin/echo -e >> ${LOG}
            /bin/echo -e "Now restoring original...." >> ${LOG}
            /bin/echo -e >> ${LOG}
            cp -f ${ETC_HOSTS}.chhosts.old ${ETC_HOSTS}  # Restore original
            /bin/echo -e "Done...." >> ${LOG}
            /bin/echo -e >> ${LOG}
            /bin/echo -e "Please double-check the ${ETC_HOSTS} file on: ${HOSTNAME}" >> ${LOG}
            /bin/echo -e >> ${LOG}
            return 1
        else
            /bin/echo -e "${ETC_HOSTS} updated!"  >> ${LOG}
        fi
        
        # check for other errors
        COUNT=`cat ${ETC_HOSTS} | wc -l `
        if [ $COUNT -lt 3 ]
        then
              /bin/echo -e >> ${LOG}
              /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e "Something is wrong with the ${ETC_HOSTS} file!" >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e "Original file name saved as: ${ETC_HOSTS}.chhosts.old" >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e "Now restoring original...." >> ${LOG}
              /bin/echo -e >> ${LOG}
              cp -f ${ETC_HOSTS}.chhosts.old ${ETC_HOSTS}  # Restore original
              /bin/echo -e "Done...." >> ${LOG}
              /bin/echo -e >> ${LOG}
              /bin/echo -e "Please double-check the ${ETC_HOSTS} file on: ${HOSTNAME}" >> ${LOG}
              /bin/echo -e >> ${LOG}
              #/bin/mv $LOG ${LOG}.Z
              #/bin/cp ${LOG}.Z /tohq
              return 1
        fi	
    else
        /bin/echo -e >> ${LOG}
        /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
        /bin/echo -e >> ${LOG}
        /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
        /bin/echo -e >> ${LOG}
        /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
        /bin/echo -e >> ${LOG}
        /bin/echo -e " *************** ATTENTION *************** " >> ${LOG}
        /bin/echo -e >> ${LOG}
        /bin/echo -e "The ${ETC_HOSTS} file is NOT editable!" >> ${LOG}
        /bin/echo -e >> ${LOG}
        /bin/echo -e "Modifications to the ${ETC_HOSTS} file CANNOT be completed!" >> ${LOG}
        return 2
    fi
    return 0
}
# exitprog args <ExitValue = 0|1|2...> 
function exitprog ()
{
    /bin/echo -e "Exiting..." >> ${LOG}
    exit $1
}
## END OF FUNCTIONS
#############################################################################
#
####################
## RUN MAIN PROGRAM

# clear log files, if root user
cat /dev/null > ${LOG}
cat /dev/null > ${ERROR_LOG}
/bin/echo -en "Running ${PROGRAM_NAME} ... Start Date: " >> ${LOG}
date >> ${LOG}

# user must have root access
if [ $UID -ne 0 ]
then
  #/bin/echo -e "User does NOT have root access!" >> ${LOG}
  email_log "ERROR:MAIN: NO ROOT ACCESS!"
  exitprog 2
fi

# verify correct usage of arguments
USAGE_SMT="Usage: $0 [printer_queue_name] [new_ip_address]"
if [ $# -ne 2 ] 
then
    /bin/echo -e "${USAGE_SMT}"  >> ${LOG}
    email_log "Incorrect Usage: $0 $1 $2"
    exitprog 2
fi

# call function(s)
modify_hosts $1 $2
RC=$?
if [ $RC -ne 0 ]
then
    case $RC in
            1) 
                /bin/echo -e "ERROR:FUNCTION CALL: modify_hosts(): file modification error" >> ${LOG}
                email_log "ERROR:FUNCTION CALL: modify_hosts(): file modification error"
                exitprog 1
                ;;
            2)
                /bin/echo -e "ERROR:FUNCTION CALL: modify_hosts(): file write error" >> ${LOG}
                email_log "ERROR:FUNCTION CALL: modify_hosts(): file write error"
                exitprog 2
                ;;
            3)
                /bin/echo -e "ERROR: $1 PRINTER NOT FOUND @ $HOSTNAME" >> ${LOG}
                email_log "ERROR: $1 PRINTER NOT FOUND @ $HOSTNAME"
                exitprog 3
                ;;
            *) 
                /bin/echo -e "ERROR:FUNCTION CALL: modify_hosts()" >> ${LOG}
                email_log "ERROR:FUNCTION CALL: modify_hosts()"
                exitprog 1
                ;;
    esac
fi
# Copy Log file to /tohq - so that it gets transferred to tw001
#/bin/mv $LOG ${LOG}.Z
#/bin/cp ${LOG}.Z /tohq
#
# finish program and email success
email_log "Successfully executed!"
exitprog 0

####################
############## end of script
##
## CHANGES
## created 2013-04-24
##
## AUTHOR: JE
##
