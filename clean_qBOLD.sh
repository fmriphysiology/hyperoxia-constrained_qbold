#!/bin/bash

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}

echo 'Removing old files (except TRUST analysis)'

find ${srcout} -maxdepth 1 -type f ! \( -name '*trust*' \) -delete
