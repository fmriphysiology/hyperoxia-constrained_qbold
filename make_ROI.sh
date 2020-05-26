#!/bin/bash

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2
PVthresh=$3

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}


#Create cortical GM mask from MNI template
fslmaths ${srcout}/${subj}_MNI-maxprob-thr0 -thr 3 -uthr 6 ${srcout}/${subj}_gase_cortex
fslmaths ${srcout}/${subj}_MNI-maxprob-thr0 -thr 8 -uthr 8 \
	-add ${srcout}/${subj}_gase_cortex ${srcout}/${subj}_gase_cortex
fslmaths ${srcout}/${subj}_gase_cortex -bin ${srcout}/${subj}_gase_cortex

#Threshold grey matter PVE map and mask with cortex
# fslmaths ${srcout}/${subj}_gase_gm -thr ${PVthresh} -mas ${srcout}/${subj}_cortex \
# 	-bin ${srcout}/${subj}_gm_cortex
# fslmaths ${srcout}/${subj}_gase_wholebrain_gm -thr ${PVthresh} -mas ${srcout}/${subj}_cortex \
# 	-bin ${srcout}/${subj}_gm_cortex
fslmaths ${srcout}/${subj}_gase_merge_gm -thr ${PVthresh} -mas ${srcout}/${subj}_gase_cortex \
	-bin ${srcout}/${subj}_gase_gm_cortex
fslmaths ${srcout}/${subj}_gase_gm_cortex -mas ${srcout}/${subj}_gase_merge_ref_bet ${srcout}/${subj}_gase_gm_cortex

# fslmaths ${srcout}/${subj}_gase_wholebrain_csf -uthr ${PVthresh} -bin ${srcout}/${subj}_csf_cortex
# fslmaths ${srcout}/${subj}_gm_cortex -mas ${srcout}/${subj}_csf_cortex ${srcout}/${subj}_gm_cortex
fslmaths ${srcout}/${subj}_gase_merge_csf -uthr ${PVthresh} -bin ${srcout}/${subj}_gase_csf_thr
#fslmaths ${srcout}/${subj}_gm_cortex -mas ${srcout}/${subj}_csf_thr  ${srcout}/${subj}_gm_cortex

#Transform to ASL space
# flirt -in ${srcout}/${subj}_gm_cortex -ref ${srcout}/${subj}_asl_calib \
# 	-out ${srcout}/${subj}_gm_cortex_regasl -init ${srcout}/ltau2asl.mat \
# 	-interp nearestneighbour -applyxfm

#Threshold white matter PVE map
#fslmaths ${srcout}/${subj}_gase_wm -thr 1 ${srcout}/${subj}_gase_wm_thr
#fslmaths ${srcout}/${subj}_gase_wholebrain_wm -thr 1 ${srcout}/${subj}_gase_wm_thr
fslmaths ${srcout}/${subj}_gase_merge_wm -thr 1 ${srcout}/${subj}_gase_wm_thr

