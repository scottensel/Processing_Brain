%% template matching
close all
clear all

%%% BRAIN

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_007','SBSN_H_008','SBSN_H_010'}; 

copeFile = 'cope1.feat';

[brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');

allData = {};
for i = 1:length(subName)

    direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func');

    subjectFolder = dir(direc);

    disp(subName{i})

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    fileCounter = 1;
    for folder = 3:length(subjectFolder)

        %is dir and name contains gfeat
        if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_two_force_FLOB1234')

            disp(subjectFolder(folder).name)

            fileName = strsplit(subjectFolder(folder).name, '.');

            if ~exist(fullfile(direc, subjectFolder(folder).name, copeFile, 'thresh_zstat1.nii'))

                gunzip(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii.gz'));

            end

            [dataFile, hdr] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));

            nii_info = niftiinfo(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));
            affine = nii_info.Transform.T';  % Transpose to match MATLAB's orientation


            if i == 1
                dataFile = flip(dataFile, 1);
            end

            disp(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'))

            numVoxelsSeperate = [];
            magSeperate = [];
            for j = 1:8


                % Apply the mask
                masked_data = dataFile .* (brainLevels==j);
                
                % Find the max value and its voxel index
                [max_val, linear_idx] = max(masked_data(:));
                
                % Convert linear index to 3D subscripts
                [x, y, z] = ind2sub(size(dataFile), linear_idx);


                mni_coords = affine * ([x, y, z, 1]' - 1);  % subtract 1 for 0-based indexing
                % Output
                fprintf('Max value = %.4f at voxel [%d, %d, %d]\n', max_val, x, y, z);

figure;
p = patch(isosurface(dataFile, 0.5));
isonormals(dataFile, p);
set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
daspect([1 1 1]);
view(3); axis tight;
camlight; lighting gouraud;
title('3D Isosurface Rendering');
hold on
p2 = patch(isosurface(brainLevels, 0.5));
isonormals(brainLevels, p2);
            end

        end

    end
end


% figure;
% hBar=barh([mean(actVoxelsSeg4)', mean(actVoxelsSeg6)']);
% X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
% hold on  %4 runs
% hEB = errorbar([mean(actVoxelsSeg4)', mean(actVoxelsSeg6)'], X, [(std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)))',  (std(actVoxelsSeg6)/sqrt(length(actVoxelsSeg6)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% % errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
% randVec = (-1 + (1+1)*rand(4,1))/10;
% scatter(actVoxelsSeg4(1:4,:), [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 30, 'k','o','filled'); 
% scatter(actVoxelsSeg6(1:4,:), [randVec+X(1,2), randVec+X(2,2), randVec+X(3,2), randVec+X(4,2), randVec+X(5,2), randVec+X(6,2), randVec+X(7,2), randVec+X(8,2)], 30, 'k','o','filled'); 
% randVec = (-1 + (1+1)*rand(3,1))/10;
% scatter(actVoxelsSeg4(5:end,:), [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 60, 'k','x'); 
% scatter(actVoxelsSeg6(5:end,:), [randVec+X(1,2), randVec+X(2,2), randVec+X(3,2), randVec+X(4,2), randVec+X(5,2), randVec+X(6,2), randVec+X(7,2), randVec+X(8,2)], 60, 'k','x'); 
% set (gca,'YDir','reverse')
% yticks(1:length(1:8)); yticklabels({'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'});
% ylabel('Brain Area')
% xlabel('Active Voxels');
% title(sprintf('Average Active Voxel 4 vs 6 Runs combined'));
% make_pretty

