#!/bin/sh
# perf1.sh --
#
# Copyright 2004 Red Hat Inc., Durham, North Carolina. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation on the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice (including the
# next paragraph) shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT. IN NO EVENT SHALL RED HAT AND/OR THEIR SUPPLIERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
if test x"$1" == x""; then
echo "Usage: ./perf1.sh <logfile-name>"
exit 1
fi
FILE=$1
ITER=10
if test -e $FILE; then
echo "WARNING: $FILE exists -- will NOT overwrite"
exit 1
fi
function log () {
d=`date`
echo "$d: $1"
echo "==================================================" >> $FILE
echo "$d: $1" >> $FILE
if test x"$2" != x""; then
shift
fi
$* >> $FILE 2>&1
}
function logi () {
d=`date`
printf "$d: %-20.20s (PASS $1 of $ITER)\n" $2
echo "==================================================" >> $FILE
printf "$d: %-20.20s (PASS $1 of $ITER)\n" $2 >> $FILE
shift
if test x"$2" != x""; then
shift
fi
$* >> $FILE 2>&1
}
function ccc () {
log $1 cat $1
}
function ccci () {
logi $1 $2 cat $2
}
function note () {
echo "`date`: (NOTE: $*)"
}
function banner () {
d=`date`
echo "=================================================="
echo "===== $d: $* ====="
echo "==================================================" >> $FILE
echo "===== $d: $* =====" >> $FILE
}
banner "Start of Testing ($FILE)"
banner General System Information
log uname uname -a
log free
log df df -h
log mount
log lsmod
log lspci lspci -v
log dmidecode
log route route -n
log ifconfig
log "ip rule ls" ip rule ls
log "ip route ls" ip route ls
log iptables "iptables -L -n -v"
log sysctl sysctl -a
ccc /proc/cpuinfo
ccc /proc/meminfo
ccc /proc/net/dev
ccc /proc/interrupts
ccc /proc/devices
ccc /proc/cmdline
ccc /proc/scsi/scsi
ccc /etc/modules.conf
ccc /var/log/dmesg
banner Performance Snapshot
log ps ps auxwww
log sar sar -A
let t="10*$ITER"
note "The following takes about $t seconds"
log "vmstat" vmstat $ITER 10
note "The following takes about $t seconds"
log "iostat" iostat -k $ITER 10
note "Each pass takes 10 seconds"
for i in `seq 1 $ITER`; do
note "**** PASS $i of $ITER"
logi $i uptime
logi $i free
ccci $i /proc/interrupts
ccci $i /proc/stat
logi $i ifconfig ifconfig -a
sleep 10
done
banner "End of Testing ($FILE)"
