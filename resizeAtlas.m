clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAKE SURE TO CHANGE PATHS TO CORRECT FILES THESE ARE JUST EXAMPLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this folder you should have
addpath('D:\NHP_code\cbiNifti')

%this folder is located in brain preprocessing folder on server
addpath(genpath('D:\SBSN\Processing_Brain\processingFunctions'))

% this is the image dimensions you want to transform the atlas into
% so take the zstat image that you are using with the clusters
% TargetSpace = 'D:\SBSN\Data\Brain\SBSN_S_001\func\func1\level_one.feat\thresh_zstat1.nii';
gunzip('C:\Users\scott\Documents\Brain\SBSN_H_001\func\level_two123456+.gfeat\cope1.feat\stats\MNI_zstat1.nii.gz')
InputSpace = 'C:\Users\scott\Documents\Brain\SBSN_H_001\func\level_two123456+.gfeat\cope1.feat\stats\MNI_zstat1.nii';

% commands only work on .nii and not .nii.gz
% the input atlas we use
TargetFile = 'D:\SBSN\Data\Brain\template\ATLAS\AAL3\AAL3.nii';

% 
[sliceFileWhole, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\AAL3\AAL3.nii'); 
[sliceFile, ~] = cbiReadNifti('C:\Users\scott\Documents\Brain\SBSN_H_001\func\level_two123456+.gfeat\cope1.feat\stats\MNI_zstat1.nii'); 

% the output name to where it should go.
% it will automatically save it so make sure to not overwrite the data
OutputFile = 'D:\SBSN\Data\Brain\MNI_zstat1_reslice.nii';

% when reshaping an atlas keep the 4th input 0 because thats nearest
% neighbor
% if reshpaing an image change to 1
[OutVolume] = y_Reslice(InputFile, OutputFile, [], 0, TargetSpace);


%% now you can write code to match the zstat values to the location of the atlas
%% values of the codes to match the atlas to its section are located at
% P:\projects\human\brain_spine_stroke\data\Brain\template\ATLAS\AAL3\AAL3.nii.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%