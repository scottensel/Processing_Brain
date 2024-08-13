%% template matching
clear all

%%% SPINE

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_007','SBSN_H_008','SBSN_H_010'}; 
zScore = 2.3;

copeFile = 'cope1.feat';
% copeFile = 'cope4.feat';
% copeFile = 'cope7.feat';

%% THINGS TO ADD

% gunzip('D:\SBSN\Data\Spine/template/PAM50_cervical_cord.nii.gz');
% [tempLevels, ~] = cbiReadNifti('D:\SBSN\Data\Spine/template/PAM50_cervical_cord.nii');

[brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');

allData = {};
for i = 1:length(subName)
    %direc = fullfile('/Volumes/MyPassport/Sub_Data/new_data/new_spine', subName{i}, 'func');
%     direc = fullfile('/Volumes/rnelshare/projects/human/brain_spine_stroke_SBSN/Data/sreya/Spine', subName{i}, 'func');
    direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func');

    subjectFolder = dir(direc);

    disp(subName{i})

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    fileCounter = 1;
    for folder = 3:length(subjectFolder)

        %is dir and name contains gfeat
        if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_two_FLOB1234')

            disp(subjectFolder(folder).name)

            fileName = strsplit(subjectFolder(folder).name, '.');

            if ~exist(fullfile(direc, subjectFolder(folder).name, copeFile, '/thresh_zstat1.nii'))

                gunzip(fullfile(direc, subjectFolder(folder).name,  copeFile, '/thresh_zstat1.nii.gz'));

            end
            [dataFile, ~] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));

            disp(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'))

            if contains(fileName{1}, 'smooth')
                allData{i}{fileCounter, 2} = fileName{1}(28:end);
            else
                allData{i}{fileCounter, 2} = fileName{1}(21:end);                
            end

            cAll = dataFile.*brainLevels;
            cAll(cAll>zScore) = 1;


            % number of active voxels
            allData{i}{fileCounter, 1}{1, 1} = squeeze(sum(cAll,[1,2]));

            fileCounter = fileCounter + 1;
        end

    end
end

% 
% allDataSmooth = allData;
% for i = 1:length(allData)
%     allData{i,1}(6:10, :) = [];
%     allDataSmooth{i,1}(1:5, :) = [];
% end
% 
% 
% save('savedData/allDataSLcope7', 'allData')
% save('savedData/allDataSmoothSLcope7', 'allDataSmooth')