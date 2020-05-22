#!/bin/bash
# Nicholas Blockley 2020
# Segmentation for hqBOLD/sqBOLD analysis

if [ $# -lt 2 ]
then
	echo usage: run_reg.sh source_directory subj_dir
	echo e.g. run_reg.sh /data/hqBOLD/sourcedata/ sub-01
	exit
fi

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}

echo "Segment anatomical and transform to wholebrain space"

if [ -f ${srcout}/${subj}_T1w_bet_pve_000.nii.gz ]; then

	echo "Segmentation already completed - skipping"

else

	# Segment anatomical data
	fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -g -B -b -o ${srcout}/${subj}_T1w_bet ${srcout}/${subj}_T1w_bet
	
	# Transform PVE maps to wholebrain
	convert_xfm -omat ${srcout}/anat2wb.mat -inverse ${srcout}/wb2anat.mat 
	applywarp --in=${srcout}/${subj}_T1w_bet_pve_0 --ref=${srcout}/${subj}_gase_wholebrain_ref_bet --out=${srcout}/${subj}_gase_wholebrain_csf --premat=${srcout}/anat2wb.mat --interp=trilinear --super --superlevel=4
	applywarp --in=${srcout}/${subj}_T1w_bet_pve_1 --ref=${srcout}/${subj}_gase_wholebrain_ref_bet --out=${srcout}/${subj}_gase_wholebrain_gm --premat=${srcout}/anat2wb.mat --interp=trilinear --super --superlevel=4
	applywarp --in=${srcout}/${subj}_T1w_bet_pve_2 --ref=${srcout}/${subj}_gase_wholebrain_ref_bet --out=${srcout}/${subj}_gase_wholebrain_wm --premat=${srcout}/anat2wb.mat --interp=trilinear --super --superlevel=4
	
	# Transform MNI atlas to wholebrain space
	convert_xfm -omat ${srcout}/MNI2anat.mat -inverse ${srcout}/anat2MNI.mat 
	convert_xfm -omat ${srcout}/MNI2wb.mat -concat ${srcout}/anat2wb.mat ${srcout}/MNI2anat.mat 
	#flirt -in ${FSLDIR}/data/atlases/MNI/MNI-maxprob-thr0-1mm -ref ${srcout}/${subj}_gase_wholebrain_ref_bet -out ${srcout}/${subj}_MNI-maxprob-thr0 -init ${srcout}/MNI2wb.mat -interp nearestneighbour -applyxfm	
	convert_xfm -omat ${srcout}/wb2merge.mat -inverse ${srcout}/merge2wb.mat
	convert_xfm -omat ${srcout}/MNI2merge.mat -concat ${srcout}/wb2merge.mat ${srcout}/MNI2wb.mat
	flirt -in ${FSLDIR}/data/atlases/MNI/MNI-maxprob-thr0-1mm -ref ${srcout}/${subj}_gase_merge_ref_bet -out ${srcout}/${subj}_MNI-maxprob-thr0 -init ${srcout}/MNI2merge.mat -interp nearestneighbour -applyxfm	
	
	# Segment GASE merge data
	#fslmaths ${srcout}/${subj}_gase_merge_mcf_regwb -Tmean ${srcout}/${subj}_gase_merge_mcf_regwb_avg
	#bet ${srcout}/${subj}_gase_merge_mcf_regwb_avg ${srcout}/${subj}_gase_merge_mcf_regwb_bet -f 0.3
	fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -g -B -b -o ${srcout}/${subj}_gase_merge_ref_bet ${srcout}/${subj}_gase_merge_ref_bet 
	
	# Rename PVE maps
	mv ${srcout}/${subj}_gase_merge_ref_bet_pve_0.nii.gz ${srcout}/${subj}_gase_merge_csf.nii.gz
	mv ${srcout}/${subj}_gase_merge_ref_bet_pve_1.nii.gz ${srcout}/${subj}_gase_merge_gm.nii.gz
	mv ${srcout}/${subj}_gase_merge_ref_bet_pve_2.nii.gz ${srcout}/${subj}_gase_merge_wm.nii.gz

fi