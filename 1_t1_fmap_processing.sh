#!/bin/bash
#
# SBSN framework - Preprocessing
# June 2022
#
# This script performs automatic SC segmentation, vertebrae labeling and normalization to the PAM50 template
#
# Requirements: Spinal Cord Toolbox 5.5
#
#
####################################
#set -x
# Immediately exit if error
#set -e -o pipefail

# Exit if user presses CTRL+C (Linux) or CMD+C (OSX)
trap "echo Caught Keyboard Interrupt within script. Exiting now.; exit" INT

# Save script path
#PATH_SCRIPT=$PWD

# get starting time:
start=`date +%s`
####################################

# load in function that has paths to subject
. /mnt/d/SBSN/Processing_Brain/path_to_subjects.sh 

# For each subject
for s in "${sub[@]}"; do
	cd $DIREC$s"/anat/"

	tput setaf 2; echo "crop image "$s
        tput sgr0;
   
    # crop out the spine
    sct_crop_image -i t1.nii.gz -o t1_crop.nii.gz -g 1
 
    # skullstripping
    bet t1_crop.nii.gz t1_brain.nii.gz -f 0.3

    # register the T1 to the MNI template. Later we will apply a transform to put it in the subjects native space
    flirt -in t1_brain.nii.gz -ref ../../template/MNI152_T1_2mm_brain.nii.gz -omat t12template.mat -out t1_MNI.nii.gz -v

    # to register the brain to the template instead of the entitre skull
    flirt -in t1_crop.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out t1_skull_MNI.nii.gz -init t12template.mat -applyxfm -v

    # this will register EPI to t1
    #epi_reg --epi=func/func1/fmri_brain_moco_mean.nii.gz --t1=anat/t1_crop.nii.gz --t1brain=anat/t1_brain.nii.gz --out=test_epi.nii.gz -v

    #FAST algorithm
    #fast t1_brain.nii.gz

    # renaming the segmentations
    #mv t1_brain_pve_0.nii.gz t1_brain_CSF.nii.gz
    #mv t1_brain_pve_1.nii.gz t1_brain_GM.nii.gz
    #mv t1_brain_pve_2.nii.gz t1_brain_WM.nii.gz

	tput setaf 2; echo "T1 Done!"
        tput sgr0;

done

####################################
# Display useful info for the log
end=`date +%s`
runtime=$((end-start))
echo
echo "~~~"
echo "SCT version: `sct_version`"
echo "Ran on:      `uname -nsr`"
echo "Duration:    $(($runtime / 3600))hrs $((($runtime / 60) % 60))min $(($runtime % 60))sec"
echo "~~~"
####################################
