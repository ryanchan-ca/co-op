#!/bin/bash
# Wayne July 3, 2020
FSLDIR=/usr/local/fsl5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:/usr/local/MATLAB/R2014a/bin:${PATH}
export FSLDIR PATH
export FREESURFER_HOME=/usr/local/freesurfer6.0
source $FREESURFER_HOME/SetUpFreeSurfer.sh


if [ -z $1 ]; then
    echo "please give the command you want to run."
    echo "1 -- create base for each subject"
    echo "2 -- edit base"
    echo "3 -- processing all timepoints"
    echo "4 -- edit all timepoints"
    echo "5 -- lgi measure"
    echo "6 -- hippocampus subfield segmentation and more"
    echo "7 -- qcache"
    echo "8 -- other commands"
    exit
fi

project=HOTEL
export HPCDIR=/mnt/hpcdata				                # (1) HPCDIR reference

export SUBJECTS_DIR=${HPCDIR}/${project}/fs_long_hotel 	# (2) INPUT FOLDER (UNPROCESSED SCANS) HERE


variation=$1

cd ${SUBJECTS_DIR}

if [ $variation = 2 ]; then

    echo "edit the template (base)"

    while read -u 4 line
    do
        subject=`echo ${line} | awk '{print $1}'`
        echo "subject: ${subject}"
#        tkmedit ${subject} wm.mgz -aux brainmask.mgz -surfs
    freeview -v ${subject}/mri/brainmask.mgz  ${subject}/mri/wm.mgz:colormap=heat:opacity=0.4 -f ${subject}/surf/lh.white:edgecolor=blue ${subject}/surf/lh.pial:edgecolor=red ${subject}/surf/rh.white:edgecolor=blue ${subject}/surf/rh.pial:edgecolor=red

        while true; do
        echo "Did you edit WM or pial surface? (Y/N)"
        read yn # < /dev/tty

        if [ "$yn" = "y" ]; then
            ${FSLDIR}/bin/fsl_sub -N B${subject} -l ${SUBJECTS_DIR}/logs ${FREESURFER_HOME}/bin/recon-all -base ${subject} -autorecon2-wm -autorecon3
#            echo "you did it!" 
            break
        else
            echo "no edit"
            break
        fi
        done
    done 4< "scans.txt"
    

elif [ $variation = 3 ]; then
    echo "longitudinally process all timepoints"

    while read line
    do
        subject=`echo ${line} | awk '{print $1}'`
        num=`echo ${line} | wc -w`
        num=`expr ${num} - 1`
        echo "subject: ${subject} with ${num} scans"
        scanlist=`echo ${line} | cut -d' ' -f2-`

        for scan in ${scanlist} ; do
            ${FSLDIR}/bin/fsl_sub  -N B${scan} -l ${SUBJECTS_DIR}/logs ${FREESURFER_HOME}/bin/recon-all -long ${scan} ${subject} -all 
            sleep 1
        done

    done < "scans.txt"

elif [ $variation = 4 ]; then
    echo "edit all timepoints"

    while read -u 4 line
    do
        subject=`echo ${line} | awk '{print $1}'`
        num=`echo ${line} | wc -w`
        num=`expr ${num} - 1`
        echo "subject: ${subject} with ${num} scans"
        scanlist=`echo ${line} | cut -d' ' -f2-`

        for scan in ${scanlist} ; do
#            tkmedit ${scan}.long.${subject} wm.mgz -aux brainmask.mgz -surfs
         freeview -v  ${scan}.long.${subject}/mri/brainmask.mgz   ${scan}.long.${subject}/mri/wm.mgz:colormap=heat:opacity=0.4 ${scan}.long.${subject}/mri/aseg.presurf.mgz:colormap=lut:opacity=0.2  -f  ${scan}.long.${subject}/surf/lh.white:edgecolor=blue  ${scan}.long.${subject}/surf/lh.pial:edgecolor=red  ${scan}.long.${subject}/surf/rh.white:edgecolor=blue  ${scan}.long.${subject}/surf/rh.pial:edgecolor=red

            while true; do
            echo "Did you edit WM or pial surface? (Y/N)"
            read yn # < /dev/tty

            if [ "$yn" = "y" ]; then
                ${FSLDIR}/bin/fsl_sub  -N B${subject} -l ${SUBJECTS_DIR}/logs ${FREESURFER_HOME}/bin/recon-all -long ${scan} ${subject} -autorecon2-wm -autorecon3
#                echo "you did it!" 
                 break
            else
                echo "no edit"
                break
            fi
            done

        done

    done 4< "scans.txt"

fi




#END