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

tput setaf 6; 
echo -n "Enter the index of the step to perform (1 = Prepare for GLM, 2 = Prepare for force GLM, 3 = Prepare for iCAP): "
tput sgr0;
read ind

# For each subject
for s in "${sub[@]}"; do

		cd $DIREC$s"/func/"

        for d in "${myFunc[@]}"; do

            # Will print */ if no directories are available
            cd $DIREC$s"/func/func"$d"/"

            ## generate the EVs (regressors) for moco fmri and create outliers.txt using the brain mask
            # Generate EV for outliers
            if [ ! -f outliers.png ]; then
    
                echo "Generate motion outliers..."
                tput sgr0

                fsl_motion_outliers -i fmri_brain_moco_reg.nii.gz -o outliers.txt -p outliers.png --dvars --nomoco
            fi

            ## adds the moco_params files to the txt file
            if [ ! -f fmri_moco.txt ]; then
                cp fmri_moco.par fmri_moco.txt 
            fi

            ## creates text file will all the regressor files

            # for some reason adding these EV always causes the level one to fail.
            #ls -1 `${FSLDIR}/bin/imglob -extensions ${DIREC}${s}/physio/physio${d}/${s}ev0*` > regressors_evlist.txt
            #ls -1 `${FSLDIR}/bin/imglob -extensions ${DIREC}${s}/physio/physio${d}/${s}ev001*` > regressors_evlist.txt

            ## add CSF mask
            fslcpgeom fmri_brain_moco_reg.nii.gz "$DIREC$s"/physio/physio"$d"/${s}_csf*""
            echo "$DIREC$s"/physio/physio"$d"/${s}_csf*"" > regressors_evlist.txt # Add CSF mask

            ## adds the moco_params files to the counfounds list
            paste -d '' "$DIREC$s"/func/func"$d"/fmri_moco.txt"" "$DIREC$s"/func/func"$d"/WM_regressor.txt"" outliers.txt > confoundsList.txt


            # changes the template file that it loops through
            if [ "$ind" == "1" ]; then
                templateFile="template_design.fsf"
            elif [ "$ind" == "2" ]; then
                templateFile="template_design_force.fsf"
            elif [ "$ind" == "3" ]; then
                templateFile="template_design.fsf"
            fi

            ## Generate fsf file from template
            ## path is relevant to folder we are in which is sub-XX/func
            ## for i in "../../../template/template_design.fsf"; do
            for i in "../../../template/"$templateFile; do

                # 1 - PREPARE .fsf files properly
                if [ "$ind" == "1" ]; then

                    tput setaf 2; echo "Prepare first level analysis for GLM " $s"/func/func"$d
                    tput sgr0; 

                    # this is editing the text of the files
                    sed -e 's@OUT_DIREC@'"level_one"'@g' \
                            -e 's@PNMPATH@'$DIREC$s"/func/func"$d"/regressors_evlist.txt"'@g' \
                            -e 's@4D_DATA_PATH@'$DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz"'@g' \
                            -e 's@EVENTS_FILE_PATH@'$DIREC$s"/task/task"$d"/events.txt"'@g' \
                            -e 's@NPTS@'"$(fslnvols $DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz")"'@g' \
                            -e 's@CONFOUND@'$DIREC$s"/func/func"$d"/confoundsList.txt"'@g' \
                            -e 's@set fmri(regunwarp_yn) 1@'"set fmri(regunwarp_yn) 0"'@g' <$i> design_levelone.fsf

                # 2 - 
                elif [ "$ind" == "2" ]; then
                    tput setaf 2; echo "Prepare first level analysis for GLM " $s"/func/func"$d
                    tput sgr0; 

                    # this is editing the text of the files
                    sed -e 's@OUT_DIREC@'"level_one_force"'@g' \
                            -e 's@PNMPATH@'$DIREC$s"/func/func"$d"/regressors_evlist.txt"'@g' \
                            -e 's@4D_DATA_PATH@'$DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz"'@g' \
                            -e 's@EVENTS_FILE_PATH1@'$DIREC$s"/task/task"$d"/force20.txt"'@g' \
                            -e 's@EVENTS_FILE_TITLE1@'20'@g' \
                            -e 's@EVENTS_FILE_PATH2@'$DIREC$s"/task/task"$d"/force45.txt"'@g' \
                            -e 's@EVENTS_FILE_TITLE2@'45'@g' \
                            -e 's@EVENTS_FILE_PATH3@'$DIREC$s"/task/task"$d"/force70.txt"'@g' \
                            -e 's@EVENTS_FILE_TITLE3@'70'@g' \
                            -e 's@NPTS@'"$(fslnvols $DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz")"'@g' \
                            -e 's@CONFOUND@'$DIREC$s"/func/func"$d"/confoundsList.txt"'@g' \
                            -e 's@set fmri(regunwarp_yn) 1@'"set fmri(regunwarp_yn) 0"'@g' <$i> design_levelone_force.fsf


                elif [ "$ind" == "3" ]; then
                    tput setaf 2; echo "Prepare for iCAP " $s"/func/func"$d
                    tput sgr0; 

                    sed -e 's@OUT_DIREC@'"icap_prep"'@g' \
                            -e 's@PNMPATH@'$DIREC$s"/func/func"$d"/regressors_evlist.txt"'@g' \
                            -e 's@4D_DATA_PATH@'$DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz"'@g' \
                            -e 's@EVENTS_FILE_PATH@'""'@g' \
                            -e 's@NPTS@'"$(fslnvols $DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz")"'@g' \
                            -e 's@CONFOUND@'$DIREC$s"/func/func"$d"/confoundsList.txt"'@g' \
                            -e 's@set fmri(shape1) 3@'"set fmri(shape1) 10"'@g' \
                            -e 's@set fmri(convolve1) 2@'"set fmri(convolve1) 0"'@g' \
                            -e 's@set fmri(regunwarp_yn) 1@'"set fmri(regunwarp_yn) 0"'@g' <$i> design_icapprep.fsf


                fi

                # created a design_levelone.fsf based on the template.fsf
            done

            if [ "$ind" == "1" ]; then
                tput setaf 2; echo "Run first level analysis for " $s"/func/func"$d
                tput sgr0; 

                # Run the analysis using the fsf file
                feat design_levelone.fsf

            elif [ "$ind" == "2" ]; then
                tput setaf 2; echo "Run first level analysis for " $s"/func/func"$d
                tput sgr0; 

                # Run the analysis using the fsf file
                feat design_levelone_force.fsf
            
            elif [ "$ind" == "3" ]; then
                tput setaf 2; echo "Run noise regression for " $s"/func/func"$d
                tput sgr0; 

                # Run the analysis using the fsf file
                feat design_icapprep.fsf

                # Copy geometry to residuals for TA
                cp icap_prep.feat/stats/res4d.nii.gz fmri_brain_moco_denoised_subject.nii.gz
                fslcpgeom fmri_brain_moco_reg.nii.gz fmri_brain_moco_denoised_subject.nii.gz
              
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