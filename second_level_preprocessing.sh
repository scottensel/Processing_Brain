 #!/bin/bash
#
# SBSN framework - Preprocessing
# June 2022
#
# Preparation of functional spine data
#
# Requirements: FSL, Spinal Cord Toolbox 5.5
#
# SPINE


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
echo -n "Enter the index of the step to perform (1 = Prepare for GLM, 2 = Prepare for iCAP): "
tput sgr0;
read ind


# For each subject
for s in "${sub[@]}"; do

		cd $DIREC$s"/func/"

        for d in "${myFunc[@]}"; do

            if [ "$ind" == "1" ]; then
                tput setaf 2; echo "Prepare second level analysis for GLM " $s"/func/func"$d
                tput sgr0; 

                # Will print */ if no directories are available
                cd $DIREC$s"/func/func"$d"/"

                tput setaf 2; echo "Moving files " $s"/func/func"$d	

                cp -r "/mnt/d/SMA/MRI_data/reg/" $DIREC$s"/func/func"$d"/level_one.feat/"
                
                # these have to be the same size across all subject because they get concatenated in the 4th dimension
                # change this to the PAM50 template
                cp ../../../../../template/PAM50_t2s.nii.gz level_one.feat/reg/standard.nii.gz
                cp ../../../../../template/PAM50_t2s.nii.gz level_one.feat/reg/example_func.nii.gz

                cp anat2template.nii.gz level_one.feat/example_func.nii.gz
                cp anat2template.nii.gz level_one.feat/mean_func.nii.gz

                if [ -f level_one.feat/stats/subjectSpace_cope1.nii.gz ]; then

                    # files have already been transofrmed
                    # subject space images are original images so just apply warps to them
                    # no need to rename files again
                    sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/cope1.nii.gz

                    sct_apply_transfo -i level_one.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/varcope1.nii.gz

                    # i think this mask may have to be replaced with the PAM50 mask that we want to use
                    cp ../../../../../template/PAM50_cord.nii.gz level_one.feat/mask.nii.gz
                    #sct_apply_transfo -i level_one.feat/subjectSpace_mask.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/mask.nii.gz

                else

                    # rename file then apply a transform to it so its located in PAM50 space
                    mv level_one.feat/stats/cope1.nii.gz level_one.feat/stats/subjectSpace_cope1.nii.gz
                    #sleep 10
                    sct_apply_transfo -i level_one.feat/stats/subjectSpace_cope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/cope1.nii.gz

                    mv level_one.feat/stats/varcope1.nii.gz level_one.feat/stats/subjectSpace_varcope1.nii.gz
                    #sleep 10
                    sct_apply_transfo -i level_one.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one.feat/stats/varcope1.nii.gz

                    # i think this mask may have to be replaced with the PAM50 mask that we want to use
                    mv level_one.feat/mask.nii.gz level_one.feat/subjectSpace_mask.nii.gz
                    cp ../../../../../template/PAM50_cord.nii.gz level_one.feat/mask.nii.gz

                fi

            elif [ "$ind" == "2" ]; then

                tput setaf 2; echo "Prepare second level analysis for GLM " $s"/func/func"$d
                tput sgr0; 

                # Will print */ if no directories are available
                cd $DIREC$s"/func/func"$d"/"

                tput setaf 2; echo "Moving files " $s"/func/func"$d	

                cp -r "/mnt/d/SMA/MRI_data/reg/" $DIREC$s"/func/func"$d"/level_one_force.feat/"
                
                # these have to be the same size across all subject because they get concatenated in the 4th dimension
                # change this to the PAM50 template
                cp ../../../../../template/PAM50_t2s.nii.gz level_one_force.feat/reg/standard.nii.gz
                cp ../../../../../template/PAM50_t2s.nii.gz level_one_force.feat/reg/example_func.nii.gz

                cp anat2template.nii.gz level_one_force.feat/example_func.nii.gz
                cp anat2template.nii.gz level_one_force.feat/mean_func.nii.gz

                if [ -f level_one_force.feat/stats/subjectSpace_cope1.nii.gz ]; then

                    # files have already been transofrmed
                    # subject space images are original images so just apply warps to them
                    # no need to rename files again
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_cope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_cope2.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope2.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_cope3.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope3.nii.gz

                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope1.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope2.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope2.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope3.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope3.nii.gz

                    # i think this mask may have to be replaced with the PAM50 mask that we want to use
                    cp ../../../../../template/PAM50_cord.nii.gz level_one_force.feat/mask.nii.gz
                    #sct_apply_transfo -i level_one_force.feat/subjectSpace_mask.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/mask.nii.gz

                else

                    # rename file then apply a transform to it so its located in PAM50 space
                    mv level_one_force.feat/stats/cope1.nii.gz level_one_force.feat/stats/subjectSpace_cope1.nii.gz
                    mv level_one_force.feat/stats/cope2.nii.gz level_one_force.feat/stats/subjectSpace_cope2.nii.gz
                    mv level_one_force.feat/stats/cope3.nii.gz level_one_force.feat/stats/subjectSpace_cope3.nii.gz

                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_cope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope1.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_cope2.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope2.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_cope3.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/cope3.nii.gz

                    mv level_one_force.feat/stats/varcope1.nii.gz level_one_force.feat/stats/subjectSpace_varcope1.nii.gz
                    mv level_one_force.feat/stats/varcope2.nii.gz level_one_force.feat/stats/subjectSpace_varcope2.nii.gz
                    mv level_one_force.feat/stats/varcope3.nii.gz level_one_force.feat/stats/subjectSpace_varcope3.nii.gz

                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope1.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope1.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope2.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope2.nii.gz
                    sct_apply_transfo -i level_one_force.feat/stats/subjectSpace_varcope3.nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w warp_anat2template.nii.gz -o level_one_force.feat/stats/varcope3.nii.gz

                    # i think this mask may have to be replaced with the PAM50 mask that we want to use
                    mv level_one_force.feat/mask.nii.gz level_one_force.feat/subjectSpace_mask.nii.gz
                    cp ../../../../../template/PAM50_cord.nii.gz level_one_force.feat/mask.nii.gz

                fi

            elif [ "$ind" == "3" ]; then

                cd $DIREC$s"/func/func"$d"/"

                #tput setaf 2; echo "Preparing for TA in " $s"/func/func"$d
                #tput sgr0; 

                mkdir $DIREC$s"/func/func"$d"/iCAP/TA" -p
                cd $DIREC$s"/func/func"$d"/iCAP"

                cp ../../../../template/PAM50_cervical_cord_all.nii.gz cervical_mask_all.nii.gz
                cp ../../../../template/PAM50_cervical_cord.nii.gz cervical_mask.nii.gz
                cp ../fmri_spine_moco_denoised.nii.gz TA/fmri_spine_moco_denoised_icap.nii.gz

                gunzip cervical_mask.nii.gz -f

                # first we are going to split the data along the t dimension

                tput setaf 2; echo "...Split functional data"
                        tput sgr0;

                # First, split data
                cd $DIREC$s"/func/func"$d"/iCAP/TA"
                fslsplit fmri_spine_moco_denoised_icap.nii.gz resvol -t

                for n in "$PWD"/resvol*.nii.gz; do # Loop through all files

                    IFS='.' read -r volname string <<< "$n"

                    sct_apply_transfo -i "${volname##*/}".nii.gz -d ../../../../../template/PAM50_t2s.nii.gz -w ../../warp_anat2template.nii.gz   

                    mv "${volname##*/}"_reg.nii.gz "${volname##*/}".nii.gz

                    #sct_smooth_spinalcord -i "${volname##*/}".nii.gz -s ../cervical_mask_all.nii.gz -smooth 2,2,6 -o "${volname##*/}".nii.gz

                    gunzip "${volname##*/}".nii.gz  -f

                done

                tput setaf 2; echo "...Clean"
                        tput sgr0;
                
                rm straight_ref.nii.gz
                rm warp_curve2straight.nii.gz
                rm warp_straight2curve.nii.gz 
                rm straightening.cache     
                rm resvol*.nii.gz
                mv fmri_spine_moco_denoised_icap.nii.gz ../fmri_spine_moco_denoised_icap.nii.gz
                

            fi
    
        done
		tput setaf 2; echo "Done!" 
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