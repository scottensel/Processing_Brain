#!/bin/bash
#
# SBSN framework - Preprocessing
# June 2022
#
# Preparation of functional spine data
#
# Requirements: FSL, Spinal Cord Toolbox 5.5
#
# BRAIN


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

tput setaf 6; 
echo -n "Enter the index of the step to perform (0 = shift to MNI, 1 = Prepare for GLM (this one), 2 = Prepare for force FLOB GLM (this one), 3 = Prepare for iCAP, 4 = Prepare 3rd level flip): "
tput sgr0;
read ind


# For each subject
for s in "${sub[@]}"; do

	cd $DIREC$s"/func/"

    for d in "${myFunc[@]}"; do

        cd $DIREC$s"/func/func"$d"/"
        echo $DIREC$s"/func/func"$d

        if [ "$ind" == "0" ]; then


            if [ "$d" == "0" ]; then
            

                tput setaf 2; echo "Prepare second level analysis for REST GLM " $s"/func/func"$d
                tput sgr0; 

                if [ -f "level_one_FLOB.feat/stats/subjectSpace_zstat1.nii.gz" ]; then
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_FLOB.feat/stats/zstat1.nii.gz"

                    tput setaf 6;
                    flirt -in level_one_FLOB.feat/stats/subjectSpace_zstat1.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_FLOB.feat/stats/zstat1.nii.gz -init ../func1/anat2template.mat -applyxfm -v
                    #flirt -in level_one_force_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v
                    flirt -in subjectSpace_zstat1.nii.gz -ref ../../../../../template/MNI152_T1_2mm_brain.nii.gz -out zstat1.nii.gz -init ../../../func1/anat2template.mat -applyxfm -v

                else
                    tput setaf 1;
                    echo "No Subject File"
                    echo $DIREC$s"/func/func"$d"/level_one_FLOB.feat/stats/zstat1.nii.gz"
               
                    tput setaf 6;
                    mv level_one_FLOB.feat/stats/zstat1.nii.gz level_one_FLOB.feat/stats/subjectSpace_zstat1.nii.gz
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                    flirt -in level_one_FLOB.feat/stats/subjectSpace_zstat1.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_FLOB.feat/stats/zstat1.nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

            # tput setaf 2; echo "Prepare second level analysis for GLM " $s"/func/func"$d
            # tput sgr0; 
            else
                if [ -f "level_one_force_FLOB.feat/stats/subjectSpace_zfstat1.nii.gz" ]; then
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/stats/zfstat1.nii.gz"

                    tput setaf 6;
                    flirt -in level_one_force_FLOB.feat/stats/subjectSpace_zfstat1.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/zfstat1.nii.gz -init ../func1/anat2template.mat -applyxfm -v

                else
                    tput setaf 1;
                    echo "No Subject File"
                    echo $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/stats/zfstat1.nii.gz"
               
                    tput setaf 6;
                    mv level_one_force_FLOB.feat/stats/zfstat1.nii.gz level_one_force_FLOB.feat/stats/subjectSpace_zfstat1.nii.gz
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                    flirt -in level_one_force_FLOB.feat/stats/subjectSpace_zfstat1.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/zfstat1.nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

            done


		elif [ "$ind" == "1" ]; then

            tput setaf 2; echo "Prepare second level analysis for GLM " $s"/func/func"$d
            tput sgr0; 

            # copy the reg folder in because its needed for 2nd level analysis
            cp -r "$DIREC"/reg/"" $DIREC$s"/func/func"$d"/level_one_FLOB.feat/"

            # # these have to be the same size across all subject because they get concatenated in the 4th dimension
            # cp level_one.feat/mean_func.nii.gz level_one.feat/reg/standard.nii.gz
            # cp level_one.feat/mean_func.nii.gz level_one.feat/reg/example_func.nii.gz
            # cp level_one.feat/mean_func.nii.gz level_one.feat/reg/example_func2standard.nii.gz

            # these have to be the same size across all subject because they get concatenated in the 4th dimension
            cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_FLOB.feat/reg/standard.nii.gz
            cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_FLOB.feat/reg/example_func.nii.gz
            #cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_FLOB.feat/reg/example_func2standard.nii.gz

            totalCopes=(1)
            for copeNum in "${totalCopes[@]}"; do


                if [ -f level_one_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz  ]; then
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_FLOB.feat/stats/cope"$copeNum

                    tput setaf 6;
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/cope1.nii.gz
                    flirt -in level_one_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_FLOB.feat/stats/cope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                else
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_FLOB.feat/stats/cope"$copeNum
               
                    tput setaf 6;
                    mv level_one_FLOB.feat/stats/cope"$copeNum".nii.gz level_one_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                    flirt -in level_one_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_FLOB.feat/stats/cope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

                if [ -f level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz  ]; then
                    
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_FLOB.feat/stats/varcope"$copeNum

                    tput setaf 6;
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/varcope1.nii.gz
                    flirt -in level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_FLOB.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                else
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_FLOB.feat/stats/varcope"$copeNum
                    
                    tput setaf 6;

                    #mv level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz
                    mv level_one_FLOB.feat/stats/varcope"$copeNum".nii.gz level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz
                    #sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope1.nii.gz
                    flirt -in level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_FLOB.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

            done

            # if [ -f level_one.feat/stats/subjectSpace_mask.nii.gz  ]; then

            #     # cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one.feat/mask.nii.gz
            #     # cp ../func1/MNI152_GM.nii.gz level_one.feat/mask.nii.gz

            #     flirt -in level_one.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v
            #     flirt -in level_one.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one.feat/reg_standard/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            #     #sct_apply_transfo -i level_one.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/mask.nii.gz
            #     #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            # else
            #     mv level_one.feat/mask.nii.gz level_one.feat/subjectSpace_mask.nii.gz
            #     # cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one.feat/mask.nii.gz
            #     # cp ../func1/MNI152_GM.nii.gz level_one.feat/mask.nii.gz

            #     flirt -in level_one.feat/mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v
            #     flirt -in level_one.feat/mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one.feat/reg_standard/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            #     #sct_apply_transfo -i level_one_force.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/mask.nii.gz
            #     #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            # fi
            
            if [ -f level_one_FLOB.feat/stats/subjectSpace_mask.nii.gz  ]; then

                cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one_FLOB.feat/mask.nii.gz

                #sct_apply_transfo -i level_one.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/mask.nii.gz
                #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            else
                mv level_one_FLOB.feat/mask.nii.gz level_one_FLOB.feat/subjectSpace_mask.nii.gz
                cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one_FLOB.feat/mask.nii.gz

                #sct_apply_transfo -i level_one_force.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/mask.nii.gz
                #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            fi
            cp level_one_FLOB.feat/mask.nii.gz level_one_FLOB.feat/reg_standard/mask.nii.gz


        elif [ "$ind" == "2" ]; then

            tput setaf 2; echo "Prepare second level analysis for GLM " $s"/func/func"$d
            tput sgr0; 

            # copy the reg folder in because its needed for 2nd level analysis
            cp -r "$DIREC"/reg/"" $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/"

            # # these have to be the same size across all subject because they get concatenated in the 4th dimension
            # cp level_one.feat/mean_func.nii.gz level_one.feat/reg/standard.nii.gz
            # cp level_one.feat/mean_func.nii.gz level_one.feat/reg/example_func.nii.gz
            # cp level_one.feat/mean_func.nii.gz level_one.feat/reg/example_func2standard.nii.gz

            # these have to be the same size across all subject because they get concatenated in the 4th dimension
            cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_force_FLOB.feat/reg/standard.nii.gz
            cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_force_FLOB.feat/reg/example_func.nii.gz
            #cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_FLOB.feat/reg/example_func2standard.nii.gz

            totalCopes=(1 2 3 4 5 6 7 8 9)
            for copeNum in "${totalCopes[@]}"; do


                if [ -f level_one_force_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz  ]; then
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/stats/cope"$copeNum

                    tput setaf 6;
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/cope1.nii.gz
                    flirt -in level_one_force_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/cope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                else
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/stats/cope"$copeNum
               
                    tput setaf 6;
                    mv level_one_force_FLOB.feat/stats/cope"$copeNum".nii.gz level_one_force_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                    flirt -in level_one_force_FLOB.feat/stats/subjectSpace_cope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/cope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

                if [ -f level_one_force_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz  ]; then
                    
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/stats/varcope"$copeNum

                    tput setaf 6;
                    #sct_apply_transfo -i level_one.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/varcope1.nii.gz
                    flirt -in level_one_force_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                else
                    tput setaf 1;
                    echo $DIREC$s"/func/func"$d"/level_one_force_FLOB.feat/stats/varcope"$copeNum
                    
                    tput setaf 6;

                    #mv level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz level_one_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz
                    mv level_one_force_FLOB.feat/stats/varcope"$copeNum".nii.gz level_one_force_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz
                    #sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope1.nii.gz
                    flirt -in level_one_force_FLOB.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force_FLOB.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

            done

            
            if [ -f level_one_force_FLOB.feat/stats/subjectSpace_mask.nii.gz  ]; then

                cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one_force_FLOB.feat/mask.nii.gz

                #sct_apply_transfo -i level_one.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/mask.nii.gz
                #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            else
                mv level_one_force_FLOB.feat/mask.nii.gz level_one_force_FLOB.feat/subjectSpace_mask.nii.gz
                cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one_force_FLOB.feat/mask.nii.gz

                #sct_apply_transfo -i level_one_force.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/mask.nii.gz
                #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

            fi
            cp level_one_force_FLOB.feat/mask.nii.gz level_one_force_FLOB.feat/reg_standard/mask.nii.gz


        elif [ "$ind" == "3" ]; then
            
            mkdir $DIREC$s"/func/func"$d"/iCAP/TA" -p
            cd $DIREC$s"/func/func"$d"/iCAP"

            cp $DIREC"template/MNI152_T1_2mm_brain_GM.nii.gz" MNI_GM_mask.nii.gz
            cp ../fmri_brain_moco_denoised_smooth.nii.gz TA/fmri_brain_moco_denoised_smooth.nii.gz

            gunzip MNI_GM_mask.nii.gz -f

            cd $DIREC$s"/func/func"$d"/iCAP/TA"

            tput setaf 2; echo "Transform to MNI"
                    tput sgr0;

            ## APPLY TRANSOFRM TO NON SPLIT DATA
            flirt -in fmri_brain_moco_denoised_smooth.nii.gz -ref ../../../../../template/MNI152_T1_2mm_brain.nii.gz -out fmri_brain_moco_denoised_smooth.nii.gz -init $DIREC$s"/func/func1/anat2template.mat" -applyxfm -v

            # first we are going to split the data along the t dimension
            tput setaf 2; echo "...Split functional data"
                    tput sgr0;

            fslsplit fmri_brain_moco_denoised_smooth.nii.gz resvol -t

            for n in "$PWD"/resvol*.nii.gz; do # Loop through all files

                IFS='.' read -r volname string <<< "$n"
                gunzip "${volname##*/}".nii.gz -f

            done

            tput setaf 2; echo "...Cleaning up"
                    tput sgr0;
            
            # get rid of gz files and original image
            rm resvol*.nii.gz fmri_brain_moco_denoised_smooth.nii.gz


        elif [ "$ind" == "4" ]; then

            tput setaf 2; echo "Prepare third level analysis for GLM " $s
            tput sgr0; 

            cd $DIREC$s"/func/"

            # do two different if statements for both the cope and var cope to avoid outlier cases of overwriting
            if [ -f "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_cope1.nii.gz" ]; then

                tput setaf 1; 
                echo $DIREC$s"/func/"

                tput setaf 6;
                # files have already been transofrmed
                # subject space images are original images so just apply warps to them
                # no need to rename files again                
                fslswapdim "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_cope1.nii.gz" -x y z "level_two_force_FLOB1234.gfeat/cope1.feat/stats/cope1.nii.gz"
            
            else 
                echo "No subject space cope"

                # rename file then apply a transform to it so its located in PAM50 space
                mv "level_two_force_FLOB1234.gfeat/cope1.feat/stats/cope1.nii.gz" "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_cope1.nii.gz"

                tput setaf 1; 
                echo $DIREC$s"/func/"

                tput setaf 6;
                # files have already been transofrmed
                fslswapdim "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_cope1.nii.gz" -x y z "level_two_force_FLOB1234.gfeat/cope1.feat/stats/cope1.nii.gz"

            fi

            # another if statement that does same as above except for varcope file
            if [ -f "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_varcope1.nii.gz" ]; then

                tput setaf 1; 
                echo $DIREC$s"/func/"

                tput setaf 6;
                # files have already been transofrmed
                # subject space images are original images so just apply warps to them
                # no need to rename files again                
                fslswapdim "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_varcope1.nii.gz" -x y z "level_two_force_FLOB1234.gfeat/cope1.feat/stats/varcope1.nii.gz"
            

            else
                echo "No subject space varcope"

                # rename file then apply a transform to it so its located in PAM50 space
                mv "level_two_force_FLOB1234.gfeat/cope1.feat/stats/varcope1.nii.gz" "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_varcope1.nii.gz"

                tput setaf 1; 
                echo $DIREC$s"/func/"

                tput setaf 6;
                # files have already been transofrmed
                fslswapdim "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_varcope1.nii.gz" -x y z "level_two_force_FLOB1234.gfeat/cope1.feat/stats/varcope1.nii.gz"


            fi

            # another if statement that does same as above except for varcope file
            if [ -f "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_tdof_t1.nii.gz" ]; then

                tput setaf 1; 
                echo $DIREC$s"/func/"

                tput setaf 6;
                # files have already been transofrmed
                # subject space images are original images so just apply warps to them
                # no need to rename files again                
                fslswapdim "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_tdof_t1.nii.gz" -x y z "level_two_force_FLOB1234.gfeat/cope1.feat/stats/tdof_t1.nii.gz"
            

            else
                echo "No subject space tdof_t"

                # rename file then apply a transform to it so its located in PAM50 space
                mv "level_two_force_FLOB1234.gfeat/cope1.feat/stats/tdof_t1.nii.gz" "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_tdof_t1.nii.gz"

                tput setaf 1; 
                echo $DIREC$s"/func/"

                tput setaf 6;
                # files have already been transofrmed
                fslswapdim "level_two_force_FLOB1234.gfeat/cope1.feat/stats/subjectSpace_tdof_t1.nii.gz" -x y z "level_two_force_FLOB1234.gfeat/cope1.feat/stats/tdof_t1.nii.gz"


            fi
        fi

    done

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