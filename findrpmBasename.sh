#!/usr/bin/env bash
#
# Description:
#     strip rpms to their basic package name
#

for RPM in `cat fc12-13-14.rpms `
do 
   rpm -q --qf %-40{NAME} ${RPM} >> fc12-13-14.rpms.NAME
   echo >> fc12-13-14.rpms.NAME
done 

#
# From 'rpm' man page:
#
#  For example, to print only the names of the packages queried, you could
#   use  %{NAME} as the format string.  To print the packages name and dis-
#   tribution information in two columns, you could use %-30{NAME}%{DISTRI-
#   BUTION}.   rpm will print a list of all of the tags it knows about when
#   it is invoked with the --querytags argument.
#
