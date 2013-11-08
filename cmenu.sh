#!/bin/sh
# Change .profile - for SCO Unix
# Change vcsprofile - for Linux
# Change inetmenu - for either SCO Unix or Linux

PATH=/usr/local/bin:/usr/bin:/bin:/sbin
unalias -a 2>/dev/null

# user must have root access 
if [ "$UID" -ne "0" ]
then
echo "User doesn't have root access" > ${LOG}
exit 1
fi

OS=`uname -s`
HOSTNAME=`hostname`
LOG=/tohq/cmenu_${HOSTNAME}_${OS}.log.Z
ERROR_LOG=/tmp/cmenu.err

# clear log files
cat /dev/null > ${LOG}
cat /dev/null > ${ERROR_LOG}

# modify files
for USERNAME in `cat /etc/passwd | grep "\/usr\/" | grep "sh" | cut -f1 -d: `
do
	for VFILE in .profile vcsprofile inetmenu
	do
		CHECKFILE=`echo -n /usr/${USERNAME}/${VFILE}`
		if [ -e $CHECKFILE ]
		then
			# Backup file first
			cp -f ${CHECKFILE} ${CHECKFILE}.cmenu.old
			sed -e "s/Viking\ Computer\ Services/\ Thrifty\ White\ Pharmacy\ /g" ${CHECKFILE}.cmenu.old > ${CHECKFILE}.tmp 2> ${ERROR_LOG}
			ERROR_ONE=$?
			sed -e "s/[Ss]cript[Mm]aster\ Translator/\ \ \ \ TWRx\ Translator\ \ \ \ /g" ${CHECKFILE}.tmp > ${CHECKFILE}.tmp2 2> ${ERROR_LOG}
			ERROR_TWO=$?
			sed -e "s/CALL\ VIKING\ COMPUTER\ SERVICES'/CALL\ THRIFTY\ WHITE\ PHARMACY/g" ${CHECKFILE}.tmp2 > ${CHECKFILE}.tmp3 2> ${ERROR_LOG}
			ERROR_THREE=$?
			sed -e "s/SCRIPTMASTER/TWRx/g" ${CHECKFILE}.tmp3 > ${CHECKFILE}.tmp4 2> ${ERROR_LOG}
			ERROR_FOUR=$?
			sed -e "s/[Ss]cript[Mm]aster/TWRx\ \ \ \ \ \ \ \ /g" ${CHECKFILE}.tmp4 > ${CHECKFILE} 2> ${ERROR_LOG}
			ERROR_FIVE=$?
			/bin/rm ${CHECKFILE}.tmp
			/bin/rm ${CHECKFILE}.tmp2
			/bin/rm ${CHECKFILE}.tmp3
			/bin/rm ${CHECKFILE}.tmp4

			# check for errors reported by sed
			if [ $ERROR_ONE != 0 -o $ERROR_TWO != 0 -o $ERROR_THREE != 0 -o $ERROR_FOUR != 0 -o $ERROR_FIVE != 0 ]
   			then
   				echo "errors while changing ${CHECKFILE}" >> ${LOG}
				cat ${ERROR_LOG} >> ${LOG}
				date >> ${LOG}
   			else
				echo "${CHECKFILE} updated"  >> ${LOG}
				date >> ${LOG}
			fi
			
			# check for errors
			COUNT=`cat ${CHECKFILE} | wc -l `
			if [ $COUNT -lt 3 ]
			then
			      echo  >> ${LOG}
			      echo " *************** ATTENTION *************** " >> ${LOG}
			      echo >> ${LOG}
			      echo " *************** ATTENTION *************** " >> ${LOG}
			      echo >> ${LOG}
			      echo " *************** ATTENTION *************** " >> ${LOG}
			      echo >> ${LOG}
			      echo " *************** ATTENTION *************** " >> ${LOG}
			      echo >> ${LOG}
			      echo "Something is wrong with the ${CHECKFILE} file" >> ${LOG}
			      echo "You must restore the original file !!!" >> ${LOG}
			      echo >> ${LOG}
			      echo "Original file name saved as: ${CHECKFILE}.cmenu.old" >> ${LOG}
			      echo >> ${LOG}
			      echo "Exiting..." >> ${LOG}
			fi			
			
		fi
	
	done
	
done


