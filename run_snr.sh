#!/bin/bash
# Nicholas Blockley 2021
# SNR calculation for hqBOLD/sqBOLD analysis

if [ $# -lt 2 ]
then
	echo usage: run_snr.sh source_directory subj_dir
	echo e.g. run_snr.sh /data/hqBOLD/sourcedata/ sub-01
	exit
fi

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}

echo "Preparing ASE images for SNR calculation"

fslroi ${srcout}/${subj}_gase_merge_se ${srcout}/${subj}_gase_merge_img1 9 1
fslroi ${srcout}/${subj}_gase_merge_se ${srcout}/${subj}_gase_merge_img2 10 1

fslmaths ${srcout}/${subj}_gase_merge_img1 -sub ${srcout}/${subj}_gase_merge_img2 ${srcout}/${subj}_gase_merge_imgdiff

fslmaths ${srcout}/${subj}_gase_merge_ref_bet -ero -ero ${srcout}/${subj}_gase_merge_ref_bet_ero

echo "Preparing BOLD images for SNR calculation"

fslroi ${srcout}/${subj}_bold_mcf ${srcout}/${subj}_bold_mcf_img1 598 1
fslroi ${srcout}/${subj}_bold_mcf ${srcout}/${subj}_bold_mcf_img2 599 1

fslmaths ${srcout}/${subj}_bold_mcf_img1 -sub ${srcout}/${subj}_bold_mcf_img2 ${srcout}/${subj}_bold_mcf_imgdiff

fslmaths ${srcout}/${subj}_bold_ref_bet -ero -ero ${srcout}/${subj}_bold_ref_bet_ero


