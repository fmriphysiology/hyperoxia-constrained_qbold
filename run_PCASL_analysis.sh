#!/bin/bash


if [ $# -lt 2 ]
then
	echo usage: run_PCASL_analysis.sh source_directory subj_dir
	echo e.g. run_PCASL_analysis.sh /data/hc-qBOLD/sourcedata/ sub-01
	exit
fi

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1
subj=$2

srcin=${src}/${subj}
srcout=${src}/derivatives/${subj}

# separate calib and tagctl data
#fslroi ${srcin}/func-asl/${subj}_asl ${srcout}/${subj}_asl_calib 0 1
#fslroi ${srcin}/func-asl/${subj}_asl ${srcout}/${subj}_asl_tagctl 1 -1

# motion correct unsubtracted tag/control images (motion correction in BASIL)
#mcflirt -in ${srcout}/${subj}_asl_tagctl -cost mutualinfo -out ${srcout}/${subj}_trust_mcf

#run BASIL
# oxford_asl  -i "${srcout}/${subj}_asl_tagctl.nii.gz" --ibf=rpt --iaf=tc \
# 		--tis 2.05,2.30,2.55,2.80,3.05,3.30 --bolus 1.80 --casl --slicedt 0.00000 \
# 		-c "${srcout}/${subj}_asl_calib.nii.gz" --tr 10.00 --cgain 1.00 --cmethod voxel \
# 		--t1 1.30 --bat 1.30 --t1b 1.65 --alpha 0.85 --fixbolus --spatial --mc -o "${srcout}"
oxford_asl  -i "${srcout}/${subj}_asl_tagctl_reg.nii.gz" --ibf=rpt --iaf=tc \
		--tis 2.05,2.30,2.55,2.80,3.05,3.30 --bolus 1.80 --casl --slicedt 0.00000 \
		-c "${srcout}/${subj}_asl_calib_reg.nii.gz" --tr 10.00 --cgain 1.00 --cmethod voxel \
		--t1 1.30 --bat 1.30 --t1b 1.65 --alpha 0.85 --fixbolus --spatial --mc -o "${srcout}"
			
# transform into long tau space 
#applywarp --in=${srcout}/native_space/perfusion_calib --ref=${srcout}/${subj}_gase_long_tau_ref_bet \
#		--out=${srcout}/${subj}_perfusion_reg --premat=${srcout}/asl2ltau.mat --interp=trilinear
		


