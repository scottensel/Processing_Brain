#!/bin/bash
#
# SBSN framework - Preprocessing
# June 2022
#
# Preparation second level for atlas comparison

# This is just to transform the zstat into the MNI atlas

# load in function that has paths to subject
. /mnt/d/SBSN/Processing_Brain/path_to_subjects.sh  


for s in "${sub[@]}"; do

    cd $DIREC$s"/func/"

    for d in level_two*/ ; do
        echo "$d"
        cd "$d"
        
        if [ -d cope1.feat ]; then 
            echo "Now we register the image to MNI152"

            # take in the zstat image and transform to MNI152
            flirt -in cope1.feat/thresh_zstat1.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out cope1.feat/MNI_thresh_zstat1.nii.gz -init $DIREC$s"/func/func1/anat2template.mat" -applyxfm -v
        
        else 

            echo $DIREC$s$d"cope1.feat doesn't exist"
            
        fi

        cd $DIREC$s"/func/"

    done
done