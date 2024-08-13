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
echo -n "Enter the index of the step to perform (1 = Prepare for GLM, 2 = Prepare for seperate force GLM): "
tput sgr0;
read ind

naming=$(printf '%s' "${myFunc[@]}")

# For each subject
for s in "${sub[@]}"; do

		cd $DIREC$s"/func/"

        j=1

        tput setaf 2; echo "Prepare template files for analysis..."
        tput sgr0;

	    if [ "$ind" == "1" ]; then

            # here I run through the number of runs were are to combine specified when you start running this
            # always must be a minimum of two runs to do a second level analysis of per subject    
            for runNum in ${myFunc[@]}; do
    
                ## Generate fsf file from template
                if [ "$j" == "1" ]; then
          
                    for i in "../../template/second_level_template.fsf"; do
                        
                        sed -e 's@OUTDIR@'"level_two_FLOB"$naming""'@g' \
                            -e 's@PATH1@'$DIREC$s"/func/func"$runNum"/level_one_FLOB.feat"'@g' \
                            -e 's@THRESH_MASK@'""'@g' \
                            -e 's@NSUBJECTS@'${#myFunc[@]}'@g' <$i> design_leveltwo"$j".fsf 
    
                            #-e 's@THRESH_MASK@'$DIREC"template/MNI152_T1_2mm_brain_GM.nii.gz"'@g' \
                                #-e 's@THRESH_MASK@'$DIREC$s"/func/func1/MNI152_GM.nii.gz"'@g' \

                    done
    
                elif [ "$j" == "2" ]; then
    
                    for i in "design_leveltwo"$((j-1))".fsf"; do
    
                        sed -e 's@PATH2@'$DIREC$s"/func/func"$runNum"/level_one_FLOB.feat"'@g' \
                            -e 's@OUTLPATH@''@g' <$i> design_leveltwo"$j".fsf 
    
                    done
    
                    #echo design_leveltwo"$((j-1))"
                    rm design_leveltwo"$((j-1))".fsf
    
                else
    
                    for i in "design_leveltwo"$((j-1))".fsf"; do
     
                        sed -e 's@FEAT_PATH@'"# 4D AVW data or FEAT directory ("$j")\nset feat_files("$j") "$DIREC$s"/func/func"$runNum"/level_one_FLOB.feat\n\nFEAT_PATH"'@g' \
                            -e 's@EVG_PATH@'"# Higher-level EV value for EV 1 and input "$j"\nset fmri(evg"$j".1) 1\n\nEVG_PATH"'@g' \
                            -e 's@GROUPMEM_PATH@'"# Group membership for input "$j"\nset fmri(groupmem\."$j") 1\n\nGROUPMEM_PATH"'@g' <$i> design_leveltwo"$j".fsf 
    
                    done
    
                    rm design_leveltwo"$((j-1))".fsf
    
                fi           
     
                ((j+=1));
    
                if [ "$j" -gt "${#myFunc[@]}" ]; then
    
                    if [ -f design_leveltwo"$naming".fsf ]; then
                        # remove the old previous one because im not sure it will overwrite properly
                        rm design_leveltwo"$naming".fsf
                    fi
    
                    for i in "design_leveltwo"$((j-1))".fsf"; do
    
                        sed -e 's@FEAT_PATH@''@g' -e 's@EVG_PATH@''@g' -e 's@GROUPMEM_PATH@''@g' <$i> design_leveltwo"$naming".fsf 
    
                    done
    
                    #echo design_leveltwo"$((j-1))"
                    rm design_leveltwo"$((j-1))".fsf
    
                fi
    
            done
    
            tput setaf 2; echo "Run second level analysis"
            tput sgr0; 
    
            # Run the analysis using the fsf file
            feat design_leveltwo"$naming".fsf
    
		    tput setaf 2; echo "Done!" 
        	    tput sgr0;				 			

        elif [ "$ind" == "2" ]; then

            for runNum in ${myFunc[@]}; do
    
                ## Generate fsf file from template
                if [ "$j" == "1" ]; then
          
                    for i in "../../template/second_level_force_template.fsf"; do
                        
                        sed -e 's@OUTDIR@'"level_two_force"$naming""'@g' \
                            -e 's@PATH1@'$DIREC$s"/func/func"$runNum"/level_one_force.feat"'@g' \
                            -e 's@THRESH_MASK@'$DIREC"template/MNI152_T1_2mm_brain_GM.nii.gz"'@g' \
                            -e 's@NSUBJECTS@'${#myFunc[@]}'@g' <$i> design_leveltwo_force"$j".fsf 
    
                            #-e 's@THRESH_MASK@'$DIREC"template/MNI152_T1_2mm_brain_GM.nii.gz"'@g' \
    
                    done
    
                elif [ "$j" == "2" ]; then
    
                    for i in "design_leveltwo_force"$((j-1))".fsf"; do
    
                        sed -e 's@PATH2@'$DIREC$s"/func/func"$runNum"/level_one_force.feat"'@g' -e 's@OUTLPATH@''@g' <$i> design_leveltwo_force"$j".fsf 
    
                    done
    
                    #echo design_leveltwo_force"$((j-1))"
                    rm design_leveltwo_force"$((j-1))".fsf
    
                else
    
                    for i in "design_leveltwo_force"$((j-1))".fsf"; do
     
                        sed -e 's@FEAT_PATH@'"# 4D AVW data or FEAT directory ("$j")\nset feat_files("$j") "$DIREC$s"/func/func"$runNum"/level_one_force.feat\n\nFEAT_PATH"'@g' \
                            -e 's@EVG_PATH@'"# Higher-level EV value for EV 1 and input "$j"\nset fmri(evg"$j".1) 1\n\nEVG_PATH"'@g' \
                            -e 's@GROUPMEM_PATH@'"# Group membership for input "$j"\nset fmri(groupmem\."$j") 1\n\nGROUPMEM_PATH"'@g' <$i> design_leveltwo_force"$j".fsf 
    
                    done
    
                    rm design_leveltwo_force"$((j-1))".fsf
    
                fi           
     
                ((j+=1));
    
                if [ "$j" -gt "${#myFunc[@]}" ]; then
    
                    if [ -f design_leveltwo_force"$naming".fsf ]; then
                        # remove the old previous one because im not sure it will overwrite properly
                        rm design_leveltwo_force"$naming".fsf
                    fi
    
                    for i in "design_leveltwo_force"$((j-1))".fsf"; do
    
                        sed -e 's@FEAT_PATH@''@g' -e 's@EVG_PATH@''@g' -e 's@GROUPMEM_PATH@''@g' <$i> design_leveltwo_force"$naming".fsf 
    
                    done
    
                    #echo design_leveltwo_force"$((j-1))"
                    rm design_leveltwo_force"$((j-1))".fsf
    
                fi
    
            done
    
    
            tput setaf 2; echo "Run second level analysis"
            tput sgr0; 
    
            # Run the analysis using the fsf file
            feat design_leveltwo_force"$naming".fsf
  
            # move into folder so it doesnt take up space
            mv design_leveltwo_force"$naming".fsf level_two_force"$naming".gfeat/design_leveltwo_force"$naming".fsf 
  
		    tput setaf 2; echo "Done!" 
        	    tput sgr0;

        fi


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
