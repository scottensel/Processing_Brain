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
echo -n "Enter the index of the step to perform (1 = Prepare for FLOB GLM (this one), 2 = Prepare for FLOB force GLM (this one)): "
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

            j=1
            k=1
            # changes the template file that it loops through
            if [ "$ind" == "2" ]; then
                levelFile="level_one_force_FLOB.feat"
                outputName="level_two_force_FLOB"
                templateName="second_level_cope_force_FLOB_template.fsf"
                threshmask="MNI152_T1_brain_mask.nii"
                # i have to treat each cope as its own subject in this and only choose the first cope for some and include the last one for toehrs
            fi

            # here I run through the number of runs were are to combine specified when you start running this
            # always must be a minimum of two runs to do a second level analysis of per subject
            for runNum in ${myFunc[@]}; do


                for copeNum in 1 4 7; do

                    # starts with the first run specified
                    ## Generate fsf file from template
                    if [ "$j" == "1" ] && [ "$copeNum" == "1" ]; then
        
                        # here selecting the original named template file
                        for i in "../../template/"$templateName; do
                            
                            # now we set some standard paths ands masks 
                            # set path 1 as the first run
                            # and resave the file as a new template inside the folder
                            sed -e 's@OUTDIR@'"$outputName$naming"'@g' \
                                -e 's@PATH1@'$DIREC$s"/func/func"$runNum"/"$levelFile"/stats/cope"$copeNum".nii.gz"'@g' \
                                -e 's@THRESH_MASK@'$DIREC"template/"$threshmask""'@g' \
                                -e 's@NSUBJECTS@'$(( ${#myFunc[@]} * 3 ))'@g' <$i> design_leveltwo_force_FLOB"$k".fsf 
                                #-e 's@NSUBJECTS@'${#myFunc[@]}'@g' <$i> design_leveltwo_force_FLOB"$j".fsf 
        

                        done
                    

                    # must need a second run so this is when j=2
                    elif [ "$j" == "1" ] && [ "$copeNum" == "4" ]; then

                        # take the template file we just named in the previous statement
                        for i in "design_leveltwo_force_FLOB"$((k-1))".fsf"; do
                            
                            # now we sepcificy the second path we chose and create a new template file
                            sed -e 's@PATH2@'$DIREC$s"/func/func"$runNum"/"$levelFile"/stats/cope"$copeNum".nii.gz"'@g' \
                                -e 's@OUTLPATH@''@g' <$i> design_leveltwo_force_FLOB"$k".fsf 
        
                        done
                        
                        # remove the old template file as its not needed
                        #echo design_leveltwo_force_FLOB"$((j-1))"
                        rm design_leveltwo_force_FLOB"$((k-1))".fsf


                    elif [ "$j" == "1" ] && [ "$copeNum" == "7" ]; then

                        # take the template file we just named in the previous statement                
                        for i in "design_leveltwo_force_FLOB"$((k-1))".fsf"; do
         
                            # here we have to edit the file to add in more than two runs
                            # this is so we can choose whatever amount of runs we want and add into the file instead of delete
                            sed -e 's@FEAT_PATH@'"# 4D AVW data or FEAT directory ("$k")\nset feat_files("$k") "$DIREC$s"/func/func"$runNum"/"$levelFile"/stats/cope"$copeNum".nii.gz""\n\nFEAT_PATH"'@g' \
                                -e 's@EVG_PATH@'"# Higher-level EV value for EV 1 and input "$k"\nset fmri(evg"$k".1) 1\n\nEVG_PATH"'@g' \
                                -e 's@GROUPMEM_PATH@'"# Group membership for input "$k"\nset fmri(groupmem\."$k") 1\n\nGROUPMEM_PATH"'@g' <$i> design_leveltwo_force_FLOB"$k".fsf 
        
                        done
        
                        # remove the old template file as its not needed
                        rm design_leveltwo_force_FLOB"$((k-1))".fsf
        
                    else

                        # take the template file we just named in the previous statement                
                        for i in "design_leveltwo_force_FLOB"$((k-1))".fsf"; do
         
                            # here we have to edit the file to add in more than two runs
                            # this is so we can choose whatever amount of runs we want and add into the file instead of delete
                            sed -e 's@FEAT_PATH@'"# 4D AVW data or FEAT directory ("$k")\nset feat_files("$k") "$DIREC$s"/func/func"$runNum"/"$levelFile"/stats/cope"$copeNum".nii.gz""\n\nFEAT_PATH"'@g' \
                                -e 's@EVG_PATH@'"# Higher-level EV value for EV 1 and input "$k"\nset fmri(evg"$k".1) 1\n\nEVG_PATH"'@g' \
                                -e 's@GROUPMEM_PATH@'"# Group membership for input "$k"\nset fmri(groupmem\."$k") 1\n\nGROUPMEM_PATH"'@g' <$i> design_leveltwo_force_FLOB"$k".fsf 
        
                        done
        
                        # remove the old template file as its not needed
                        rm design_leveltwo_force_FLOB"$((k-1))".fsf
        
                    fi           
         

                    ((k+=1));
                    

                    # one statement to make sure the file is named properly
                    if [ "$k" -gt "$(( ${#myFunc[@]} * 3 ))" ]; then
        
                        # checking if a file exists already
                        if [ -f design_leveltwo_force_FLOB"$naming".fsf ]; then
        
                            # remove the old previous one because im not sure it will overwrite properly
                            rm design_leveltwo_force_FLOB"$naming".fsf
                        fi
                        
                        # set some final paths to empty
                        for i in "design_leveltwo_force_FLOB"$((k-1))".fsf"; do
        
                            sed -e 's@FEAT_PATH@''@g' -e 's@EVG_PATH@''@g' -e 's@GROUPMEM_PATH@''@g' <$i> design_leveltwo_force_FLOB"$naming".fsf 
        
                        done
        
                        #echo design_leveltwo"$((j-1))"
                        rm design_leveltwo_force_FLOB"$((k-1))".fsf
        
                    fi


                done

                ((j+=1));

            done

            tput setaf 2; echo "Run second level analysis"
            tput sgr0; 
    
            # Run the analysis using the fsf file
            feat design_leveltwo_force_FLOB"$naming".fsf

            # move into folder so it doesnt take up space
            mv design_leveltwo_force_FLOB"$naming".fsf  "$outputName$naming".gfeat/design_leveltwo_force_FLOB"$naming".fsf 

            tput setaf 2; echo "Done!" 
                tput sgr0;

        fi


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
