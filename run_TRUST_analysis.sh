#!/bin/bash


if [ $# -lt 2 ]
then
	echo usage: run_TRUST_analysis.sh source_directory subj_dir
	echo e.g. run_TRUST_analysis.sh /data/hc-qBOLD/sourcedata/ sub-01
	exit
fi

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}

# motion correct unsubtracted tag/control images
mcflirt -in ${srcin}/func-trust/${subj}_trust -cost mutualinfo -out ${srcout}/${subj}_trust_mcf
#fslmaths ${srcin}/func-trust/${subj}_trust ${srcout}/${subj}_trust_mcf

# calculate pairwise subtracted image (dM)
asl_file --data=${srcout}/${subj}_trust_mcf --ntis=5 --iaf=ct --pairs --diff --out=${srcout}/${subj}_trust_diff --mean=${srcout}/${subj}_trust_mean

# restrict roi for Superior Saggital Sinus
fslroi ${srcout}/${subj}_trust_mean ${srcout}/${subj}_trust_roi 22 20 0 20 0 1 0 1
fslroi ${srcout}/${subj}_trust_mean ${srcout}/${subj}_trust_roi_mean 22 20 0 20 0 1 0 -1

# get the threshold value for the 4 voxels in sagital sinus the 4th highest voxel
# percentile threshold set based on size of roi i.e. 4 voxels in 400 total voxels
mask_thresh=`fslstats ${srcout}/${subj}_trust_roi -p 99`
echo Threshold signal for saggital sinus is $mask_thresh

# make mask
fslmaths ${srcout}/${subj}_trust_roi -thr $mask_thresh -bin ${srcout}/${subj}_trust_mask
fslview_deprecated ${srcout}/${subj}_trust_roi_mean ${srcout}/${subj}_trust_mask -l Red

# extract mean timecourse
fslmeants -i ${srcout}/${subj}_trust_roi_mean -o ${srcout}/${subj}_trust_mean_tc.txt -m ${srcout}/${subj}_trust_mask 

# CALC T2b and Yv
${MATLABDIR}/bin/matlab -nosplash -nodesktop -r "addpath('$codedir'); run_TRUST_fit('$src','$subj'); exit;"
