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
. /mnt/d/SMA/Processing_Brain/path_to_subjects.sh 

tput setaf 6; 
echo -n "Enter the index of the step to perform (1 = Prepare for FLOB GLM (this one), 2 = Prepare for FLOB force GLM (this one), 3 = Prepare for iCAP: "
tput sgr0
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

            tput setaf 2; echo "Prepare nuisance regressors file..."
            tput sgr0

            ## creates text file will all the regressor files
            ls -1 `${FSLDIR}/bin/imglob -extensions ${DIREC}${s}/physio/physio${d}/${s}ev0*` > regressors_evlist.txt

            # for some reason adding these EV always causes the level one to fail.
            #ls -1 `${FSLDIR}/bin/imglob -extensions ${DIREC}${s}/physio/physio${d}/${s}ev0*` > regressors_evlist.txt
            #ls -1 `${FSLDIR}/bin/imglob -extensions ${DIREC}${s}/physio/physio${d}/${s}ev001*` > regressors_evlist.txt


            ## adds the moco_params files to the counfounds list
            #paste -d '' "$DIREC$s"/func/func"$d"/fmri_moco.txt"" "$DIREC$s"/func/func"$d"/WM_regressor.txt"" "$DIREC$s"/func/func"$d"/CSF_regressor.txt"" outliers.txt > confoundsList.txt
            paste -d '' "$DIREC$s"/func/func"$d"/fmri_moco.txt"" "$DIREC$s"/func/func"$d"/WM_regressor.txt"" outliers.txt > confoundsList.txt


            # changes the template file that it loops through
            if [ "$ind" == "1" ]; then
                templateFile="template_design_FLOB.fsf"
            elif [ "$ind" == "2" ]; then
                templateFile="template_design_force_FLOB.fsf" 
            elif [ "$ind" == "3" ]; then
                templateFile="template_design.fsf"               
            fi

            ## Generate fsf file from template
            ## path is relevant to folder we are in which is sub-XX/func
            ## for i in "../../../template/template_design.fsf"; do
            for i in "../../../template/"$templateFile; do

                # 1 - PREPARE .fsf files properly
                if [ "$ind" == "1" ]; then
                    tput setaf 2; echo "Prepare first level analysis for GLM FLOB " $s"/func/func"$d
                    tput sgr0; 

                    sed -e 's@PNMPATH@'$DIREC$s"/func/func"$d"/regressors_evlist.txt"'@g' \
                                        -e 's@OUT_DIREC@'"level_one_FLOB"'@g' \
                                        -e 's@4D_DATA_PATH@'$DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz"'@g' \
                                        -e 's@OUTLYN@'"1"'@g' \
                                        -e 's@NPTS@'"$(fslnvols $DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz")"'@g' \
                                        -e 's@EVENTS_FILE_PATH@'$DIREC$s"/task/task"$d"/events.txt"'@g' \
                                        -e 's@CONFOUND@'$DIREC$s"/func/func"$d"/confoundsList.txt"'@g' <$i> design_levelone_FLOB.fsf


                elif [ "$ind" == "2" ]; then
                    tput setaf 2; echo "Prepare first level analysis for GLM force FLOB " $s"/func/func"$d
                    tput sgr0;

                    sed -e 's@OUT_DIREC@'"level_one_force_FLOB"'@g' \
                                        -e 's@PNMPATH@'$DIREC$s"/func/func"$d"/regressors_evlist.txt"'@g' \
                                        -e 's@4D_DATA_PATH@'$DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz"'@g' \
                                        -e 's@OUTLYN@'"1"'@g' \
                                        -e 's@NPTS@'"$(fslnvols $DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz")"'@g' \
                                        -e 's@CONFOUND@'$DIREC$s"/func/func"$d"/confoundsList.txt"'@g' \
                                        -e 's@EV_TITLE1@'20'@g' \
                                        -e 's@EV_FILE1@'$DIREC$s"/task/task"$d"/force20.txt"'@g' \
                                        -e 's@EV_TITLE2@'45'@g' \
                                        -e 's@EV_FILE2@'$DIREC$s"/task/task"$d"/force45.txt"'@g' \
                                        -e 's@EV_TITLE3@'70'@g' \
                                        -e 's@EV_FILE3@'$DIREC$s"/task/task"$d"/force70.txt"'@g' <$i> design_levelone_force_FLOB.fsf



                elif [ "$ind" == "3" ]; then
                    tput setaf 2; echo "Prepare for iCAP " $s"/func/func"$d
                    tput sgr0; 

                    sed -e 's@OUT_DIREC@'"icap_prep"'@g' \
                            -e 's@PNMPATH@'$DIREC$s"/func/func"$d"/regressors_evlist.txt"'@g' \
                            -e 's@4D_DATA_PATH@'$DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz"'@g' \
                            -e 's@EV_TITLE@'""'@g' \
                            -e 's@EVENTS_FILE_PATH@'""'@g' \
                            -e 's@NPTS@'"$(fslnvols $DIREC$s"/func/func"$d"/fmri_brain_moco_reg.nii.gz")"'@g' \
                            -e 's@CONFOUND@'$DIREC$s"/func/func"$d"/confoundsList.txt"'@g' <$i> icap_denoised.fsf

                fi

                # created a design_levelone.fsf based on the template.fsf
            done

            

            if [ "$ind" == "1" ]; then
                tput setaf 2; echo "Run first level FLOB analysis for " $s"/func/func"$d
                tput sgr0; 
                
                # Run the analysis using the fsf file
                feat design_levelone_FLOB.fsf      

            elif [ "$ind" == "2" ]; then
                tput setaf 2; echo "Run first level FLOB force analysis for " $s"/func/func"$d
                tput sgr0; 
                
                # Run the analysis using the fsf file
                feat design_levelone_force_FLOB.fs

            elif [ "$ind" == "3" ]; then
                tput setaf 2; echo "Run noise regression for " $s"/func/func"$d
                tput sgr0; 

                # Run the analysis using the fsf file
                feat icap_denoised.fsf

                #Copy geometry to residuals for TA
                cp icap_prep.feat/stats/res4d.nii.gz fmri_brain_moco_denoised.nii.gz

                # copy header info
                fslcpgeom fmri_brain_moco_reg.nii.gz fmri_brain_moco_denoised.nii.gz
        
                # smooth the image
                fslmaths fmri_brain_moco_denoised.nii.gz -s 2.5479870902 fmri_brain_moco_denoised_smooth

            fi

        
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