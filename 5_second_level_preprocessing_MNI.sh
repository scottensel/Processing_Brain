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
echo -n "Enter the index of the step to perform (1 = Prepare for GLM, 2 = Prepare for force GLM, 3 = Prepare for iCAP): "
tput sgr0;
read ind


# For each subject
for s in "${sub[@]}"; do

		cd $DIREC$s"/func/"

        for d in "${myFunc[@]}"; do

            cd $DIREC$s"/func/func"$d"/"
            echo $DIREC$s"/func/func"$d

			if [ "$ind" == "1" ]; then

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
                cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_FLOB.feat/reg/example_func2standard.nii.gz

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
                cp -r "$DIREC"/reg/"" $DIREC$s"/func/func"$d"/level_one_force.feat/"

                # these have to be the same size across all subject because they get concatenated in the 4th dimension
                cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_force.feat/reg/standard.nii.gz
                cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_force.feat/reg/example_func.nii.gz
                cp ../../../template/MNI152_T1_2mm_brain.nii.gz level_one_force.feat/reg/example_func2standard.nii.gz

                totalCopes=(1 2 3 4 5 6)
                for copeNum in "${totalCopes[@]}"; do

                    if [ -f level_one_force.feat/stats/subjectSpace_cope"$copeNum".nii.gz  ]; then
                        tput setaf 1;
                        echo $DIREC$s"/func/func"$d"/level_one_force.feat/stats/cope"$copeNum

                        tput setaf 6;
                        #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/cope1.nii.gz
                        flirt -in level_one_force.feat/stats/subjectSpace_cope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/stats/cope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                    else
                        tput setaf 1;
                        echo $DIREC$s"/func/func"$d"/level_one_force.feat/stats/cope"$copeNum
                   
                        tput setaf 6;
                        mv level_one_force.feat/stats/cope"$copeNum".nii.gz level_one_force.feat/stats/subjectSpace_cope"$copeNum".nii.gz
                        #sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                        flirt -in level_one_force.feat/stats/subjectSpace_cope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/stats/cope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v

                    fi

                    if [ -f level_one_force.feat/stats/subjectSpace_varcope"$copeNum".nii.gz  ]; then
                        
                        tput setaf 1;
                        echo $DIREC$s"/func/func"$d"/level_one_force.feat/stats/varcope"$copeNum

                        tput setaf 6;
                        #sct_apply_transfo -i level_one.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/varcope1.nii.gz
                        flirt -in level_one_force.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v
    
                    else
                        tput setaf 1;
                        echo $DIREC$s"/func/func"$d"/level_one_force.feat/stats/varcope"$copeNum
                        
                        tput setaf 6;
                        mv level_one_force.feat/stats/varcope"$copeNum".nii.gz level_one_force.feat/stats/subjectSpace_varcope"$copeNum".nii.gz
                        #sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope1.nii.gz
                        flirt -in level_one_force.feat/stats/subjectSpace_varcope"$copeNum".nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/stats/varcope"$copeNum".nii.gz -init ../func1/anat2template.mat -applyxfm -v
    
                    fi

                done

                if [ -f level_one_force.feat/stats/subjectSpace_mask.nii.gz  ]; then

                    cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one_force.feat/mask.nii.gz

                    #sct_apply_transfo -i level_one.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/mask.nii.gz
                    #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

                else
                    mv level_one_force.feat/mask.nii.gz level_one_force.feat/subjectSpace_mask.nii.gz
                    cp ../../../template/MNI152_T1_brain_mask.nii.gz level_one_force.feat/mask.nii.gz

                    #sct_apply_transfo -i level_one_force.feat/subjectSpace_mask.nii.gz -d ../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/mask.nii.gz
                    #flirt -in level_one_force.feat/subjectSpace_mask.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out level_one_force.feat/mask.nii.gz -init ../func1/anat2template.mat -applyxfm -v

                fi

            elif [ "$ind" == "3" ]; then

                #tput setaf 2; echo "Apply warping field to denoised fMRI in " $s"/func/func"$d
                #tput sgr0; 
                cp fmri_brain_moco_denoised_subject.nii.gz fmri_brain_moco_denoised.nii.gz
                
                mkdir $DIREC$s"/func/func"$d"/iCAP/TA" -p
                cd $DIREC$s"/func/func"$d"/iCAP"

                cp $DIREC"template/MNI152_T1_2mm_brain_GM.nii.gz" MNI_GM_mask.nii.gz
                cp ../fmri_brain_moco_denoised.nii.gz TA/fmri_brain_moco_denoised.nii.gz

                gunzip MNI_GM_mask.nii.gz -f

                # First, split data
                cd $DIREC$s"/func/func"$d"/iCAP/TA"

                # first we are going to split the data along the t dimension
                tput setaf 2; echo "Transform to MNI"
                        tput sgr0;

                ## APPLY TRANSOFRM TO NON SPLIT DATA
                flirt -in fmri_brain_moco_denoised.nii.gz -ref ../../../../../template/MNI152_T1_2mm_brain.nii.gz -out fmri_brain_moco_denoised.nii.gz -init $DIREC$s"/func/func1/anat2template.mat" -applyxfm -v

                # first we are going to split the data along the t dimension
                tput setaf 2; echo "...Split functional data"
                        tput sgr0;

                fslsplit fmri_brain_moco_denoised.nii.gz resvol -t

                for n in "$PWD"/resvol*.nii.gz; do # Loop through all files

                    IFS='.' read -r volname string <<< "$n"
                    gunzip "${volname##*/}".nii.gz -f

                done

                tput setaf 2; echo "...Cleaning up"
                        tput sgr0;
                
                rm resvol*.nii.gz
                mv fmri_brain_moco_denoised.nii.gz ../fmri_brain_moco_denoised_icap.nii.gz

            fi

        done
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