#!/bin/bash

#
# SBSN framework - Preprocessing
# June 2022
#
# Preparation of functional spine data
#
# Requirements: FSL, Spinal Cord Toolbox 5.5
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

# this is inneficient and can be changed. It is the same ROI that is used for all the funcs of each subject
# dont have to loop around for each func and only need to in the first one to do this

DIREC2="/mnt/d/SBSN/Data/Spine/" 
# bAreas=("L_SM" "R_SM" "L_CEB" "R_CEB")
bAreas=("Right_M1" "Left_M1" "Right_SMA" "Left_SMA" "Right_PMv" "Left_PMv")

# Right_M1    1
# Left_M1     2
# Right_S1    3
# Left_S1     4
# Right_SMA   5
# Left_SMA    6
# Right_preSMA    7
# Left_preSMA 8
# Right_PMd   9
# Left_PMd    10
# Right_PMv   11
# Left_PMv    12

# HMAT_Left_M1.nii
# HMAT_Left_PMd.nii
# HMAT_Left_PMv.nii
# HMAT_Left_SMA.nii
# HMAT_Left_preSMA.nii
# HMAT_Left_S1.nii
# HMAT_Right_M1.nii
# HMAT_Right_PMd.nii
# HMAT_Right_PMv.nii
# HMAT_Right_SMA.nii
# HMAT_Right_preSMA.nii
# HMAT_Right_S1.nii

# this is the radius in mm of the sphere of ROI
RADIUS=2

# For each subject
for s in "${sub[@]}"; do
    cd $DIREC$s"/func/"

    #######################################################
    # Step 1: Create the ROIs once per subject (outside func loop)
    #######################################################
    tput setaf 2; echo "Processing ROI for " $DIREC$s"/func/"
    tput sgr0;

    # for ii in 0 1 2 3; do
    for ii in "${!bAreas[@]}"; do

        #1 left sensory
        #2 right sensory
        #3 left cerebellum
        #4 right cerebllum

        # echo $DIREC"template/ATLAS/greiciusLevels/"$((ii + 1))".nii.gz"
        echo $DIREC"template/HMAT_website/HMAT_"${bAreas[$ii]}".nii"
        echo ${bAreas[$ii]}
        echo $RADIUS

        # 1. Apply mask to the Z-stat image
        # fslmaths $DIREC$s"/func/level_two_force_FLOB1234.gfeat/cope1.feat/thresh_zstat1.nii.gz" -mas $DIREC"template/ATLAS/greiciusLevels/"$((ii + 1))".nii" thresh_zstat_masked
        fslmaths $DIREC$s"/func/level_two_force_FLOB1234.gfeat/cope1.feat/thresh_zstat1.nii.gz" -mas $DIREC"template/HMAT_website/HMAT_"${bAreas[$ii]}".nii" thresh_zstat_masked

        # 2. Check if masked image contains any non-zero voxels
        nz=$(fslstats thresh_zstat_masked.nii.gz -V | awk '{print $1}')
        echo $nz
        if [ "$nz" -eq 0 ]; then
            echo "  No non-zero voxels in masked image for $s. Skipping."
            rm -f thresh_zstat_masked.nii.gz
            continue
        fi

        # 3. Get max voxel coordinates (integer voxel space)
        MAX_VOXEL=$(fslstats thresh_zstat_masked.nii.gz -x)
        echo $MAX_VOXEL
        if [ -z "$MAX_VOXEL" ]; then
            echo "  Could not find max voxel for $s. Skipping."
            rm -f thresh_zstat_masked.nii.gz
            continue
        fi

        #echo $MAX_VOXEL | awk '{printf "%d 1 %d 1 %d 1 0 1", $1, $2, $3}'
        # this creates the point
        fslmaths $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz -mul 0 -add 1 -roi $(echo $MAX_VOXEL | awk '{printf "%d 1 %d 1 %d 1 0 1", $1, $2, $3}') point_voxel -odt float

        # 5. Create spherical ROI around that voxel
        fslmaths point_voxel.nii.gz -kernel sphere $RADIUS -fmean point_sphere -odt float

        # binarize the sphere
        fslmaths point_sphere.nii.gz -bin "point_sphere_MNI_"${bAreas[$ii]}$RADIUS

        # 6. Cleanup
        rm -f thresh_zstat_masked.nii.gz point_voxel.nii.gz point_sphere.nii.gz
        
        # now Ill have to apply the transofrmation to subject space
        flirt -in "point_sphere_MNI_"${bAreas[$ii]}$RADIUS".nii.gz" -ref func1/fmri_brain_moco_mean.nii.gz -out "point_sphere_subject_"${bAreas[$ii]}$RADIUS".nii.gz" -init func1/template2anat.mat -applyxfm -interp nearestneighbour

    done

    #######################################################
    # Step 2: Apply the ROI to each func run
    #######################################################
    for d in "${myFunc[@]}"; do

        # Will print */ if no directories are available
        cd $DIREC$s"/func/func"$d"/"

        tput setaf 2; echo "Extracting signal for func $d of subject $s"
        tput sgr0;

        # for ii in 0 1 2 3; do
        for ii in "${!bAreas[@]}"; do
            # now copy over to the spine folder
            cp "../point_sphere_subject_"${bAreas[$ii]}$RADIUS".nii.gz" "point_sphere_subject_"${bAreas[$ii]}$RADIUS".nii.gz"
            cp "../point_sphere_MNI_"${bAreas[$ii]}$RADIUS".nii.gz" "point_sphere_MNI_"${bAreas[$ii]}$RADIUS".nii.gz"

            # get the data we want from the 
            fslmeants -i fmri_brain_moco_denoised_smooth.nii.gz -o ${bAreas[$ii]}$RADIUS"_regressor.txt" -m "point_sphere_subject_"${bAreas[$ii]}$RADIUS".nii.gz" -v

            # now copy over to the spine folder
            cp ${bAreas[$ii]}$RADIUS"_regressor.txt" $DIREC2$s"/func/func"$d"/"${bAreas[$ii]}$RADIUS"_regressor.txt"

        done

    done


    #######################################################
    # Step 3: Remove files from the func folder
    #######################################################
    cd $DIREC$s"/func/"
    for ii in 0 1 2 3; do
        # now remove
        rm -f "point_sphere_subject_"${bAreas[$ii]}$RADIUS".nii.gz" "point_sphere_MNI_"${bAreas[$ii]}$RADIUS".nii.gz"
    done

    tput setaf 2; echo "Done!" 
        tput sgr0;  

done

echo
echo "${sub[@]}"
echo "${myFunc[@]}"
echo

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