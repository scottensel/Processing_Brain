%% template matching
clear all

%%% BRAIN

 %%%%%%%%%%%%%
% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
% subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_044','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 
subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_007','SBSN_S_044','SBSN_S_008','SBSN_S_009'}; 



fullMask = [];
for i = 1:length(subName)

    direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'anat');

    subjectFolder = dir(direc);

    disp(subName{i})

    if ~exist(fullfile(direc, 't1_lesion_mask_MNI.nii'))

        gunzip(fullfile(direc, 't1_lesion_mask_MNI.nii.gz'));

    end

    [dataFile, hdr] = cbiReadNifti(fullfile(direc, 't1_lesion_mask_MNI.nii'));
   
    % these are the subjects who had lesions on the opposit side
    if ismember(i, [3 5 9 10])
        dataFile = flip(dataFile, 1);
    end
           
    if i == 1
        fullMask = dataFile;
        hdr1 = hdr;

    else

        fullMask = fullMask + dataFile;

    end
    
end


cbiWriteNifti(fullfile('D:\SBSN\Data\Brain', 'summed_lesion_mask_all2.nii'), fullMask, hdr1);


