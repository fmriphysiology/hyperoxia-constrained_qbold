#!/bin/bash
# Nicholas Blockley 2019
# Averages the sub-slices acquired using GESEPI
# Bash version of script by Alan Stone

if [ $# -lt 2 ]
then
	echo usage: zaverage.sh ase_in_filename ase_out_filename
	echo e.g. zaverage.sh images_004_npbep2dasestdavic1001.nii.gz gase.nii.gz
	echo - note that this is set to average over 4 sub-slices
	exit
fi

filedir=`dirname $2`
tempdir=${filedir}/zaverage_tmp/
mkdir ${tempdir}

## Calculate slice numbers
# number of slices
nz=`fslval $1 dim3`
# slice number beginning at 0
nz_zerod=`expr $nz - 1`
# new number of slices after averaging
new_nz=`expr $nz / 4`
# new_slices after averaging
new_nz_zerod=`expr $new_nz - 1`

## Split GESEPI image into seperate slices
fslslice $1 ${tempdir}/temp

# slice counters for loop
counter=0
count=`printf "%04d"  0`
count_za=`printf "%04d"  0`
count_zb=`printf "%04d"  1`
count_zc=`printf "%04d"  2`
count_zd=`printf "%04d"  3`

# Mean over blocks of 4 slices
printf "Averaging GESEPI sub-slices"

while [ $counter -le $new_nz_zerod ]
do
    #Averaging sub-slices in slab $counter

    ## Change the slice thickness (dz) in first slice ($count) header and copy to others
    fslhd -x ${tempdir}/temp_slice_$count_za.nii.gz > ${tempdir}/tmp_hdr_$count.txt
    sed "s/dz =.*/dz = \'7.5\'/" ${tempdir}/tmp_hdr_$count.txt > ${tempdir}/hdr_$count.txt
    fslcreatehd ${tempdir}/hdr_$count.txt ${tempdir}/temp_slice_$count_za.nii.gz
    fslcreatehd ${tempdir}/hdr_$count.txt ${tempdir}/temp_slice_$count_zb.nii.gz
    fslcreatehd ${tempdir}/hdr_$count.txt ${tempdir}/temp_slice_$count_zc.nii.gz
    fslcreatehd ${tempdir}/hdr_$count.txt ${tempdir}/temp_slice_$count_zd.nii.gz

    fslmaths ${tempdir}/temp_slice_$count_za.nii.gz \
        -add ${tempdir}/temp_slice_$count_zb.nii.gz \
        -add ${tempdir}/temp_slice_$count_zc.nii.gz \
        -add ${tempdir}/temp_slice_$count_zd.nii.gz \
        -div 4 \
        ${tempdir}/temp_zmean_slice_$count.nii.gz

	((counter++))
    count=`echo $count | awk '{ printf("%04d\n", $1 + 1) }'`
    count_za=`echo $count_za | awk '{ printf("%04d\n", $1 + 4) }'`
    count_zb=`echo $count_zb | awk '{ printf("%04d\n", $1 + 4) }'`
    count_zc=`echo $count_zc | awk '{ printf("%04d\n", $1 + 4) }'`
    count_zd=`echo $count_zd | awk '{ printf("%04d\n", $1 + 4) }'`

	printf .

done

fslmerge -z $2 ${tempdir}/temp_zmean_slice_*

# check to make sure slice thickness is 7.5 ... used because there is a bug for single tau-volumes (used for reg purposes)
fslhd -x $2 > $tempdir/tmp_hdr_main.txt
sed "s/dz =.*/dz = \'7.5\'/" $tempdir/tmp_hdr_main.txt > $tempdir/hdr_main.txt
fslcreatehd $tempdir/hdr_main.txt $2

rm -r $tempdir

echo done.
