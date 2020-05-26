#!/bin/bash
# Nicholas Blockley 2019
# Run hc-qBOLD analysis

PVthresh=0.5

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1

#Process registration and segmentation in parallel if GNU parallel is installed
#parallel --progress $codedir/run_reg.sh $src {} ::: sub-01 sub-02 sub-03 sub-04 sub-05 sub-06 sub-07 sub-08 sub-09 sub-10
#parallel --progress $codedir/run_seg.sh $src {} ::: sub-01 sub-02 sub-03 sub-04 sub-05 sub-06 sub-07 sub-08 sub-09 sub-10

for n in {1..10}
do

	subj_id=sub-`printf "%02d\n" $n`
	echo $subj_id
	${codedir}/run_reg.sh ${src} $subj_id
	${codedir}/run_seg.sh ${src} $subj_id
	${MATLABDIR}/bin/matlab -nosplash -nodesktop -r "addpath('${codedir}'); run_hqBOLD_analysis('$src','$subj_id'); exit"
	${MATLABDIR}/bin/matlab -nosplash -nodesktop -r "addpath('${codedir}'); run_sqBOLD_analysis('$src','$subj_id'); exit"
	${codedir}/run_TRUST_analysis.sh ${src} $subj_id
	${codedir}/make_ROI.sh ${src} ${subj_id} ${PVthresh}

done

