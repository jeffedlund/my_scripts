#!/bin/sh
FILENAME=$1
cpio -iv -I ${FILENAME} --make-directories
