#!/bin/bash
# Nicholas Blockley 2019
# Registers, segments and creates ROIs for hqBOLD analysis

if [ $# -lt 2 ]
then
	echo usage: run_regseg.sh source_directory subj_dir
	echo e.g. run_regseg.sh /data/hqBOLD/sourcedata/ sub-01
	exit
fi

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}

#Check if directories exist
if ! [ -d "${src}/derivatives/" ]; then
mkdir ${src}/derivatives/
fi

if ! [ -d "${srcout}" ]; then
mkdir ${srcout}
fi

if [ -f ${srcout}/${subj}_gase_spin_echo_repeats.nii.gz ]; then

	echo "Slice averaging already completed - skipping"
	
else

	#Slice average GASE data
	${codedir}/zaverage.sh ${srcin}/func-ase/${subj}_ase_spin_echo_repeats ${srcout}/${subj}_gase_spin_echo_repeats 
	${codedir}/zaverage.sh ${srcin}/func-ase/${subj}_ase_long_tau ${srcout}/${subj}_gase_long_tau
	${codedir}/zaverage.sh ${srcin}/func-ase/${subj}_ase_wholebrain ${srcout}/${subj}_gase_wholebrain
	${codedir}/zaverage.sh ${srcin}/func-ase/${subj}_ase ${srcout}/${subj}_gase

fi

echo "Creating reference images for registration"
mcflirt -in ${srcout}/${subj}_gase_spin_echo_repeats -out ${srcout}/${subj}_gase_spin_echo_repeats_mcf
fslmaths ${srcout}/${subj}_gase_spin_echo_repeats_mcf -Tmean ${srcout}/${subj}_gase_spin_echo_repeats_ref
bet ${srcout}/${subj}_gase_spin_echo_repeats_ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -Z

mcflirt -in ${srcout}/${subj}_gase_long_tau -out ${srcout}/${subj}_gase_long_tau_mcf
fslmaths ${srcout}/${subj}_gase_long_tau_mcf -Tmean ${srcout}/${subj}_gase_long_tau_ref
bet ${srcout}/${subj}_gase_long_tau_ref ${srcout}/${subj}_gase_long_tau_ref_bet -Z

bet ${srcout}/${subj}_gase_wholebrain ${srcout}/${subj}_gase_wholebrain_ref_bet

mcflirt -in ${srcout}/${subj}_gase -out ${srcout}/${subj}_gase_mcf
fslmaths ${srcout}/${subj}_gase_mcf -Tmean ${srcout}/${subj}_gase_ref
bet ${srcout}/${subj}_gase_ref ${srcout}/${subj}_gase_ref_bet -Z

mcflirt -in ${srcin}/func-bold/${subj}_bold -out ${srcout}/${subj}_bold_mcf
fslmaths ${srcout}/${subj}_bold_mcf -Tmean ${srcout}/${subj}_bold_ref
bet ${srcout}/${subj}_bold_ref ${srcout}/${subj}_bold_ref_bet -Z

fslroi ${srcin}/func-asl/${subj}_asl ${srcout}/${subj}_asl_calib 0 1
fslroi ${srcin}/func-asl/${subj}_asl ${srcout}/${subj}_asl_tagctl 1 -1
bet ${srcout}/${subj}_asl_calib ${srcout}/${subj}_asl_calib_bet
mcflirt -in ${srcout}/${subj}_asl_tagctl -out ${srcout}/${subj}_asl_tagctl_mcf -r ${srcout}/${subj}_asl_calib

bet ${srcin}/anat/${subj}_T1w ${srcout}/${subj}_T1w_bet

fslmerge -t ${srcout}/${subj}_gase_merge ${srcout}/${subj}_gase ${srcout}/${subj}_gase_long_tau ${srcout}/${subj}_gase_spin_echo_repeats
mcflirt -in ${srcout}/${subj}_gase_merge -out ${srcout}/${subj}_gase_merge_mcf
fslmaths ${srcout}/${subj}_gase_merge_mcf -Tmean ${srcout}/${subj}_gase_merge_ref
bet ${srcout}/${subj}_gase_merge_ref ${srcout}/${subj}_gase_merge_ref_bet -Z

echo "Registering GASE, BOLD and ASL data"

#Register long tau data to wholebrain data
flirt -in ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -ref ${srcout}/${subj}_gase_wholebrain_ref_bet -out ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_regwb -schedule ${FSLDIR}/etc/flirtsch/ztransonly.sch -2D -cost mutualinfo -omat ${srcout}/se2wb.mat
flirt -in ${srcout}/${subj}_gase_long_tau_ref_bet -ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -out ${srcout}/${subj}_gase_long_tau_ref_bet_regse -2D -cost mutualinfo -omat ${srcout}/ltau2se.mat

#Register ASE data to wholebrain data
flirt -in ${srcout}/${subj}_gase_ref_bet -ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -out ${srcout}/${subj}_gase_ref_bet_regse -2D -cost mutualinfo -omat ${srcout}/ase2se.mat

#Register ASE merge data to wholebrain data
flirt -in ${srcout}/${subj}_gase_merge_ref_bet -ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -out ${srcout}/${subj}_gase_merge_ref_bet_regse -2D -cost mutualinfo -omat ${srcout}/asemerge2se.mat

#Register BOLD data to wholebrain data
flirt -in ${srcout}/${subj}_bold_ref_bet -ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -out ${srcout}/${subj}_bold_ref_bet_regse -2D -cost mutualinfo -omat ${srcout}/bold2se.mat

#Register ASL data to wholebrain data
flirt -in ${srcout}/${subj}_asl_calib_bet -ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -out ${srcout}/${subj}_asl_calib_bet_regse -dof 6 -searchcost mutualinfo -omat ${srcout}/asl2se.mat

#Register wholebrain data to anatomical data
flirt -in ${srcout}/${subj}_gase_wholebrain_ref_bet -ref ${srcout}/${subj}_T1w_bet -out ${srcout}/${subj}_gase_wholebrain_ref_bet_regT1 -dof 6 -omat ${srcout}/wb2anat.mat -cost mutualinfo

#Register anatomical data to standard space
flirt -in ${srcout}/${subj}_T1w_bet -ref ${FSLDIR}/data/standard/MNI152_T1_1mm_brain -out ${srcout}/${subj}_T1w_bet_regMNI -omat ${srcout}/anat2MNI.mat

echo "Applying transforms to GASE, BOLD and ASL data"

#Transform BOLD data to long tau space
convert_xfm -omat ${srcout}/se2ltau.mat -inverse ${srcout}/ltau2se.mat
convert_xfm -omat ${srcout}/bold2ltau.mat -concat ${srcout}/se2ltau.mat ${srcout}/bold2se.mat

convert_xfm -omat ${srcout}/se2asemerge.mat -inverse ${srcout}/asemerge2se.mat
convert_xfm -omat ${srcout}/bold2asemerge.mat -concat ${srcout}/se2asemerge.mat ${srcout}/bold2se.mat

applywarp --in=${srcout}/${subj}_bold_mcf --ref=${srcout}/${subj}_gase_long_tau_ref_bet --out=${srcout}/${subj}_bold_mcf_reg --premat=${srcout}/bold2asemerge.mat --interp=trilinear

#Transform ASL data to long tau space
convert_xfm -omat ${srcout}/se2asl.mat -inverse ${srcout}/asl2se.mat
convert_xfm -omat ${srcout}/asl2ltau.mat -concat ${srcout}/se2ltau.mat ${srcout}/asl2se.mat
convert_xfm -omat ${srcout}/ltau2asl.mat -inverse ${srcout}/asl2ltau.mat

#applywarp --in=${srcout}/${subj}_asl_calib --ref=${srcout}/${subj}_gase_long_tau_ref_bet --out=${srcout}/${subj}_asl_calib_reg --premat=${srcout}/asl2ltau.mat --interp=trilinear
#applywarp --in=${srcout}/${subj}_asl_tagctl --ref=${srcout}/${subj}_gase_long_tau_ref_bet --out=${srcout}/${subj}_asl_tagctl_reg --premat=${srcout}/asl2ltau.mat --interp=trilinear

#Transform ASE data to long tau space
convert_xfm -omat ${srcout}/ase2ltau.mat -concat ${srcout}/se2ltau.mat ${srcout}/ase2se.mat
applywarp --in=${srcout}/${subj}_gase_mcf --ref=${srcout}/${subj}_gase_long_tau_ref_bet --out=${srcout}/${subj}_gase_mcf_reg --premat=${srcout}/ase2ltau.mat --interp=trilinear

#Transform ASE merge data to long tau space
convert_xfm -omat ${srcout}/asemerge2ltau.mat -concat ${srcout}/se2ltau.mat ${srcout}/asemerge2se.mat
applywarp --in=${srcout}/${subj}_gase_merge_mcf --ref=${srcout}/${subj}_gase_long_tau_ref_bet --out=${srcout}/${subj}_gase_merge_mcf_reg --premat=${srcout}/asemerge2ltau.mat --interp=trilinear

echo "Apply smoothing FWHM equal to in-plane voxel dimensions"
#fwhm = 2.355 sigma
sigma=1
fslmaths ${srcout}/${subj}_gase_long_tau_mcf -s $sigma ${srcout}/${subj}_gase_long_tau_mcf_sm
fslmaths ${srcout}/${subj}_bold_mcf_reg -s $sigma ${srcout}/${subj}_bold_mcf_reg_sm
fslmaths ${srcout}/${subj}_gase_mcf_reg -s $sigma ${srcout}/${subj}_gase_mcf_reg_sm
fslmaths ${srcout}/${subj}_gase_merge_mcf_reg -s $sigma ${srcout}/${subj}_gase_merge_mcf_reg_sm
fslmaths ${srcout}/${subj}_gase_merge_mcf -s $sigma ${srcout}/${subj}_gase_merge_mcf_sm

echo "Segment SE and transform to GASE space"

if [ -f ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_0.nii.gz ]; then

	echo "Segmentation already completed - skipping"

else

	#Segment spin echo repeats data
	fslcreatehd 192 192 18 1 1.145833 1.145833 3.75 1 0 0 0 16 ${srcout}/up
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet --ref=${srcout}/up --out=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up --premat=${FSLDIR}/etc/flirtsch/ident.mat --interp=trilinear --super --superlevel=4
	fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -g -B -b -o ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up

	#Transform PVE maps to GASE space
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_0 --ref=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet --out=${srcout}/${subj}_gase_csf --premat=${srcout}/se2ltau.mat --interp=trilinear --super --superlevel=4
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_1 --ref=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet --out=${srcout}/${subj}_gase_gm --premat=${srcout}/se2ltau.mat --interp=trilinear --super --superlevel=4
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_2 --ref=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet --out=${srcout}/${subj}_gase_wm --premat=${srcout}/se2ltau.mat --interp=trilinear --super --superlevel=4

	#Transform PVE maps to ASL space
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_0 --ref=${srcout}/${subj}_asl_calib --out=${srcout}/${subj}_gase_csf_regasl --premat=${srcout}/se2asl.mat --interp=trilinear --super --superlevel=4
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_1 --ref=${srcout}/${subj}_asl_calib --out=${srcout}/${subj}_gase_gm_regasl --premat=${srcout}/se2asl.mat --interp=trilinear --super --superlevel=4
	applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats_ref_bet_up_pve_2 --ref=${srcout}/${subj}_asl_calib --out=${srcout}/${subj}_gase_wm_regasl --premat=${srcout}/se2asl.mat --interp=trilinear --super --superlevel=4

	#Transform MNI atlas to GASE space
	convert_xfm -omat ${srcout}/ltau2wb.mat -concat ${srcout}/se2wb.mat ${srcout}/ltau2se.mat
	convert_xfm -omat ${srcout}/wb2MNI.mat -concat ${srcout}/anat2MNI.mat ${srcout}/wb2anat.mat
	convert_xfm -omat ${srcout}/ltau2MNI.mat -concat ${srcout}/wb2MNI.mat ${srcout}/ltau2wb.mat 
	convert_xfm -omat ${srcout}/MNI2ltau.mat -inverse ${srcout}/ltau2MNI.mat
	flirt -in ${FSLDIR}/data/atlases/MNI/MNI-maxprob-thr0-1mm -ref ${srcout}/${subj}_gase_spin_echo_repeats_ref_bet -out ${srcout}/${subj}_MNI-maxprob-thr0 -init ${srcout}/MNI2ltau.mat -interp nearestneighbour -applyxfm

	#Transform MNI atlas to ASL space
	convert_xfm -omat ${srcout}/asl2wb.mat -concat ${srcout}/se2wb.mat ${srcout}/asl2se.mat
	convert_xfm -omat ${srcout}/asl2MNI.mat -concat ${srcout}/wb2MNI.mat ${srcout}/asl2wb.mat 
	convert_xfm -omat ${srcout}/MNI2asl.mat -inverse ${srcout}/asl2MNI.mat
	flirt -in ${FSLDIR}/data/atlases/MNI/MNI-maxprob-thr0-1mm -ref ${srcout}/${subj}_asl_calib_bet -out ${srcout}/${subj}_MNI-maxprob-thr0_regasl -init ${srcout}/MNI2asl.mat -interp nearestneighbour -applyxfm

fi

#convert_xfm -omat ${srcout}/MNI2anat.mat -inverse ${srcout}/anat2MNI.mat
#convert_xfm -omat ${srcout}/anat2wb.mat -inverse ${srcout}/wb2anat.mat
#convert_xfm -omat ${srcout}/MNI2wb.mat -concat ${srcout}/anat2wb.mat ${srcout}/MNI2anat.mat
#convert_xfm -omat ${srcout}/wb2se.mat -inverse ${srcout}/se2wb.mat

