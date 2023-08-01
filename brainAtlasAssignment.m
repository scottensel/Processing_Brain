%% MATCH TO BRAIN ATLAS
clear all
close all

%% ANY PATH YOU HAVE TO CHANGE
% Path where you will want to grab second level folders from
secondLevelPath = 'C:\Users\scott\Documents\Brain';

% ATLAS PATH (points to where you have both atlases
atlasPath = 'D:\SBSN\Data\Brain\template\ATLAS\';

% this path where you have the cbiNifti folder
addpath('D:\NHP_code\cbiNifti')

% what value you want to threshold at
zScore = 1.5;

%% TODO make it loop over each directory and combination you want to try
% - add cluster seperation
% - save files
% - make plots of z-score for different run combinations
secondLevelPathsAll = uipickfiles('FilterSpec', secondLevelPath);

allZscores = {};
for idx = 1:length(secondLevelPathsAll)
 
    % this is the image dimensions you want to transform the atlas into
    % so take the zstat image that you are using with the clusters
    gunzip([secondLevelPathsAll{idx}, '\cope1.feat\MNI_thresh_zstat1.nii.gz'])

    
    %% GRECIEUS ATLAS

    atlasFolders = dir([atlasPath, 'GREICIUS\']);
    greiciusAtlas = {};
    counter = 1;
    % just loading in all the atlases from this set
    for i = 3:length(atlasFolders)
        gunzip([atlasPath, 'GREICIUS\', atlasFolders(i).name, '\', atlasFolders(i).name, '.nii.gz'])
        [greiciusAtlas{counter}, ~] = cbiReadNifti([atlasPath, 'GREICIUS\', atlasFolders(i).name, '\', atlasFolders(i).name, '.nii']);
        greName{counter} = atlasFolders(i).name;
        counter = counter + 1;
    end

    % load in the actual image
    [zstat, ~] = cbiReadNifti([secondLevelPathsAll{idx}, '\cope1.feat\MNI_thresh_zstat1.nii']); 

    % loop through each atalas and compute values
    atlasResults = {};
    for i = 1:length(greiciusAtlas)
        zScores = abs(zstat(greiciusAtlas{i} == 1));

        % edge cases
        if isempty(zScores) || length(zScores) == 1 || length(zScores(zScores > zScore)) == 0
            atlasResults{i, 1} = 0; % percent of that region active
            atlasResults{i, 2} = 0; % mean z-score
            atlasResults{i, 3} = 0; % std of z-score
            atlasResults{i, 4} = 0; % total voxels z-score
            atlasResults{i, 5} = 0; % total voxels z-score
            atlasResults{i, 6} = greName{i}; 
        else
            atlasResults{i, 1} = (sum(zScores > zScore, 'omitnan')/length(find(greiciusAtlas{i} == 1))) * 100; % percent of that region active
            atlasResults{i, 2} = mean(zScores(zScores > zScore), 'omitnan'); % mean z-score
            atlasResults{i, 3} = std(zScores(zScores > zScore), 'omitnan'); % std of z-score
            atlasResults{i, 4} = sum(zScores > zScore, 'omitnan'); % total voxels z-score
            atlasResults{i, 5} = zScores(zScores > zScore); % total voxels z-score
            atlasResults{i, 6} = greName{i}; 
        end

    end
    
    %% SAVE THIS OR PLOT FROM THESE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    allZscores{idx, 1} = atlasResults(:, 5);
    allZscores{idx, 2} = atlasResults(:, 6);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % can be used to order the values based on criteria
    % not used for now
    percentActiveGRE = [atlasResults{:,1}]';
    % maxZscore = [atlasResults{:,2}]';
    meanZscoreGRE = [atlasResults{:,2}]';
    stdZscoreGRE = [atlasResults{:,3}]';
    totalVoxelsGRE = [atlasResults{:,4}]';
    anatGRE = [atlasResults(:,6)];

    
    %% ALL ATLAS

    gunzip([atlasPath, 'AAL3\AAL3.nii.gz'])
    % commands only work on .nii and not .nii.gz
    % the input atlas we use
    [aalAtlas, ~] = cbiReadNifti([atlasPath, 'AAL3\AAL3.nii']); 
    atlasList = readcell([atlasPath, 'AAL3\AAL3.nii.txt']);
    atlasList(:,3) = [];

    atlasResults2 = {};
    for i = 1:length(atlasList)
        zScores = abs(zstat(aalAtlas == i));

        % edge cases
        if isempty(zScores) || length(zScores) == 1 || length(zScores(zScores > zScore)) == 0
            atlasResults2{i, 1} = 0; % percent of that region active
            atlasResults2{i, 2} = 0; % mean z-score
            atlasResults2{i, 3} = 0; % std of z-score
            atlasResults2{i, 4} = 0; % total voxels z-score
            atlasResults2{i, 5} = 0; % total voxels z-score
            atlasResults2{i, 6} = atlasList{i, 2};
        else
            atlasResults2{i, 1} = (sum(zScores > zScore, 'omitnan')/length(find(aalAtlas == i))) * 100; % percent of that region active
            atlasResults2{i, 2} = mean(zScores(zScores > zScore), 'omitnan'); % mean z-score
            atlasResults2{i, 3} = std(zScores(zScores > zScore), 'omitnan'); % std of z-score
            atlasResults2{i, 4} = sum(zScores > zScore, 'omitnan'); % total voxels z-score
            atlasResults2{i, 5} = zScores(zScores > zScore); % total voxels z-score
            atlasResults2{i, 6} = atlasList{i, 2};
        end

    end

    % can be used to order the values based on criteria
    % not used for now
    percentActiveAAL = [atlasResults2{:,1}]';
    % maxZscore = [atlasResults{:,2}]';
    meanZscoreAAL = [atlasResults2{:,2}]';
    stdZscoreAAL = [atlasResults2{:,3}]';
    totalVoxelsAAL = [atlasResults2{:,4}]';
    anatAAL = [atlasResults2(:,6)];


    % this can sort the columns based on activation
%     [B,I] = sort(meanZscore, 'descend');
%     meanZscore = round(meanZscore(I), 3, 'significant');
%     percentActive = percentActive(I);
%     % maxZscore = maxZscore(I);
%     stdZscore = stdZscore(I);
%     totalVoxels = totalVoxels(I);
%     anat = anat(I);


%     T = table(percentActiveAAL, meanZscoreAAL, stdZscoreAAL, totalVoxelsAAL, anatAAL);
%     T.Properties.VariableNames = {'Percent Active' 'Mean Z-score' 'Std Z-score' '# Voxels' 'Anatomy'};
% 
%     writetable(T, 'C:\Users\scott\Documents\Brain\SBSN_H_001\func\level_two123456+.gfeat\cope1.feat\stats\atlasAssignment.xlsx')
    
    
end