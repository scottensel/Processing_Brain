%% Frame Displacement
clear all

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 

allData = {};
for i = 1:length(subName)

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    for j = 1:4
        direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);
        
        motionData = importdata(fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)], 'fmri_moco.txt'));
%         motionData = motionData(11:end,:);

        dataDiff = motionData(2:end,:)-motionData(1:(end-1),:);
        FD = sum(abs(dataDiff), 2);

        FD = FD(5:end,:);

        % number of active voxels
        allData{i, 1}{j, 1} = [mean(reshape(FD, [], 1),'omitnan'), std(reshape(FD, [], 1),'omitnan')];
        allData{i, 1}{j, 2} = [subName{i}, ' func', num2str(j)];

    
    end
end


for i = 1:length(allData)

    frameD(i,:) = allData{i,1}{1,1}(1);

end

mean(mean(frameD)) 
std(frameD)/sqrt(length(frameD))

%% TSNR
clear all

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 

% fmri_brain_moco_mean_tsnr_MNI152.nii.gz

gunzip('D:\SBSN\Data\Brain\template\MNI152_T1_brain_mask.nii.gz');
[brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\MNI152_T1_brain_mask.nii');

allData = {};
for i = 1:length(subName)

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    for j = 1:4
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
        allData{i, 1}{j, 1} = [mean(reshape(mag, [], 1),'omitnan'), std(reshape(mag, [], 1),'omitnan')];
        allData{i, 1}{j, 2} = [subName{i}, ' func', num2str(j)];

    
    end
end


for i = 1:length(allData)
    for j = 1:length(allData{i,1})

        tsnr(i,j) = allData{i,1}{j,1}(1);

    end

end


figure;
plot(tsnr')
% plotCreator(tsnr, 1:7);
make_pretty
xlim([0.75,4.25])
ylabel('TSNR')
xlabel('Run Number');
title(sprintf('TSNR of Participant'));
% xticklabels({'1','2','3','4'})

% figure;
% plot(tsnr', '.-r')
% hold on
% plot(mean(tsnr), 'k')
% errorbar(1:7,mean(tsnr), std(tsnr)/sqrt(length(tsnr)), 'Color','black')


% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_tsnr.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_tsnr.svg');


% Define the run combinations (1 to 6)
% runCombinations = 1:7;
% 
% % Spearman's correlation for active voxels
% [rho_activeVoxels, pval_activeVoxels] = corr(runCombinations', mean(tsnr)', 'Type', 'Spearman');
% 
% % Display results for active voxels
% disp('Spearman correlation for active voxels:');
% disp('Correlation coefficients (rho):');
% disp(rho_activeVoxels);
% disp('P-values:');
% disp(pval_activeVoxels);

% runRepeatedMeasuresANOVA(tsnr)


%% template matching
clear all

%%% SPINE

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 
zScore = 2.3;

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
        if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_two_FLOB')

            disp(subjectFolder(folder).name)

            fileName = strsplit(subjectFolder(folder).name, '.');

            if ~exist(fullfile(direc, subjectFolder(folder).name, copeFile, 'thresh_zstat1.nii'))

                gunzip(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii.gz'));

            end

            [dataFile, hdr] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));

            disp(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'))

            numVoxels = sum(sum(sum((dataFile>=zScore).*(brainLevels>=1))));
            mag = dataFile(brainLevels>=1);

            numVoxelsSeperate = [];
            magSeperate = [];
            for j = 1:8
                numVoxelsSeperate(j) = sum(sum(sum((dataFile>=zScore).*(brainLevels==j))));
                numVoxelsSeperate(j) = numVoxelsSeperate(j)/sum(sum(sum(brainLevels==j)))*100;

                var = dataFile(brainLevels==j);
                magSeperate(j) = mean(var(var>zScore));  
            end

            % number of active voxels
            allData{i, 1}{fileCounter, 1} = [numVoxels/sum(sum(sum(brainLevels>=1)))*100, mean(mag(mag>zScore)), std(mag(mag>zScore))];
            allData{i, 1}{fileCounter, 2} = subjectFolder(folder).name;
            allData{i, 1}{fileCounter, 3} = [numVoxelsSeperate; magSeperate];

            fileCounter = fileCounter + 1;
        end

    end
end


for i = 1:length(allData)
%     for j = 1:length(allData{i,1})

        activeVoxels(i) = allData{i,1}{1,1}(1);
        zScores(i) = allData{i,1}{1,1}(2);
        
        actVoxelsSeg4(i,:) = allData{i,1}{1,3}(1,:);
        zSeg4(i,:) = allData{i,1}{1,3}(2,:);
%     end

end

% figure;
% plot(activeVoxels', '.-r')
% hold on
% plot(mean(activeVoxels), 'k')
% errorbar(1:5,mean(activeVoxels), std(activeVoxels)/sqrt(length(activeVoxels)), 'Color','black')
% make_pretty
figure;
plot(activeVoxels);
make_pretty
xlim([0.75,length(subName)+0.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Average Active Successive runs'));
xticks(1:length(subName))
xticklabels( {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_055','SBSN_S_066','SBSN_S_077'})

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_success.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_success.svg');
% Step 1: Detect changepoints based on changes in the slope ('linear')
% Adjust 'MaxNumChanges' based on your data (max number of changes to detect)


% % Define the run combinations (1 to 6)
% runCombinations = 1:5;
% 
% % Spearman's correlation for active voxels
% [rho_activeVoxels, pval_activeVoxels] = corr(runCombinations', mean(activeVoxels)', 'Type', 'Spearman');
% 
% % Display results for active voxels
% disp('Spearman correlation for active voxels:');
% disp('Correlation coefficients (rho):');
% disp(rho_activeVoxels);
% disp('P-values:');
% disp(pval_activeVoxels);

% 
% runRepeatedMeasuresANOVA(activeVoxels)
% runRepeatedMeasuresANOVA(zScores)
% 
% plotCreator(diff(activeVoxels')', 1:4);
% figure;
% plot(diff(activeVoxels'), '.-r')
% hold on
% plot(mean(diff(activeVoxels')'), 'k')
% errorbar(1:4,mean(diff(activeVoxels')'), std(diff(activeVoxels')')/sqrt(length(activeVoxels)), 'Color','black')
% make_pretty
% xlim([0.75,4.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Difference Average Active Successive runs'));
% xticks(1:4)
% xticklabels({'2-3','3-4','4-5','5-6'})

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_diff.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_diff.svg');

figure;
plot(zScores);
% figure;
% plot(zScores', '.-r')
% hold on
% plot(mean(zScores), 'k')
% errorbar(1:5,mean(zScores), std(zScores)/sqrt(length(zScores)), 'Color','black')
make_pretty
xlim([0.75,length(subName)+0.25])
xlabel('Run Combination')
ylabel('Z-Score');
title(sprintf('Average Zscore Successive runs'));
xticks(1:length(subName))
xticklabels({'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_055','SBSN_S_066','SBSN_S_077'})
% [rho,pval] = corr(mean(activeVoxels)', 'Spearman')

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_success.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_success.svg');

% Spearman's correlation for Z-scores
% [rho_ZScores, pval_ZScores] = corr(runCombinations', mean(zScores)', 'Type', 'Spearman');
% 
% % Display results for Z-scores
% disp('Spearman correlation for Z-scores:');
% disp('Correlation coefficients (rho):');
% disp(rho_ZScores);
% disp('P-values:');
% disp(pval_ZScores);



% plotCreator(diff(zScores')', 1:4);
% % figure;
% % plot(diff(zScores'), '.-r')
% % hold on
% % plot(mean(diff(zScores')'), 'k')
% % errorbar(1:4,mean(diff(zScores')'), std(diff(zScores')')/sqrt(length(zScores)), 'Color','black')
% make_pretty
% xlim([0.75,4.25])
% xlabel('Run Combination')
% ylabel('zScores');
% title(sprintf('Difference Average zScores Successive runs'));
% xticks(1:4)
% xticklabels({'2-3','3-4','4-5','5-6'})

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_diff.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_diff.svg');




% time = [1, 2, 3, 4, 5];
% findSlopePts(activeVoxels, time)
% make_pretty
% xlim([0.75,length(subName)+0.25])
% xlabel('Run Combination')
% ylabel('Active Voxels');
% title(sprintf('Difference Average Active Voxels Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% % Save the plot as a PNG image
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_slope.png');
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_slope.svg');
% 
% 
% 
% time = [1, 2, 3, 4, 5];
% findSlopePts(zScores, time)
% make_pretty
% xlim([0.75,length(subName)+0.25])
% xlabel('Run Combination')
% ylabel('Z-Score');
% title(sprintf('Average Zscore Successive runs'));
% xticks(1:5)
% xticklabels({'1-2','1-3','1-4','1-5','1-6'})
% % Save the plot as a PNG image
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_slope.png');
% % saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_slope.svg');

% actVoxelsSeg6 = actVoxelsSeg4(3:end,:);
% zSeg6 = zSeg4(3:end,:);

% actVoxelsSeg4(3:end,:) = [];
% zSeg4(3:end,:) = [];

figure;
hBar=barh(mean(actVoxelsSeg4)');
X=get(hBar,'XData').'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar(mean(actVoxelsSeg4)', X, (std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)))', 'horizontal', '.', 'Color','black');  % add the errorbar
randVec = (-1 + (1+1)*rand(1,1))/10;
scatter(actVoxelsSeg4, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 20, 'k','o','filled'); 
% scatter(actVoxelsSeg6, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 20, 'k','o','filled'); 
set(gca,'YDir','reverse')
yticks(1:length(1:8)); yticklabels({'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'});
ylabel('Brain Area')
xlabel('Active Voxels');
title(sprintf('Average Active Voxel 4 Runs'));
make_pretty

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_area.svg');

figure;
hBar=barh(mean(zSeg4, 'omitnan')');
X=get(hBar,'XData').'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar(mean(zSeg4, 'omitnan')', X, (std(zSeg4, 'omitnan')/sqrt(length(zSeg4)))', 'horizontal', '.', 'Color','black');  % add the errorbar
% errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
randVec = (-1 + (1+1)*rand(1,1))/10;
scatter(zSeg4, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 20, 'k','o','filled'); 
% scatter(zSeg6, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 20, 'k','o','filled'); 
set (gca,'YDir','reverse')
yticks(1:length(1:8)); yticklabels({'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'});
ylabel('Brain Area')
xlabel('Z-score');
title(sprintf('Average Z-Score 4 Runs'));
make_pretty

% Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_zscore_area.svg');

% h = barh(flip(cerAvg([1 2 3 4 6 5 7 8]),1),'FaceColor',[.35 .35 .35]);  %6 runs
% %legend('4R','6R','Location','eastoutside')
% title (sprintf('All subjects - average : %d runs combined',i+1))
% yticks(1:8)
% xlim([0 50])
% yticklabels({'Cerebellum (R)','Cerebellum (L)','BG (R)','BG (L)','Thalamus (R)','Thalamus (L)','SM (R)','SM (L)'})

%% template matching
clear all

%%% SPINE

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 
zScore = 2.3;

% THINGS TO ADD
[brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');

allData = {};
for i = 1:length(subName)

    allData{i, 1} = {};
    allData{i, 2} = subName{i};

    for j = 1:4
        direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);

%         direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);
    
        subjectFolder = dir(direc);
    
        disp(subName{i})

        fileCounter = 1;
        for folder = 3:length(subjectFolder)
    
            %is dir and name contains gfeat
            if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_one_FLOB')
    
                disp(subjectFolder(folder).name)
    
                fileName = strsplit(subjectFolder(folder).name, '.');
    
                if ~exist(fullfile(direc, subjectFolder(folder).name, 'stats\zstat1.nii'))
    
                    gunzip(fullfile(direc, subjectFolder(folder).name,  'stats\zstat1.nii.gz'));
    
                end
    
                [dataFile, ~] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  'stats\zstat1.nii'));

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
[h,p,ci,stats] = ttest(activeVoxels(:,1), mean(activeVoxels(:,2:end),2, 'omitnan'));
h,p,ci,stats
[h,p,ci,stats] = ttest(zScores(:,1), mean(zScores(:,2:end),2, 'omitnan'));
h,p,ci,stats

activeVoxels2 = [activeVoxels(:,1), mean(activeVoxels(:,2:end),2)];
zScores2 = [zScores(:,1), mean(zScores(:,2:end),2)];

mean(activeVoxels2)
mean(zScores2)
std(activeVoxels2)/sqrt(length(activeVoxels2))
std(zScores2)/sqrt(length(zScores2))

plotCreator(activeVoxels2, 1:2);
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

% % Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_control.png');
% saveas(gcf, 'D:\SBSN\Manuscript\plots\Brain_voxel_control.svg');


plotCreator(zScores2, 1:2);
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

plotCreator(activeVoxels, 1:7);
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

plotCreator(zScores, 1:7);
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

%%

function plotCreator(value,len)
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
        
        if i > 4
            plot(value(i,:)', 'x-', 'Color', opac{i-1}, 'MarkerSize', 15)
            hold on
        else
            plot(value(i,:)', '.-', 'Color', opac{i-1},'MarkerSize', 15)
            hold on
        end

    end
    hold on
    plot(mean(value, 'omitnan'), 'k')
    errorbar(len, mean(value, 'omitnan'), std(value, 'omitnan')/sqrt(length(value)), 'Color','black')

end


function findSlopePts(data, time)

%     time = [1, 2, 3, 4, 5]; % Example time data
    [changepts,~] = findchangepts(mean(data), 'Statistic', 'linear', 'MaxNumChanges', 5);
    
    % Step 2: Plot data with detected changepoints
    figure;
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