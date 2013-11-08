#!/bin/sh

HOSTNAME=`uname -n`

ifconfig -a  >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
cat /etc/hosts  >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
lpstat -t  >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
cat /etc/inittab  >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
finger  >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
echo   >> /${HOSTNAME}.txt
tail -20 /etc/passwd  >> /${HOSTNAME}.txt

