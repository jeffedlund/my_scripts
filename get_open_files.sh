#!/usr/bin/env bash
#
 for ll in `fuser /dev/console |cut -d: -f1 `;
 do  
     clear;
     lsof -P -n -p ${ll};
     /bin/echo -e "\n\n Process: $ll";
     sleep 2;
     read -p "Enter to continue" RR;
     echo
 done
 
