#!/bin/bash
set -m
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
echo -n "Enter the index of the step to perform (1 = Crop the EPI, 2 = slice timing & Moco, 3 = distortion correction, 4 = Registration to first run, 5 = TSNR/SSNR): "
tput sgr0;
read ind


# For each subject
for s in "${sub[@]}"; do

		cd $DIREC$s"/func/"

        for d in "${myFunc[@]}"; do

            cd $DIREC$s"/func/func"$d"/"
            echo $DIREC$s"/func/func"$d

			if [ "$ind" == "1" ]; then

                # crop image at set point. Maybe change this to GUI
                sct_crop_image -i fmri.nii.gz -o fmri_crop.nii.gz -zmin 34
                fslmaths fmri_crop.nii.gz -Tmean fmri_crop_mean.nii.gz      

                # for creation of slice timing file
                sct_crop_image -i fmri.nii.gz -o fmri_brain_slices.nii.gz -zmin 34 -b 1000
                fslmaths fmri_brain_slices.nii.gz -Tmean fmri_brain_slices_mean.nii.gz

                tput setaf 2; echo "Run the preprocess physio script now!"
                tput sgr0;

            elif [ "$ind" == "2" ]; then

                tput setaf 2; echo "Preprocess physio script must be run already"
                tput sgr0;

                # remove the first 5 volumes
                if [ $(fslnvols fmri_crop.nii.gz) -eq 163 ]; then
                   sct_image -i fmri_crop.nii.gz -remove-vol 0,1,2,3,4
                fi

                # slice timing correction. Has to be done after the cropping
                slicetimer -i fmri_crop.nii.gz -o fmri_crop_slice.nii.gz -r 2.2 --tcustom=../../physio/physio"$d"/slice_order.txt -v

                # motion correction
                mcflirt -in fmri_crop_slice.nii.gz -out fmri_moco -refvol 0 -plots -report

            elif [ "$ind" == "3" ]; then
                
                tput setaf 2; echo "Running Distortion Correction. Will take over an hour"
                tput sgr0;

                # only take first five volumes to match five of blip-down image
                sct_image -i fmri_moco.nii.gz -keep-vol 0,1,2,3,4 -o fmri_AP.nii.gz
                
                # crop the frames
                sct_crop_image -i ../../fieldmap/fmap.nii.gz -o fmri_PA.nii.gz -zmin 36

                # register fieldmap brain to functional run in rigid regression
                flirt -in fmri_PA.nii.gz -ref fmri_AP.nii.gz -omat f2f.mat -v -dof 6
                flirt -in fmri_PA.nii.gz -ref fmri_AP.nii.gz -out fmri_PA.nii.gz -init f2f.mat -applyxfm -v

                % merge them to one file
                fslmerge -t input_topup.nii.gz fmri_AP.nii.gz fmri_PA.nii.gz

                #calculate epi distortion with topup
                topup --imain=input_topup.nii.gz --datain=../../fieldmap/acq_params.txt --config=$FSLDIR/etc/flirtsch/b02b0.cnf --out=fmri_topup --iout=unwarped.nii.gz -v

                #apply distortion correction to file
                applytopup --imain=fmri_moco.nii.gz --inindex=1 --method=jac --datain=../../fieldmap/acq_params.txt --topup=fmri_topup_fieldcoef --out=fmri_moco_dc.nii.gz -v

                # skullstrip
                bet fmri_moco_dc.nii.gz fmri_brain_moco.nii.gz -F -v

            elif [ "$ind" == "4" ]; then

                if [ "$d" == "1" ]; then

                    # take a mean func image only do this for the first run
                    fslmaths fmri_brain_moco.nii.gz -Tmean fmri_brain_moco_mean.nii.gz

                    # create matrix aligning brain to MNI
                    flirt -in fmri_brain_moco_mean.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -omat anat2template.mat -v
                    # if its the first run then register the masks to the space

                    % flip the transformation
                    convert_xfm -inverse anat2template.mat -omat template2anat.mat

                    apply the reversed transformations
                    flirt -in ../../../template/MNI152_T1_2mm_brain_WM.nii.gz -ref fmri_brain_moco_mean.nii.gz -out MNI152_WM.nii.gz -init template2anat.mat -applyxfm -v
                    flirt -in ../../../template/MNI152_T1_2mm_brain_GM.nii.gz -ref fmri_brain_moco_mean.nii.gz -out MNI152_GM.nii.gz -init template2anat.mat -applyxfm -v
                    flirt -in ../../../template/MNI152_T1_2mm_brain_CSF.nii.gz -ref fmri_brain_moco_mean.nii.gz -out MNI152_CSF.nii.gz -init template2anat.mat -applyxfm -v
                    
                    # this has to be done or it will create nan values in the physio processing and cause the FEAT to fail due to it
                    fslmaths MNI152_CSF.nii.gz -add 1 MNI152_CSF.nii.gz

                    # this will probably have to change to transforming the results to MNI space 
                    # because I dont like the interpolation errors on the atlas
                    # flirt -in ../../../template/ATLAS/AAL3/AAL3.nii.gz -ref fmri_brain_moco_mean.nii.gz -out AAL3_subject.nii.gz -init template2anat.mat -interp nearestneighbour -applyxfm -v

                    # now get average signal of each from the images
                    fslmeants -i fmri_brain_moco.nii.gz -o WM_regressor.txt -m MNI152_WM.nii.gz
                    fslmeants -i fmri_brain_moco.nii.gz -o CSF_regressor.txt -m MNI152_CSF.nii.gz

                    # rename the file
                    cp fmri_brain_moco.nii.gz fmri_brain_moco_reg.nii.gz

                    # now to registration for t1
                    # create matrix aligning brain to MNI
                    flirt -in fmri_brain_moco_mean.nii.gz -ref ../../anat/t1_brain.nii.gz -omat func2anat.mat -v

                    % flip the transformation
                    convert_xfm -inverse func2anat.mat -omat anat2func.mat

                    # apply the reversed transformations
                    flirt -in ../../anat/t1_brain.nii.gz -ref fmri_brain_moco_mean.nii.gz -out t1_subject_brain.nii.gz -init anat2func.mat -applyxfm -v
                    flirt -in ../../anat/t1_crop.nii.gz -ref fmri_brain_moco_mean.nii.gz -out t1_subject_skull.nii.gz -init anat2func.mat -applyxfm -v

                fi

                if [ "$d" != "1" ]; then

                    fslmaths fmri_brain_moco.nii.gz -Tmean fmri_brain_moco_mean.nii.gz

                    # here it is regsitering the other functional runs to the first run
                    flirt -in fmri_brain_moco_mean.nii.gz -ref ../func1/fmri_brain_moco_mean.nii.gz -omat anat2anat.mat -v

                    # apply the transformation to the mean data to get out reg
                    flirt -in fmri_brain_moco.nii.gz -ref ../func1/fmri_brain_moco_mean.nii.gz -out fmri_brain_moco_reg.nii.gz -init anat2anat.mat -applyxfm -v

                    # now get avergae signal of each from the images
                    fslmeants -i fmri_brain_moco_reg.nii.gz -o WM_regressor.txt -m ../func1/MNI152_WM.nii.gz 
                    fslmeants -i fmri_brain_moco_reg.nii.gz -o CSF_regressor.txt -m ../func1/MNI152_CSF.nii.gz

                    # copy the t1 into each subjects files
                    cp ../func1/t1_subject_brain.nii.gz t1_subject_brain.nii.gz
                    cp ../func1/t1_subject_skull.nii.gz t1_subject_skull.nii.gz

                fi

            elif [ "$ind" == "5" ]; then

                tput setaf 2; echo "Compute TSNR and sSNR in " "$DIREC$s"/func/"$d"
                tput sgr0; 

                # compute tsnr around just spine
                sct_fmri_compute_tsnr -i fmri_brain_moco.nii.gz -o fmri_brain_moco_mean_tsnr_subject.nii.gz

                flirt -in fmri_brain_moco_mean_tsnr_subject.nii.gz -ref ../../../template/MNI152_T1_2mm_brain.nii.gz -out fmri_brain_moco_mean_tsnr_MNI152.nii.gz -init ../func1/anat2template.mat -applyxfm -v
                
                sct_crop_image -i fmri_brain_moco_mean_tsnr_MNI152.nii.gz -m ../../../template/MNI152_T1_brain_mask.nii.gz -b 0 -o fmri_brain_moco_mean_tsnr_MNI152.nii.gz

                sct_compute_snr -i fmri_brain_moco.nii.gz -m fmri_brain_moco_mask.nii.gz \
                    -method mult -o fmri_brain_moco_mean_ssnr_mult -v 1

                sct_compute_snr -i fmri_brain_moco.nii.gz -m fmri_brain_moco_mask.nii.gz \
                    -method diff -vol 81,82 -o fmri_brain_moco_mean_ssnr_diff -v 1


            else

                tput setaf 1; 
                echo "Index not valid (should be 1 to 5)"
                tput sgr0; 

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