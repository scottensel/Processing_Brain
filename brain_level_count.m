%%
close all

%% Frame Displacement
clear all

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_017','SBSN_H_018','SBSN_H_019'}; 

allData = {};
for i = 1:length(subName)

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    for j = 0:6
        direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);
        
        motionData = importdata(fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)], 'fmri_moco.txt'));
%         motionData = motionData(11:end,:);

        dataDiff = motionData(2:end,:)-motionData(1:(end-1),:);
        FD = sum(abs(dataDiff), 2);

        FD = FD(5:end,:);

        % number of active voxels
        allData{i, 1}{j+1, 1} = [mean(reshape(FD, [], 1),'omitnan'), std(reshape(FD, [], 1),'omitnan')];
        allData{i, 1}{j+1, 2} = [subName{i}, ' func', num2str(j)];

    
    end
end


for i = 1:length(allData)

    for j = 1:length(allData{i,1})

        frameD(i,j) = allData{i,1}{j,1}(1);

    end

end

% all runs but rest rud
disp("all task runs")
mean(mean(frameD(:,2:end))) 
std(mean(frameD(:,2:end)))/sqrt(length(mean(frameD(:,2:end))))

% only the rest run
disp('Rest Run')
mean(frameD(:, 1))
std(frameD(:, 1))/sqrt(length(frameD(:,1)))

% means across runs
disp("mean across all runs")
mean(frameD, 1) 
std(frameD, 1)/sqrt(length(mean(frameD)))

%% TSNR

clear all

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_019','SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_017','SBSN_H_018'}; 

subSplit = 5;

% fmri_brain_moco_mean_tsnr_MNI152.nii.gz

gunzip('D:\SBSN\Data\Brain\template\MNI152_T1_brain_mask.nii.gz');
[brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\MNI152_T1_brain_mask.nii');

allData = {};
for i = 1:length(subName)

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    for j = 0:6
        direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);
    
        subjectFolder = dir(direc);
    
        disp(subName{i})

        if ~exist(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii'))

            gunzip(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii.gz'));

        end

        [dataFile, ~] = cbiReadNifti(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii'));

        disp(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii'))

        mag = dataFile(brainLevels>=1);

        % number of active voxels
        allData{i, 1}{j+1, 1} = [mean(reshape(mag, [], 1),'omitnan'), std(reshape(mag, [], 1),'omitnan')];
        allData{i, 1}{j+1, 2} = [subName{i}, ' func', num2str(j)];

    
    end
end


for i = 1:length(allData)
    for j = 1:length(allData{i,1})

        tsnr(i,j) = allData{i,1}{j,1}(1);

    end

end


plotCreator(tsnr, 1:7, subSplit);
make_pretty
xlim([0.75,7.25])
ylabel('TSNR')
xlabel('Run Number');
title(sprintf('TSNR of Each Run'));
xticklabels({'Rest','1','2','3','4','5','6'})

% all runs but rest run
disp("all task runs")
mean(mean(tsnr(:, 2:end))) 
std(mean(tsnr(:, 2:end)))/sqrt(length(mean(tsnr(:,2:end))))

% only the rest run
disp("rest runs")
mean(tsnr(:, 1))
std(tsnr(:, 1))/sqrt(length(tsnr(:, 1)))

% means across runs
disp("all runs")
mean(tsnr, 1) 
std(tsnr, 1)/sqrt(length(mean(tsnr)))

% Save the plot as a PNG image
saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_tsnr.png');
saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_tsnr.svg');

% Define the run combinations (1 to 6)
runCombinations = 1:6;

% Spearman's correlation for active voxels
[rho_activeVoxels, pval_activeVoxels] = corr(runCombinations', mean(tsnr(:, 2:end))', 'Type', 'Spearman');

% Display results for active voxels
disp('Spearman correlation for active voxels:');
disp('Correlation coefficients (rho):');
disp(rho_activeVoxels);
disp('P-values:');
disp(pval_activeVoxels);

% runRepeatedMeasuresANOVA(tsnr)


%% template matching
clear all

%%% SPINE

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
% young first and then old at the end
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_019','SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_017','SBSN_H_018'};

zScore = 3.1;
subSplit = 5;

copeFile = 'cope1.feat';

% THINGS TO ADD
% [brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');
% 
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};

[brainLevels2, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\ventral_DMN\ventral_DMN.nii');

hmatPath = 'D:\SBSN\Data\Brain\template\HMAT_website\HMAT_2mm.nii';
[HMAT, ~] = cbiReadNifti(hmatPath);

brainNames = {'M1 (R)','M1 (L)','S1 (R)','S1 (L)', 'SMA (R)','SMA (L)','preSMA (R)','preSMA (L)', 'PMd (R)','PMd (L)','PMv (R)','PMv (L)'};
% clsoe
nRegions = numel(brainNames);   % 12

% this is how I need to have it go back and forth between the two
brainLevels = HMAT;

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
        if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_two_force_FLOB')

            disp(subjectFolder(folder).name)

            fileName = strsplit(subjectFolder(folder).name, '.');

            if ~exist(fullfile(direc, subjectFolder(folder).name, copeFile, 'thresh_zstat1.nii'))

                gunzip(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii.gz'));

            end

            [dataFile, hdr] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));
            
            if i == 1
                dataFile = flip(dataFile, 1);
            end

            disp(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'))

            numVoxels = sum(sum(sum((dataFile>=zScore).*(brainLevels>=1))));
            mag = dataFile(brainLevels>=1);


            %C ontrol areas
            numVoxels2 = sum(sum(sum((dataFile>=zScore).*(brainLevels2>=1))));
            mag2 = dataFile(brainLevels2>=1);
%             numVoxels3 = sum(sum(sum((dataFile>=zScore).*(brainLevels3>=1))));
%             mag3 = dataFile(brainLevels3>=1);

            numVoxelsSeperate = [];
            magSeperate = [];
            for j = 1:nRegions
                numVoxelsSeperate(j) = sum(sum(sum((dataFile>=zScore).*(brainLevels==j))));
                numVoxelsSeperate(j) = numVoxelsSeperate(j)/sum(sum(sum(brainLevels==j)))*100;

                var = dataFile(brainLevels==j);
                magSeperate(j) = mean(var(var>zScore));  
            end

            % number of active voxels
            allData{i, 1}{fileCounter, 1} = [numVoxels/sum(sum(sum(brainLevels>=1)))*100, mean(mag(mag>zScore)), std(mag(mag>zScore))];
            allData{i, 1}{fileCounter, 2} = subjectFolder(folder).name;
            allData{i, 1}{fileCounter, 3} = [numVoxelsSeperate; magSeperate];

            allData{i, 1}{fileCounter, 4} = [numVoxels2/sum(sum(sum(brainLevels2>=1)))*100, mean(mag2(mag2>zScore)), std(mag2(mag2>zScore))];
%             allData{i, 1}{fileCounter, 5} = [numVoxels3/sum(sum(sum(brainLevels3>=1)))*100, mean(mag3(mag3>zScore)), std(mag3(mag3>zScore))];

            fileCounter = fileCounter + 1;
        end

    end
end


for i = 1:length(allData)
    for j = 1:length(allData{i,1})

        activeVoxels(i,j) = allData{i,1}{j,1}(1);
        zScores(i,j) = allData{i,1}{j,1}(2);

        activeVoxels2(i,j) = allData{i,1}{j,4}(1);
        zScores2(i,j) = allData{i,1}{j,4}(2);
%         activeVoxels3(i,j) = allData{i,1}{j,5}(1);
%         zScores3(i,j) = allData{i,1}{j,5}(2);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        actVoxelsSeg2(i,:) = allData{i,1}{1,3}(1,:);
        zSeg2(i,:) = allData{i,1}{1,3}(2,:);

        actVoxelsSeg3(i,:) = allData{i,1}{2,3}(1,:);
        zSeg3(i,:) = allData{i,1}{2,3}(2,:);

        actVoxelsSeg5(i,:) = allData{i,1}{4,3}(1,:);
        zSeg5(i,:) = allData{i,1}{4,3}(2,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        actVoxelsSeg4(i,:) = allData{i,1}{3,3}(1,:);
        zSeg4(i,:) = allData{i,1}{3,3}(2,:);

        actVoxelsSeg6(i,:) = allData{i,1}{5,3}(1,:);
        zSeg6(i,:) = allData{i,1}{5,3}(2,:);
    end

end


% segs = {actVoxelsSeg2, actVoxelsSeg3, actVoxelsSeg4, actVoxelsSeg5, actVoxelsSeg6};
% runLabels = [2 3 4 5 6];
% K = numel(segs);
% nRegions = size(segs{1}, 2);
% 
% % Numeric summaries
% sigMat  = false(K, K, nRegions);   % significance (logical)
% diffMat =  nan(K, K, nRegions);    % scalar effect size summary (A-B)
% ciLo    =  nan(K, K, nRegions);
% ciHi    =  nan(K, K, nRegions);
% 
% % Optional: store the full bootstrap distribution (upper triangle)
% diffDist = cell(K, K, nRegions);   % each cell holds a 1xN vector
% 
% for r = 1:nRegions
%     for a = 1:K
%         for b = a+1:K
%             [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans( ...
%                 segs{a}(:, r), segs{b}(:, r), 10000, 0.05, 16);
% 
%             % --- scalar summary for the matrix ---
%             eff = mean(diffSampMeans);         % or median(diffSampMeans)
%             diffMat(a, b, r) = eff;
%             ciLo(a, b, r)    = ci95(1);
%             ciHi(a, b, r)    = ci95(2);
%             sigMat(a, b, r)  = logical(rejectNull);
% 
%             % keep full distribution (optional)
%             diffDist{a, b, r} = diffSampMeans(:)';  % store as row vector
% 
%             % --- mirror to lower triangle ---
%             diffMat(b, a, r) = -eff;
%             % CI for (B-A) is [-hi, -lo]
%             ciLo(b, a, r)    = -ci95(2);
%             ciHi(b, a, r)    = -ci95(1);
%             sigMat(b, a, r)  = sigMat(a, b, r);
%             if ~isempty(diffSampMeans)
%                 diffDist{b, a, r} = -diffSampMeans(:)';  % sign-flipped distribution
%             end
%         end
%     end
% end
% 
% % Now you can visualize a simple run×run significance matrix per region:
% regionIdx = 1;
% figure;
% imagesc(double(sigMat(:,:,regionIdx)));
% axis equal tight; colorbar;
% xticks(1:K); yticks(1:K);
% xticklabels(runLabels); yticklabels(runLabels);
% title(sprintf('Significance by Run (Region: %s)', brainNames{regionIdx}));
% 
% % Or count how many regions are significant for each run pair:
% sigCount = sum(sigMat, 3);
% figure;
% imagesc(sigCount);
% axis equal tight; colorbar;
% xticks(1:K); yticks(1:K);
% xticklabels(runLabels); yticklabels(runLabels);
% title('Count of Regions with Significant Differences (Run × Run)');



% for i = 1:nRegions
% 
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg3(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg4(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg5(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg6(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg3(:), actVoxelsSeg4(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg3(:), actVoxelsSeg5(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg3(:), actVoxelsSeg6(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:), actVoxelsSeg5(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:), actVoxelsSeg6(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg5(:), actVoxelsSeg6(:), 10000, 0.05, 10);
%     brainNames{i}
    ci95, rejectNull    
% % end


% 
%     [p,h] = signrank(actVoxelsSeg2(:), actVoxelsSeg6(:));
%     p, h
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg4(:), 100000, 0.05, 10);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg5(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg2(:), actVoxelsSeg6(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg3(:), actVoxelsSeg4(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg3(:), actVoxelsSeg5(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg3(:), actVoxelsSeg6(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:), actVoxelsSeg5(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:), actVoxelsSeg6(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull
% 
%     [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg5(:), actVoxelsSeg6(:), 100000, 0.05);
% %     brainNames{i}
%     ci95, rejectNull   

plotCreator(activeVoxels, 1:5, subSplit);
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('Active Voxels');
title(sprintf('Average Active Successive runs'));
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_success.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_success.svg');
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_success_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_success_z', num2str(zScore), '.svg']);

% Step 1: Detect changepoints based on changes in the slope ('linear')
% Adjust 'MaxNumChanges' based on your data (max number of changes to detect)


% Define the run combinations (1 to 6)
runCombinations = 1:5;

% Spearman's correlation for active voxels
[rho_activeVoxels, pval_activeVoxels] = corr(runCombinations', mean(activeVoxels)', 'Type', 'Spearman');

% Display results for active voxels
disp('Spearman correlation for active voxels:');
disp('Correlation coefficients (rho):');
disp(rho_activeVoxels);
disp('P-values:');
disp(pval_activeVoxels);

% 
% runRepeatedMeasuresANOVA(activeVoxels)
% runRepeatedMeasuresANOVA(zScores)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time = [1, 2, 3, 4, 5];
figure;
for i = 1:length(subName)
    findSlopePtsSingle(activeVoxels(i, :), time, i, subSplit)
    hold on
end
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('Active Voxels');
title(sprintf('Line of Best Subject'));
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% Save the plot as a PNG image
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_SUPP_fig', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_SUPP_fig', num2str(zScore), '.svg']);



time = [1, 2, 3, 4, 5];
figure;
for i = 1:length(subName)
    findSlopePtsSingle(zScores(i, :), time, i, subSplit)
    hold on
end
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('zScore');
title(sprintf('Line of Best Subject'));
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% Save the plot as a PNG image
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_SUPP_fig', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_SUPP_fig', num2str(zScore), '.svg']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plotCreator(diff(activeVoxels')', 1:4, subSplit);
% % figure;
% % plot(diff(activeVoxels'), '.-r')
% % hold on
% % plot(mean(diff(activeVoxels')'), 'k')
% % errorbar(1:4,mean(diff(activeVoxels')'), std(diff(activeVoxels')')/sqrt(length(activeVoxels)), 'Color','black')
% make_pretty
% xlim([0.75,4.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Difference Average Active Successive runs'));
% xticks(1:4)
% xticklabels({'2-3','3-4','4-5','5-6'})
% 
% % Save the plot as a PNG image
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_diff.png');
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_diff.svg');
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_diff_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_diff_z', num2str(zScore), '.svg']);
% 


plotCreator(zScores, 1:5, subSplit);
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('Z-Score');
title(sprintf('Average Zscore Successive runs'));
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% [rho,pval] = corr(mean(activeVoxels)', 'Spearman')

% % Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_success.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_success.svg');
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_success_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_success_z', num2str(zScore), '.svg']);


% Spearman's correlation for Z-scores
[rho_ZScores, pval_ZScores] = corr(runCombinations', mean(zScores)', 'Type', 'Spearman');

% Display results for Z-scores
disp('Spearman correlation for Z-scores:');
disp('Correlation coefficients (rho):');
disp(rho_ZScores);
disp('P-values:');
disp(pval_ZScores);

% plotCreator(diff(zScores')', 1:4, subSplit);
% make_pretty
% xlim([0.75,4.25])
% xlabel('Run Combination')
% ylabel('zScores');
% title(sprintf('Difference Average zScores Successive runs'));
% xticks(1:4)
% xticklabels({'2-3','3-4','4-5','5-6'})
% 
% % Save the plot as a PNG image
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_diff.png');
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_diff.svg');
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_diff_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_diff_z', num2str(zScore), '.svg']);


time = [1, 2, 3, 4, 5];
figure;
findSlopePts(activeVoxels, time)
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('Active Voxels');
title(sprintf('Line of Best Fit Active Voxels Successive runs'));
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% Save the plot as a PNG image
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_slope_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_slope_z', num2str(zScore), '.svg']);



time = [1, 2, 3, 4, 5];
figure;
findSlopePts(zScores, time)
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('Z-Score');
title(sprintf('Line of Best Fit Zscore Successive runs'));
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% Save the plot as a PNG image
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_slope_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_slope_z', num2str(zScore), '.svg']);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plotCreator(activeVoxels2, 1:5, subSplit);
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Auditory Control - Average Active Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% 
% time = [1, 2, 3, 4, 5];
% figure;
% 
% findSlopePts(activeVoxels2, time)
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Auditory Control - Line of Best Fit Active Voxels Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% 
% plotCreator(activeVoxels3, 1:5, subSplit);
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Frontal Control - Average Active Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% 
% time = [1, 2, 3, 4, 5];
% figure;
% findSlopePts(activeVoxels3, time)
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Frontal Control - Line of Best Fit Active Voxels Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% 
% plotCreator(zScores2, 1:5, subSplit);
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Z-Score');
% title(sprintf('Auditory Control - Average Zscore Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% 
% time = [1, 2, 3, 4, 5];
% figure;
% findSlopePts(zScores2, time)
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Auditory Control - Line of Best Fit Active Voxels Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% 
% plotCreator(zScores3, 1:5, subSplit);
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Z-Score');
% title(sprintf('Frontal Control - Average Zscore Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})

% % [rho,pval] = corr(mean(activeVoxels)', 'Spearman'
% time = [1, 2, 3, 4, 5];
% figure;
% findSlopePts(zScores3, time)
% make_pretty
% xlim([0.75, 5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Frontal Control - Line of Best Fit Active Voxels Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})


time = [1, 2, 3, 4, 5];
figure;
findSlopePts(activeVoxels2, time)
hold on
findSlopePts(activeVoxels, time)
errorbar(time, mean(activeVoxels2, 'omitnan'), std(activeVoxels2, 'omitnan')/sqrt(length(activeVoxels2)), '.', 'Color', 'black', 'Marker', 'none')
errorbar(time, mean(activeVoxels, 'omitnan'), std(activeVoxels, 'omitnan')/sqrt(length(activeVoxels)), '.', 'Color', 'black', 'Marker', 'none')
make_pretty
xlim([0.75,5.25])
xlabel('Run Combination')
ylabel('Active Voxels');
xticks(1:5)
xticklabels({'1-2','1-3','1-4','1-5','1-6'})
title(sprintf('Ventral DMN - Average Active Successive runs'));
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_control_slope_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_control_slope_z', num2str(zScore), '.svg']);

% Define the run combinations (1 to 6)
runCombinations = 1:5;

% Spearman's correlation for active voxels
[rho_activeVoxels, pval_activeVoxels] = corr(runCombinations', mean(activeVoxels2)', 'Type', 'Spearman');

% Display results for active voxels
disp('Spearman correlation for active voxels c1-c2:');
disp('Correlation coefficients (rho):');
disp(rho_activeVoxels);
disp('P-values:');
disp(pval_activeVoxels);

% 
% time = [1, 2, 3, 4, 5];
% figure;
% findSlopePts(activeVoxels3, time)
% hold on
% findSlopePts(activeVoxels, time)
% make_pretty
% xlim([0.75,5.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% title(sprintf(['Line of Best Fit Active Voxels Successive runs ', spineStr{[1, 7, 8]}]'));
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Spine_voxel_vert_slope_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Spine_voxel_vert_slope_z', num2str(zScore), '.svg']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure;
hBar=barh([mean(actVoxelsSeg4)', mean(actVoxelsSeg6)']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(actVoxelsSeg4)', mean(actVoxelsSeg6)'], X, [(std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)))',  (std(actVoxelsSeg6)/sqrt(length(actVoxelsSeg6)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:subSplit,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).';              

scatter(actVoxelsSeg4(1:subSplit,:), Y, 30, 'k','o','filled'); 
scatter(actVoxelsSeg6(1:subSplit,:), Y2, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).';              

scatter(actVoxelsSeg4(subSplit+1:end,:), Y, 60, 'k','x'); 
scatter(actVoxelsSeg6(subSplit+1:end,:), Y2, 60, 'k','x'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain Area')
xlabel('Active Voxels');
title(sprintf('Average Active Voxel 4 vs 6 Runs combined'));
make_pretty

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.svg');
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_area_z', num2str(zScore), '.svg']);


% [h,p,ci,stats] = ttest(actVoxelsSeg4(:, 5), actVoxelsSeg4(:, 6));
% h,p,ci,stats
% [h,p,ci,stats] = ttest(actVoxelsSeg6(:, 5), actVoxelsSeg6(:, 6));
% h,p,ci,stats
alphas = [0.05, 0.01, 0.001];
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};

for i = 1:2:nRegions
    
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:, i), actVoxelsSeg4(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end
for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg6(:, i), actVoxelsSeg6(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end
for i = 1:nRegions
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:, i), actVoxelsSeg6(:, i), 10000, 0.05, 16);
    brainNames{i}
    ci95, rejectNull

end

figure;
hBar=barh([mean(zSeg4, 'omitnan')', mean(zSeg6, 'omitnan')']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(zSeg4, 'omitnan')', mean(zSeg6, 'omitnan')'], X, [(std(zSeg4, 'omitnan')/sqrt(length(zSeg4)))',  (std(zSeg6, 'omitnan')/sqrt(length(zSeg6)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% errorbar(mean(actVoxelsSeg4), 1:subSplit, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:subSplit,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).';   

scatter(zSeg4(1:subSplit,:), Y, 30, 'k','o','filled'); 
scatter(zSeg6(1:subSplit,:), Y2, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).'; 

scatter(zSeg4(subSplit+1:end,:), Y, 60, 'k','x'); 
scatter(zSeg6(subSplit+1:end,:), Y2, 60, 'k','x'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain Area')
xlabel('Z-score');
title(sprintf('Average Z-Score 4 vs 6 Runs combined'));
make_pretty

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.svg');
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_area_z', num2str(zScore), '.svg']);


for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSeg4(:, i), zSeg4(:, i+1), 10000, 0.001, 16);
    brainNames{i}
    rejectNull

end
for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSeg6(:, i), zSeg6(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};
for i = 1:nRegions
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSeg4(:, i), zSeg6(:, i), 10000, 0.05, 16);
    brainNames{i}
    ci95, rejectNull

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
hBar=barh([mean(actVoxelsSeg4)', mean(actVoxelsSeg5)']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(actVoxelsSeg4)', mean(actVoxelsSeg5)'], X, [(std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)))',  (std(actVoxelsSeg5)/sqrt(length(actVoxelsSeg5)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% errorbar(mean(actVoxelsSeg4), 1:subSplit, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:subSplit,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).';   

scatter(actVoxelsSeg4(1:subSplit,:), Y, 30, 'k','o','filled'); 
scatter(actVoxelsSeg5(1:subSplit,:), Y2, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).';   

scatter(actVoxelsSeg4(subSplit+1:end,:), Y, 60, 'k','x'); 
scatter(actVoxelsSeg5(subSplit+1:end,:), Y2, 60, 'k','x'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain Area')
xlabel('Active Voxels');
title(sprintf('Average Active Voxel 4 vs 5 Runs combined'));
make_pretty

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.svg');
% % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel45_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel45_area_z', num2str(zScore), '.svg']);



for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg5(:, i), actVoxelsSeg5(:, i+1), 10000, 0.01, 16);
    brainNames{i}
    rejectNull

end

% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};
for i = 1:nRegions
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSeg4(:, i), actVoxelsSeg5(:, i), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end


figure;
hBar=barh([mean(zSeg4, 'omitnan')', mean(zSeg5, 'omitnan')']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(zSeg4, 'omitnan')', mean(zSeg5, 'omitnan')'], X, [(std(zSeg4, 'omitnan')/sqrt(length(zSeg4)))',  (std(zSeg5, 'omitnan')/sqrt(length(zSeg5)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:subSplit,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';   
Y2 = randVec + X(1:nRegions, 2).';   

scatter(zSeg4(1:subSplit,:), Y, 30, 'k','o','filled'); 
scatter(zSeg5(1:subSplit,:), Y2, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
Y = randVec + X(1:nRegions, 1).';              
Y2 = randVec + X(1:nRegions, 2).';   

scatter(zSeg4(subSplit+1:end,:), Y, 60, 'k','x'); 
scatter(zSeg5(subSplit+1:end,:), Y2, 60, 'k','x'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain Area')
xlabel('Z-score');
title(sprintf('Average Z-Score 4 vs 5 Runs combined'));
make_pretty

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.svg');
% % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore45_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore45_area_z', num2str(zScore), '.svg']);

for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSeg5(:, i), zSeg5(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end

% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};
for i = 1:nRegions
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSeg4(:, i), zSeg5(:, i), 10000, 0.05, 16);
    brainNames{i}
    ci95, rejectNull

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% THIS IS 4 RUNS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure;
% hBar=barh([mean(actVoxelsSeg4)']);
% X=get(hBar,'XData').'+[hBar.XOffset];
% hold on  %4 runs
% hEB = errorbar([mean(actVoxelsSeg4)'], X, [(std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% % errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
% randVec = (-1 + (1+1)*rand(9,1))/10;
% Y = randVec + X(1:nRegions, 1).';
% scatter(actVoxelsSeg4, Y, 30, 'k','o','filled'); 
% set (gca,'YDir','reverse')
% yticks(1:length(1:nRegions)); yticklabels(brainNames);
% ylabel('Brain Area')
% xlabel('Active Voxels');
% title(sprintf('Average Active Voxel 4'));
% make_pretty
% 
% % Save the plot as a PNG image
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.png');
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.svg');
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel4_area_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel4_area_z', num2str(zScore), '.svg']);
% 
% 
% figure;
% hBar=barh(mean(zSeg4, 'omitnan')');
% X=get(hBar,'XData').'+[hBar.XOffset];
% hold on  %4 runs
% hEB = errorbar([mean(zSeg4, 'omitnan')'], X, [(std(zSeg4, 'omitnan')/sqrt(length(zSeg4)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% % errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
% randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:4,:), 1),1))/10;
% Y = randVec + X(1:nRegions, 1).';
% scatter(zSeg4(1:4,:), Y, 30, 'k','o','filled'); 
% randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
% Y = randVec + X(1:nRegions, 1).';
% scatter(zSeg4(subSplit+1:end,:), Y, 60, 'k','x'); 
% set (gca,'YDir','reverse')
% yticks(1:length(1:nRegions)); yticklabels(brainNames);
% ylabel('Brain Area')
% xlabel('Z-score');
% title(sprintf('Average Z-Score 4'));
% make_pretty
% 
% % Save the plot as a PNG image
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.png');
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.svg');
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore4_area_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore4_area_z', num2str(zScore), '.svg']);

%%%%%%%%%%%%%%%%%%%%%% THIS IS 4 RUNS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% h = barh(flip(cerAvg([1 2 3 4 6 5 7 8]),1),'FaceColor',[.35 .35 .35]);  %6 runs
% %legend('4R','6R','Location','eastoutside')
% title (sprintf('All subjects - average : %d runs combined',i+1))
% yticks(1:8)
% xlim([0 50])
% yticklabels({'Cerebellum (R)','Cerebellum (L)','BG (R)','BG (L)','Thalamus (R)','Thalamus (L)','SM (R)','SM (L)'})

% this is all the verts
figure;
hBar=barh([mean(actVoxelsSeg2)', mean(actVoxelsSeg3)', mean(actVoxelsSeg4)', mean(actVoxelsSeg5)', mean(actVoxelsSeg6)']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(actVoxelsSeg2)', mean(actVoxelsSeg3)', mean(actVoxelsSeg4)', mean(actVoxelsSeg5)', mean(actVoxelsSeg6)'], X, [(std(actVoxelsSeg2)/sqrt(length(actVoxelsSeg2)))', (std(actVoxelsSeg3)/sqrt(length(actVoxelsSeg3)))', (std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)))',  (std(actVoxelsSeg5)/sqrt(length(actVoxelsSeg5)))',  (std(actVoxelsSeg6)/sqrt(length(actVoxelsSeg6)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% randVec = (-1 + (1+1)*rand(7,1))/10;
% scatter(actVoxelsSeg4, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1)], 30, 'k','o','filled'); 
% scatter(actVoxelsSeg6, [randVec+X(1,2), randVec+X(2,2), randVec+X(3,2), randVec+X(4,2)], 30, 'k','o','filled');
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:subSplit,:), 1),1))/10;
Y1 = randVec + X(1:nRegions, 1).';
Y2 = randVec + X(1:nRegions, 2).';
Y3 = randVec + X(1:nRegions, 3).';
Y4 = randVec + X(1:nRegions, 4).';
Y5 = randVec + X(1:nRegions, 5).';
scatter(actVoxelsSeg2(1:subSplit,:), Y1, 30, 'k','o','filled'); 
scatter(actVoxelsSeg3(1:subSplit,:), Y2, 30, 'k','o','filled'); 
scatter(actVoxelsSeg4(1:subSplit,:), Y3, 30, 'k','o','filled'); 
scatter(actVoxelsSeg5(1:subSplit,:), Y4, 30, 'k','o','filled'); 
scatter(actVoxelsSeg6(1:subSplit,:), Y5, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
Y1 = randVec + X(1:nRegions, 1).';
Y2 = randVec + X(1:nRegions, 2).';
Y3 = randVec + X(1:nRegions, 3).';
Y4 = randVec + X(1:nRegions, 4).';
Y5 = randVec + X(1:nRegions, 5).';
scatter(actVoxelsSeg2(subSplit+1:end,:), Y1, 60, 'k','x'); 
scatter(actVoxelsSeg3(subSplit+1:end,:), Y2, 60, 'k','x'); 
scatter(actVoxelsSeg4(subSplit+1:end,:), Y3, 60, 'k','x'); 
scatter(actVoxelsSeg5(subSplit+1:end,:), Y4, 60, 'k','x'); 
scatter(actVoxelsSeg6(subSplit+1:end,:), Y5, 60, 'k','x'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain level')
xlabel('Active Voxels');
title(sprintf('Average Active Voxel 4 vs 6 Runs combined'));
make_pretty

% % Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_all_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_all_area.svg');
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_all_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_voxel_all_area_z', num2str(zScore), '.svg']);



figure;
hBar=barh([mean(zSeg2, 'omitnan')', mean(zSeg3, 'omitnan')', mean(zSeg4, 'omitnan')', mean(zSeg5, 'omitnan')', mean(zSeg6, 'omitnan')']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(zSeg2, 'omitnan')', mean(zSeg3, 'omitnan')', mean(zSeg4, 'omitnan')', mean(zSeg5, 'omitnan')', mean(zSeg6, 'omitnan')'], X, [(std(zSeg2, 'omitnan')/sqrt(length(zSeg2)))', (std(zSeg3, 'omitnan')/sqrt(length(zSeg3)))', (std(zSeg4, 'omitnan')/sqrt(length(zSeg4)))', (std(zSeg5, 'omitnan')/sqrt(length(zSeg5)))',  (std(zSeg6, 'omitnan')/sqrt(length(zSeg6)))'], 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(1:subSplit,:), 1),1))/10;
Y1 = randVec + X(1:nRegions, 1).';
Y2 = randVec + X(1:nRegions, 2).';
Y3 = randVec + X(1:nRegions, 3).';
Y4 = randVec + X(1:nRegions, 4).';
Y5 = randVec + X(1:nRegions, 5).';
scatter(zSeg2(1:subSplit,:), Y1, 30, 'k','o','filled'); 
scatter(zSeg3(1:subSplit,:), Y2, 30, 'k','o','filled'); 
scatter(zSeg4(1:subSplit,:), Y3, 30, 'k','o','filled'); 
scatter(zSeg5(1:subSplit,:), Y4, 30, 'k','o','filled'); 
scatter(zSeg6(1:subSplit,:), Y5, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(size(actVoxelsSeg4(subSplit+1:end,:), 1),1))/10;
Y1 = randVec + X(1:nRegions, 1).';
Y2 = randVec + X(1:nRegions, 2).';
Y3 = randVec + X(1:nRegions, 3).';
Y4 = randVec + X(1:nRegions, 4).';
Y5 = randVec + X(1:nRegions, 5).';
scatter(zSeg2(subSplit+1:end,:), Y1, 60, 'k','x'); 
scatter(zSeg3(subSplit+1:end,:), Y2, 60, 'k','x'); 
scatter(zSeg4(subSplit+1:end,:), Y3, 60, 'k','x'); 
scatter(zSeg5(subSplit+1:end,:), Y4, 60, 'k','x'); 
scatter(zSeg6(subSplit+1:end,:), Y5, 60, 'k','x'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain level')
xlabel('Z-score');
title(sprintf('Average Z-Score 4 vs 6 Runs combined'));
make_pretty
% 

% Save the plot as a PNG image
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_all_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_all_area_z', num2str(zScore), '.svg']);



%%%%%%

% % laterality index
% LI = (left_activation - right_activation) / ...
%      (left_activation + right_activation);
% 
% LI = +1 → Activity is fully left-lateralized
% 
% LI = –1 → Activity is fully right-lateralized
% 
% LI = 0 → Bilateral or symmetric activation

% Define left and right region indices
% Indices assumed from your labels: {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'}
leftIdx = [1:2:nRegions];
rightIdx = [2:2:nRegions];
regionNames = brainNames(1:2:nRegions);

% Calculate Laterality Index for Pre and Post
LI_pre = (actVoxelsSeg4(:,leftIdx) - actVoxelsSeg4(:,rightIdx)) ./ ...
         (actVoxelsSeg4(:,leftIdx) + actVoxelsSeg4(:,rightIdx));
LI_post = (actVoxelsSeg6(:,leftIdx) - actVoxelsSeg6(:,rightIdx)) ./ ...
          (actVoxelsSeg6(:,leftIdx) + actVoxelsSeg6(:,rightIdx));

% Average and SEM
meanLI_pre = mean(LI_pre, 1);
semLI_pre = std(LI_pre, 0, 1) / sqrt(size(LI_pre, 1));
meanLI_post = mean(LI_post, 1);
semLI_post = std(LI_post, 0, 1) / sqrt(size(LI_post, 1));

% Plotting
figure;
hBar = bar([meanLI_pre; meanLI_post]', 'grouped');
hold on;

% Add error bars
ngroups = size([meanLI_pre; meanLI_post]', 1);
nbars = size([meanLI_pre; meanLI_post]', 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));


% Prepare the data for errorbar plotting
yvals = [meanLI_pre; meanLI_post];
errors = [semLI_pre; semLI_post];

% Then plot:

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, yvals(i,:), errors(i,:), 'k.', 'LineWidth', 1);
end

ylabel('Laterality Index (LI)');
xlabel('Brain Region');
xticks(1:length(regionNames));
xticklabels(regionNames);
legend({'4 runs', '6 runs'}, 'Location', 'northeast');
title('Laterality Index Pre vs Post');
ylim([-1, 1]);
make_pretty  % Optional custom styling

% % Save the figure
% Save the plot as a PNG image
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_all_area_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_all_area_z', num2str(zScore), '.svg']);
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\LI_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\LI_area_z', num2str(zScore), '.svg']);


%% DICE matching
clear all

%%% SPINE

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_019','SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_017','SBSN_H_018'};

zScore = 3.1;
subSplit = 5;

copeFile = 'cope1.feat';

% [brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};

hmatPath = 'D:\SBSN\Data\Brain\template\HMAT_website\HMAT_2mm.nii';
[HMAT, ~] = cbiReadNifti(hmatPath);

brainNames = {'M1 (R)','M1 (L)','S1 (R)','S1 (L)', 'SMA (R)','SMA (L)','preSMA (R)','preSMA (L)', 'PMd (R)','PMd (L)','PMv (R)','PMv (L)'};

nRegions = numel(brainNames);   % 12


% this is how I need to have it go back and forth between the two
brainLevels = HMAT;

allData = {};
for i = 1:length(subName)

    direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func');

    subjectFolder = dir(direc);

    disp(subName{i})

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    fileCounter = 1;
    diceCell = {};
    for folder = 3:length(subjectFolder)

        %is dir and name contains gfeat
        if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_two_force_FLOB')

            disp(subjectFolder(folder).name)

            fileName = strsplit(subjectFolder(folder).name, '.');

            if ~exist(fullfile(direc, subjectFolder(folder).name, copeFile, 'thresh_zstat1.nii'))

                gunzip(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii.gz'));

            end

            [dataFile, hdr] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));
            
            if i == 1
                dataFile = flip(dataFile, 1);
            end

            disp(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'))


            diceCell{fileCounter} = dataFile; 

            fileCounter = fileCounter + 1;
        end

    end

    diceValues = [];
    diceValuesSeperate = [];
    for j = 1:length(diceCell)-1

        diceValues(j) = dice((diceCell{j} >= zScore).*(brainLevels>=1), (diceCell{j+1} >= zScore).*(brainLevels>=1));

        for k = 1:nRegions
%             numVoxelsSeperate(j) = sum(sum(sum((dataFile>=zScore).*(brainLevels==j))));

            section = dice((diceCell{j} >= zScore).*(brainLevels==k), (diceCell{j+1} >= zScore).*(brainLevels==k));

            if isempty(section)

                diceValuesSeperate(j, k) = 0;

            else

                diceValuesSeperate(j, k) = section;

            end
            

        end

    end

    % number of active voxels
    allDice(i,:) = diceValues;
    allDiceSep(:,:, i) = diceValuesSeperate;

end

plotCreator(allDice, 1:4, subSplit);
make_pretty
xlim([0.75,4.25])
xlabel('Run Combination')
ylabel('DICE Score');
title(sprintf('Average Active Successive runs'));
xticks(1:4)
xticklabels({'2vs3','3vs4','4vs5','5vs6'})
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
saveas(gcf, ['D:\SBSN\Manuscript\plots\DICE\All_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\DICE\All_area_z', num2str(zScore), '.svg']);

for j = 1:nRegions

    % run x area x subject
    allDiceSep2 = squeeze(allDiceSep(:, j, :))';
    
    
    plotCreator(allDiceSep2, 1:4, subSplit);
    make_pretty
    xlim([0.75,4.25])
    xlabel('Run Combination')
    ylabel('DICE Score');
    title(sprintf(['DICE Score Across Runs' brainNames{j}]));
    xticks(1:4)
    xticklabels({'2vs3','3vs4','4vs5','5vs6'})
    % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    saveas(gcf, ['D:\SBSN\Manuscript\plots\DICE\', brainNames{j}, 'area_z', num2str(zScore), '.png']);
    saveas(gcf, ['D:\SBSN\Manuscript\plots\DICE\', brainNames{j}, 'area_z', num2str(zScore), '.svg']);

end


%% template matching
clear all

%%% BRAIN

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_001','SBSN_H_002','SBSN_H_003','SBSN_H_004','SBSN_H_019','SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_017','SBSN_H_018'}; 

zScore = 0.0;
subSplit = 5;

% THINGS TO ADD
% [brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');
% 
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};


hmatPath = 'D:\SBSN\Data\Brain\template\HMAT_website\HMAT_2mm.nii';
[HMAT, ~] = cbiReadNifti(hmatPath);

brainNames = {'M1 (R)','M1 (L)','S1 (R)','S1 (L)', 'SMA (R)','SMA (L)','preSMA (R)','preSMA (L)', 'PMd (R)','PMd (L)','PMv (R)','PMv (L)'};

nRegions = numel(brainNames);   % 12

% this is how I need to have it go back and forth between the two
brainLevels = HMAT;

allData = {};
for i = 1:length(subName)

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    for j = 0:6
        direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);

%         direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);
    
        subjectFolder = dir(direc);
    
        disp(subName{i})

        fileCounter = 1;
        for folder = 3:length(subjectFolder)
    
            %is dir and name contains gfeat
            if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_one_force_FLOB') && (j > 0)
    
                disp(subjectFolder(folder).name)
    
                fileName = strsplit(subjectFolder(folder).name, '.');
    
%                 if ~exist(fullfile(direc, subjectFolder(folder).name, 'stats\zfstat1.nii'))
    
                gunzip(fullfile(direc, subjectFolder(folder).name,  'stats\zfstat1.nii.gz'));
    
%                 end
    
                [dataFile, ~] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  'stats\zfstat1.nii'));

                if i == 1
                    dataFile = flip(dataFile, 1);
                end

                disp(fullfile(direc, subjectFolder(folder).name, 'stats\zfstat1.nii'))
    
                numVoxels = sum(sum(sum((dataFile>=zScore).*(brainLevels>=1))));
                mag = dataFile(brainLevels>=1);
    
                % number of active voxels
                allData{i, 1}{j+1, 1} = [numVoxels/sum(sum(sum(brainLevels>=1)))*100, mean(mag(mag>zScore)), std(mag(mag>zScore))];
                allData{i, 1}{j+1, 2} = subjectFolder(folder).name;
    
                fileCounter = fileCounter + 1;


            elseif subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_one_FLOB') && (j == 0)


                disp(subjectFolder(folder).name)
    
                fileName = strsplit(subjectFolder(folder).name, '.');
    
                if ~exist(fullfile(direc, subjectFolder(folder).name, 'stats\zstat1.nii'))
    
                    gunzip(fullfile(direc, subjectFolder(folder).name,  'stats\zstat1.nii.gz'));
    
                end
    
                [dataFile, ~] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  'stats\zstat1.nii'));

                if i == 1
                    dataFile = flip(dataFile, 1);
                end

                disp(fullfile(direc, subjectFolder(folder).name, 'stats\zstat1.nii'))
    
                numVoxels = sum(sum(sum((dataFile>=zScore).*(brainLevels>=1))));
                mag = dataFile(brainLevels>=1);
    
                % number of active voxels
                allData{i, 1}{j+1, 1} = [numVoxels/sum(sum(sum(brainLevels>=1)))*100, mean(mag(mag>zScore)), std(mag(mag>zScore))];
                allData{i, 1}{j+1, 2} = subjectFolder(folder).name;
    
                fileCounter = fileCounter + 1;                

            end
    
        end
    end
end

for i = 1:length(allData)
    for j = 1:length(allData{i,1})

        activeVoxels(i,j) = allData{i,1}{j,1}(1);
        zScores(i,j) = allData{i,1}{j,1}(2);
         
    end
        
end
% for i = 1:length(allData1)
% 
%     activeVoxels(i,1) = allData{i,1}{1,1}(1);
%     zScores(i,1) = allData{i,1}{1,1}(2);
%         
%     activeVoxels(i,2) = allData2{i,1}{1,1}(1);
%     zScores(i,2) = allData2{i,1}{1,1}(2);
%         
% end

% [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(activeVoxels(:,1), mean(activeVoxels(:,2:end),2), 10000, 0.001);
% rejectNull
% [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zScores(:,1), mean(zScores(:,2:end),2), 10000, 0.001);
% rejectNull
disp("this is active voxel rest vs mean of other runs")
[h,p,ci,stats] = ttest(activeVoxels(:,1), mean(activeVoxels(:,2:end), 2, 'omitnan'));
h,p,ci,stats
disp("this is zScore rest vs mean of other runs")
[h,p,ci,stats] = ttest(zScores(:,1), mean(zScores(:,2:end), 2, 'omitnan'));
h,p,ci,stats

activeVoxels2 = [activeVoxels(:,1), mean(activeVoxels(:,2:end),2)];
zScores2 = [zScores(:,1), mean(zScores(:,2:end),2)];

mean(activeVoxels2, 'omitnan')
mean(zScores2, 'omitnan')
std(activeVoxels2)/sqrt(length(activeVoxels2))
std(zScores2, 'omitnan')/sqrt(length(zScores2))

plotCreator(activeVoxels2, 1:2, subSplit);
% figure;
% plot(activeVoxels2', '.-r')
% hold on
% plot(mean(activeVoxels2), 'k')
% errorbar(1:2, mean(activeVoxels2), std(activeVoxels2)/sqrt(length(activeVoxels2)), 'Color','black')
make_pretty
xlim([0.75,2.25])
ylabel('Active Voxels')
xlabel('Group');
title(sprintf('Mean Active Voxel'));
% make_pretty
xticklabels({'Task-Free','Task'})
xticks(1:2)

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_control.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_control.svg');
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_voxel_control_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_voxel_control_z', num2str(zScore), '.svg']);


plotCreator(zScores2, 1:2, subSplit);
% figure;
% plot(zScores2', '.-r')
% hold on
% plot(mean(zScores2), 'k')
% errorbar(1:2, mean(zScores2), std(zScores2)/sqrt(length(zScores2)), 'Color','black')
make_pretty
xlim([0.75,2.25])
ylabel('Z-Score')
xlabel('Group');
title(sprintf('Mean Z-Score'));
make_pretty
xticklabels({'Task-Free','Task'})
xticks(1:2)

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_control.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_control.svg');
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_zscore_control_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_zscore_control_z', num2str(zScore), '.svg']);


plotCreator(activeVoxels, 1:7, subSplit);
% figure;
% plot(activeVoxels', '.-r')
% hold on
% plot(mean(activeVoxels), 'k')
% errorbar(1:7, mean(activeVoxels), std(activeVoxels)/sqrt(length(activeVoxels)), 'Color','black')
make_pretty
xlim([0.75,7.25])
ylabel('Active Voxels')
xlabel('Group');
title(sprintf('Mean Active Voxel'));
make_pretty
xticklabels({'Rest','1','2','3','4','5','6'})

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_active_control_all.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_active_control_all.svg');
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_active_control_all_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_active_control_all_z', num2str(zScore), '.svg']);



plotCreator(zScores, 1:7, subSplit);
% figure;
% plot(zScores', '.-r')
% hold on
% plot(mean(zScores), 'k')
% errorbar(1:7, mean(zScores), std(zScores)/sqrt(length(zScores)), 'Color','black')
make_pretty
xlim([0.75,7.25])
ylabel('Z-Score')
xlabel('Group');
title(sprintf('Mean Z-Score'));
make_pretty
xticklabels({'Rest','1','2','3','4','5','6'})

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_control_all.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_control_all.svg');
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_zscore_control_all_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\Manuscript\plots\control\Brain_zscore_control_all_z', num2str(zScore), '.svg']);

%%
function plotCreator(value, len, subsNum)
    % This function plots a sine wave given a frequency and duration.
    % Inputs:
    %   frequency - Frequency of the sine wave
    %   duration  - Duration (in seconds) of the sine wave to plot

    % Define the time vector [0.2 0.5 0.9 0.2]

%     Red (Full Red): [1, 0, 0]
%     Slightly Lighter Red: [1, 0.2, 0.2]
%     Lighter Red: [1, 0.4, 0.4]
%     Medium Light Red: [1, 0.6, 0.6]
%     Light Red: [1, 0.75, 0.75]
%     Very Light Red: [1, 0.85, 0.85]
%     Almost Pink (Lightest Red): [1, 0.9, 0.9]


%     Blue (Full Blue): [0, 0, 1]
%     Slightly Lighter Blue: [0.2, 0.2, 1]
%     Lighter Blue: [0.4, 0.4, 1]
%     Medium Light Blue: [0.6, 0.6, 1]
%     Light Blue: [0.75, 0.75, 1]
%     Very Light Blue: [0.85, 0.85, 1]
%     Almost White (Lightest Blue): [0.9, 0.9, 1]

    opac = {[1, 0.5, 0.5]; [1, 0.15, 0.15]; [1, 0.25, 0.25]; [1, 0.35, 0.35]; [1, 0.45, 0.45]; [1, 0.55, 0.55]};

    figure;
    plot(value(1,:)', '.-r', 'MarkerSize', 15)
    hold on
    for i = 2:length(value) 
        
        if i > subsNum
            plot(value(i,:)', 'x-r', 'MarkerSize', 15)
            hold on
        else
            plot(value(i,:)', '.-r', 'MarkerSize', 15)
            hold on
        end

    end
    hold on
    plot(mean(value, 'omitnan'), 'k')
    errorbar(len, mean(value, 'omitnan'), std(value, 'omitnan')/sqrt(length(value)), 'Color', 'black')

end


function findSlopePts(data, time)

%     time = [1, 2, 3, 4, 5]; % Example time data
    [changepts,~] = findchangepts(mean(data), 'Statistic', 'linear', 'MaxNumChanges', 2);
    
    % Step 2: Plot data with detected changepoints
%     figure;
    plot(mean(data), 'o', 'DisplayName', 'Data');
    hold on;
    xline(time(changepts), '--r', 'DisplayName', 'Changepoint');
    xlabel('Time');
    ylabel('Response');
    title('Detected Changepoints');
    legend show;
    
    % Step 3: Perform piecewise linear regression for each segment
    fittedResponse = zeros(size(mean(data))); % Initialize fitted response array
    segments = [1, changepts, length(mean(data))]; % Define segments including changepoints
    
    slopes = []; % To store the slopes for each segment
    mA = mean(data);
    for i = 1:length(segments)-1
        % Get indices for the current segment
        idx = segments(i):segments(i+1);
        
        % Fit a linear model to the segment
        p = polyfit(time(idx), mA(idx), 1);
        
        % Get the fitted values for this segment
        fittedResponse(idx) = polyval(p, time(idx));
        
        % Store the slope for statistical testing later
        slopes = [slopes; p(1)]; % Store the slope (first coefficient of polyfit)
    end
    
    % Step 4: Plot the piecewise regression fit
    plot(time, fittedResponse, '-r', 'DisplayName', 'Piecewise Fit');
    legend show;
    
    % Step 5: Statistical Test for the Slopes (t-test for slopes close to zero)
    alpha = 0.05; % Significance level
    disp('Statistical Test Results for Each Segment:');
    for i = 1:length(slopes)
        fprintf('Segment %d: Slope = %.4f\n', i, slopes(i));
        
        % Perform a t-test to check if the slope is significantly different from zero
        % Null hypothesis: slope = 0 (indicating a plateau)
        [h, p_value] = ttest(slopes(i), 0, 'Alpha', alpha);
        
        if h == 0
            fprintf('Segment %d: The slope is NOT significantly different from zero (p = %.4f).\n', i, p_value);
        else
            fprintf('Segment %d: The slope is significantly different from zero (p = %.4f).\n', i, p_value);
        end
    end

end


function findSlopePtsSingle(data, time, i, subSplit)

%     time = [1, 2, 3, 4, 5]; % Example time data
    [changepts,~] = findchangepts(data, 'Statistic', 'linear', 'MaxNumChanges', 2);
    
    % Step 2: Plot data with detected changepoints
%     figure;

    if i > subSplit
        plot(data, 'xr', 'MarkerSize', 15);

    else

        plot(data, '.r', 'MarkerSize', 15);

    end
    hold on;
%     xline(time(changepts), '--r', 'DisplayName', 'Changepoint');
    xlabel('Time');
    ylabel('Response');
    title('Detected Changepoints');
%     legend show;
    
    % Step 3: Perform piecewise linear regression for each segment
    fittedResponse = zeros(size(data)); % Initialize fitted response array
    segments = [1, changepts, length(data)]; % Define segments including changepoints
    
    slopes = []; % To store the slopes for each segment
    mA = data;
    for i = 1:length(segments)-1
        % Get indices for the current segment
        idx = segments(i):segments(i+1);
        
        % Fit a linear model to the segment
        p = polyfit(time(idx), mA(idx), 1);
        
        % Get the fitted values for this segment
        fittedResponse(idx) = polyval(p, time(idx));
        
        % Store the slope for statistical testing later
        slopes = [slopes; p(1)]; % Store the slope (first coefficient of polyfit)
    end
    
    % Step 4: Plot the piecewise regression fit
    plot(time, fittedResponse, '-r');

end

function runRepeatedMeasuresANOVA(inputData)
    % This function performs a repeated measures ANOVA for 5, 6, or 7 time points
    % on the provided input data for 7 subjects. It also applies a linear contrast.
    % 
    % Inputs:
    %   inputData - A 7x5, 7x6, or 7x7 matrix where rows are subjects and columns are time points
    
    % Step 1: Validate the input data
    [numSubjects, numTimePoints] = size(inputData);
    
    if numSubjects ~= 7
        error('Input data must have 7 subjects (rows).');
    end
    
    if numTimePoints ~= 5 && numTimePoints ~= 6 && numTimePoints ~= 7
        error('Input data must have 5, 6, or 7 time points (columns).');
    end

    % Step 2: Define the subject identifiers
    subject = (1:numSubjects)';  % 7 subjects

    % Step 3: Create the data table
    % Convert the matrix to table format, with columns for each time point
    timePointNames = arrayfun(@(n) sprintf('Time%d', n), 1:numTimePoints, 'UniformOutput', false);
    dataTable = array2table(inputData, 'VariableNames', timePointNames);
    dataTable.Subject = subject;

    % Step 4: Fit the repeated measures model
    % The formula dynamically handles the number of time points
    formula = sprintf('Time1-Time%d ~ 1', numTimePoints);
    rm = fitrm(dataTable, formula, 'WithinDesign', 1:numTimePoints);

    % Step 5: Perform repeated measures ANOVA
    ranovaResults = ranova(rm);
    disp('Repeated Measures ANOVA Results:');
    disp(ranovaResults);

    % Step 6: Apply Linear Contrast
    % Define the linear contrast weights based on the number of time points
    if numTimePoints == 5
        contrastWeights = [-2 -1 0 1 2];
    elseif numTimePoints == 6
        contrastWeights = [-5 -3 -1 1 3 5];
    elseif numTimePoints == 7
        contrastWeights = [-3 -2 -1 0 1 2 3];
    end
    
    % Get the mean response for each time point
    means = mean(inputData, 'omitnan');  % Calculate the marginal means ignoring NaNs
    
    % Step 7: Calculate the linear contrast result
    % Apply the contrast weights to the means
    contrastValue = contrastWeights * means';
    
    % Step 8: Calculate standard error and test statistic
    % Standard error calculation: sqrt(sum of (contrastWeights^2 / n))
    variances = var(inputData, 'omitnan');  % Variances for each time point
    se = sqrt(sum((contrastWeights.^2 .* variances) / numSubjects));  % Standard error of contrast
    
    % Test statistic (t-value for linear contrast)
    tValue = contrastValue / se;
    
    % Convert t-value to F-value
    FValue = tValue^2;  % F-value is t-value squared for one degree of freedom

    % Degrees of freedom
    df1 = 1;  % One contrast, so numerator df is 1
    df2 = numSubjects - 1;  % Denominator df = number of subjects - 1

    % Calculate the p-value for the F-statistic
    pValue = 1 - fcdf(FValue, df1, df2);

    % Display the linear contrast result
    disp('Linear Contrast Results:');
    fprintf('Contrast Value: %.4f\n', contrastValue);
    fprintf('Standard Error: %.4f\n', se);
    fprintf('T-value: %.4f\n', tValue);
    fprintf('F-value: %.4f\n', FValue);
    fprintf('p-value: %.4f\n', pValue);
end