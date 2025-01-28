#!/bin/bash
# Nicholas Blockley 2020
# Registration for hqBOLD/sqBOLD analysis

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

echo "Downsampling"

#fslcreatehd 64 64 9 1 3.4375 3.4375 7.5 3 0 0 0 16 ${srcout}/ref64

#applywarp --in=${srcout}/${subj}_gase_spin_echo_repeats --ref=${srcout}/ref64 --out=${srcout}/${subj}_gase_spin_echo_repeats --premat=$FSLDIR/etc/flirtsch/ID_MAT.mat --interp=trilinear
#applywarp --in=${srcout}/${subj}_gase_long_tau --ref=${srcout}/ref64 --out=${srcout}/${subj}_gase_long_tau --premat=$FSLDIR/etc/flirtsch/ID_MAT.mat --interp=trilinear
#applywarp --in=${srcout}/${subj}_gase_wholebrain --ref=${srcout}/ref64 --out=${srcout}/${subj}_gase_wholebrain --premat=$FSLDIR/etc/flirtsch/ID_MAT.mat --interp=trilinear
#applywarp --in=${srcout}/${subj}_gase --ref=${srcout}/ref64 --out=${srcout}/${subj}_gase --premat=$FSLDIR/etc/flirtsch/ID_MAT.mat --interp=trilinear


echo "Creating reference images for registration"

# Concatenate GASE datasets together - motion correct, time average and brain extract
fslmerge -t ${srcout}/${subj}_gase_merge ${srcout}/${subj}_gase ${srcout}/${subj}_gase_long_tau ${srcout}/${subj}_gase_spin_echo_repeats
mcflirt -in ${srcout}/${subj}_gase_merge -out ${srcout}/${subj}_gase_merge_mcf
fslroi ${srcout}/${subj}_gase_merge_mcf ${srcout}/${subj}_gase_merge_se 46 11
fslmaths ${srcout}/${subj}_gase_merge_se -Tmean ${srcout}/${subj}_gase_merge_ref
bet ${srcout}/${subj}_gase_merge_ref ${srcout}/${subj}_gase_merge_ref_bet -Z -f 0.3

# Invert contrast in GASE data
#fslmaths ${srcout}/${subj}_gase_merge_ref_bet -recip ${srcout}/${subj}_gase_merge_ref_bet_inv

# Wholebrain - brain extract
bet ${srcout}/${subj}_gase_wholebrain ${srcout}/${subj}_gase_wholebrain_ref_bet

# BOLD - motion correct, time average and brain extract
mcflirt -in ${srcin}/func-bold/${subj}_bold -out ${srcout}/${subj}_bold_mcf
fslmaths ${srcout}/${subj}_bold_mcf -Tmean ${srcout}/${subj}_bold_ref
bet ${srcout}/${subj}_bold_ref ${srcout}/${subj}_bold_ref_bet -Z

# Anatomical - brain extract
bet ${srcin}/anat/${subj}_T1w ${srcout}/${subj}_T1w_bet

echo "Registering GASE, BOLD and anatomical data"
# XXX MERGE -> BOLD -> WHOLEBRAIN -> ANAT -> MNI

# Register GASE_inv data to BOLD data 
#flirt -in ${srcout}/${subj}_gase_merge_ref_bet_inv -ref ${srcout}/${subj}_bold_ref_bet -out ${srcout}/${subj}_gase_merge_ref_bet_inv_regbold -schedule ${FSLDIR}/etc/flirtsch/ztransonly.sch -2D -cost mutualinfo -omat ${srcout}/merge2bold.mat

# Register GASE data to wholebrain
#flirt -in ${srcout}/${subj}_gase_merge_ref_bet -ref ${srcout}/${subj}_gase_wholebrain_ref_bet -out ${srcout}/${subj}_gase_merge_ref_bet_regwb -schedule ${FSLDIR}/etc/flirtsch/ztransonly.sch -2D -cost mutualinfo -omat ${srcout}/merge2wb.mat
flirt -in ${srcout}/${subj}_gase_merge_ref_bet -ref ${srcout}/${subj}_gase_wholebrain_ref_bet -out ${srcout}/${subj}_gase_merge_ref_bet_regwb -schedule ${FSLDIR}/etc/flirtsch/ztransonly.sch -2D -cost mutualinfo -omat ${srcout}/merge2wb.mat

# Register BOLD data to wholebrain
#flirt -in ${srcout}/${subj}_bold_ref_bet -ref ${srcout}/${subj}_gase_wholebrain_ref_bet -out ${srcout}/${subj}_bold_ref_bet_regwb -schedule ${FSLDIR}/etc/flirtsch/ztransonly.sch -2D -cost mutualinfo -omat ${srcout}/bold2wb.mat

# Register BOLD data to GASE
flirt -in ${srcout}/${subj}_bold_ref_bet -ref ${srcout}/${subj}_gase_merge_ref_bet -out ${srcout}/${subj}_bold_ref_bet_regmerge -2D -cost mutualinfo -omat ${srcout}/bold2merge.mat

# Register wholebrain data to anatomical data
flirt -in ${srcout}/${subj}_gase_wholebrain_ref_bet -ref ${srcout}/${subj}_T1w_bet -out ${srcout}/${subj}_gase_wholebrain_ref_bet_regT1 -dof 6 -omat ${srcout}/wb2anat.mat -cost mutualinfo

# Register anatomical data to standard space
flirt -in ${srcout}/${subj}_T1w_bet -ref ${FSLDIR}/data/standard/MNI152_T1_1mm_brain -out ${srcout}/${subj}_T1w_bet_regMNI -omat ${srcout}/anat2MNI.mat

echo "Applying transforms to GASE and BOLD data"

# Transform GASE data to wholebrain
#convert_xfm -omat ${srcout}/merge2wb.mat -concat ${srcout}/bold2wb.mat ${srcout}/merge2bold.mat
#applywarp --in=${srcout}/${subj}_gase_merge_mcf --ref=${srcout}/${subj}_gase_wholebrain_ref_bet --out=${srcout}/${subj}_gase_merge_mcf_regwb --premat=${srcout}/merge2wb.mat --interp=trilinear

# Transform BOLD data to wholebrain
#applywarp --in=${srcout}/${subj}_bold_mcf --ref=${srcout}/${subj}_gase_wholebrain_ref_bet --out=${srcout}/${subj}_bold_mcf_regwb --premat=${srcout}/bold2wb.mat --interp=trilinear

# Transform BOLD data to GASE data
applywarp --in=${srcout}/${subj}_bold_mcf --ref=${srcout}/${subj}_gase_merge_ref_bet --out=${srcout}/${subj}_bold_mcf_regmerge --premat=${srcout}/bold2merge.mat --interp=trilinear

echo "Apply smoothing FWHM equal to in-plane voxel dimensions"
#fwhm = 2.355 sigma
sigma=1
# fslmaths ${srcout}/${subj}_bold_mcf_regwb -s $sigma ${srcout}/${subj}_bold_mcf_regwb_sm
# fslmaths ${srcout}/${subj}_gase_merge_mcf_regwb -s $sigma ${srcout}/${subj}_gase_merge_mcf_regwb_sm
fslmaths ${srcout}/${subj}_bold_mcf_regmerge -s $sigma ${srcout}/${subj}_bold_mcf_regmerge_sm
fslmaths ${srcout}/${subj}_gase_merge_mcf -s $sigma ${srcout}/${subj}_gase_merge_mcf_sm


