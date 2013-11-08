#!/bin/sh
FILENAME=$1
find . -type f | cpio -o > ${FILENAME}
