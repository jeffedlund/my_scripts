#!/bin/sh
FILENAME=$1
cpio -ivt -I ${FILENAME}
