#!/bin/bash

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2
PVthresh=$3

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}


#Create cortical GM mask from MNI template
fslmaths ${srcout}/${subj}_MNI-maxprob-thr0 -thr 3 -uthr 6 ${srcout}/${subj}_cortex
fslmaths ${srcout}/${subj}_MNI-maxprob-thr0 -thr 8 -uthr 8 \
	-add ${srcout}/${subj}_cortex ${srcout}/${subj}_cortex
fslmaths ${srcout}/${subj}_cortex -bin ${srcout}/${subj}_cortex

#Threshold grey matter PVE map and mask with cortex
fslmaths ${srcout}/${subj}_gase_gm -thr ${PVthresh} -mas ${srcout}/${subj}_cortex \
	-bin ${srcout}/${subj}_gm_cortex

#Transform to ASL space
flirt -in ${srcout}/${subj}_gm_cortex -ref ${srcout}/${subj}_asl_calib \
	-out ${srcout}/${subj}_gm_cortex_regasl -init ${srcout}/ltau2asl.mat \
	-interp nearestneighbour -applyxfm

#Threshold white matter PVE map
fslmaths ${srcout}/${subj}_gase_wm -thr 1 ${srcout}/${subj}_gase_wm_thr

