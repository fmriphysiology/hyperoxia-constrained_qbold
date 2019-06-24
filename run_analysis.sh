#!/bin/bash
# Nicholas Blockley 2019
# Run hc-qBOLD analysis

codedir=`dirname $0` #assume that other scripts are in the same directory
src=$1

for n in {5..10}
do

	subj_id=sub-`printf "%02d\n" $n`
	echo $subj_id
	${codedir}/run_regseg.sh ${src} $subj_id
	${MATLABDIR}/bin/matlab -nosplash -nodesktop -r "addpath('${codedir}'); run_hcqBOLD_analysis('$src','$subj_id'); exit"
	${MATLABDIR}/bin/matlab -nosplash -nodesktop -r "addpath('${codedir}'); run_sqBOLD_analysis('$src','$subj_id'); exit"
	#${codedir}/run_TRUST_analysis.sh ${src} $subj_id
	${codedir}/run_PCASL_analysis.sh ${src} $subj_id
	

done

