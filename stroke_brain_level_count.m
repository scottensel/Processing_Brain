%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEFT HAND
% RIGHT HEMISPHERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Frame Displacement
clear all

% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subName = {'SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_011','SBSN_H_013','SBSN_H_014','SBSN_H_015','SBSN_H_016','SBSN_H_017','SBSN_H_018',...
    'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_007','SBSN_S_044','SBSN_S_008','SBSN_S_009'}; 

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

disp('task runs mean')
mean(mean(frameD)) 
std(frameD)/sqrt(length(frameD))

disp('healthy')
mean(mean(frameD(1:10))) 
std(frameD(1:10))/sqrt(length(frameD(1:10)))

disp('stroke')
mean(mean(frameD(11:end))) 
std(frameD(11:end))/sqrt(length(frameD(11:end)))

% %% TSNR
% clear all
% 
% % addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
% addpath('D:\NHP_code\cbiNifti')
% 
% % varibales to set up before
% % subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_044','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 
% subName = {'SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_011','SBSN_H_013','SBSN_H_014','SBSN_H_015','SBSN_H_016','SBSN_H_017','SBSN_H_018',...
%     'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_007','SBSN_S_044','SBSN_S_008','SBSN_S_009'}; 
% 
% % fmri_brain_moco_mean_tsnr_MNI152.nii.gz
% 
% gunzip('D:\SBSN\Data\Brain\template\MNI152_T1_brain_mask.nii.gz');
% [brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\MNI152_T1_brain_mask.nii');
% 
% allData = {};
% for i = 1:length(subName)
% 
%     allData{i, 1} = {};
%     allData{i, 2} = subName{i};
% 
%     for j = 1:4
%         direc = fullfile('D:\SBSN\Data\Brain', subName{i}, 'func', ['func', num2str(j)]);
%     
%         subjectFolder = dir(direc);
%     
%         disp(subName{i})
% 
%         if ~exist(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii'))
% 
%             gunzip(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii.gz'));
% 
%         end
% 
%         [dataFile, ~] = cbiReadNifti(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii'));
% 
%         disp(fullfile(direc, 'fmri_brain_moco_mean_tsnr_MNI152.nii'))
% 
%         mag = dataFile(brainLevels>=1);
% 
%         % number of active voxels
%         allData{i, 1}{j, 1} = [mean(reshape(mag, [], 1),'omitnan'), std(reshape(mag, [], 1),'omitnan')];
%         allData{i, 1}{j, 2} = [subName{i}, ' func', num2str(j)];
% 
%     
%     end
% end
% 
% 
% for i = 1:length(allData)
%     for j = 1:length(allData{i,1})
% 
%         tsnr(i,j) = allData{i,1}{j,1}(1);
% 
%     end
% 
% end
% 
% 
% % plot(tsnr')
% plotCreator(tsnr, 1:4);
% make_pretty
% xlim([0.75,4.25])
% ylabel('TSNR')
% xlabel('Run Number')
% xticks([1:4])
% xticklabels([1:4])
% % xticklabels(strrep(subName, '_', '-'))
% title(sprintf('TSNR of Participant'));
% % xticklabels({'1','2','3','4'})
% 
% % figure;
% % plot(tsnr', '.-r')
% % hold on
% % plot(mean(tsnr), 'k')
% % errorbar(1:7,mean(tsnr), std(tsnr)/sqrt(length(tsnr)), 'Color','black')
% 
% 
% % Save the plot as a PNG image
% saveas(gcf, 'D:\SBSN\stroke\Brain_tsnr.png');
% saveas(gcf, 'D:\SBSN\stroke\Brain_tsnr.svg');
% 
% 
% % Define the run combinations (1 to 6)
% % runCombinations = 1:7;
% % 
% % % Spearman's correlation for active voxels
% % [rho_activeVoxels, pval_activeVoxels] = corr(runCombinations', mean(tsnr)', 'Type', 'Spearman');
% % 
% % % Display results for active voxels
% % disp('Spearman correlation for active voxels:');
% % disp('Correlation coefficients (rho):');
% % disp(rho_activeVoxels);
% % disp('P-values:');
% % disp(pval_activeVoxels);
% 
% % runRepeatedMeasuresANOVA(tsnr)


%% template matching
clear all

%%% BRAIN



 %%%%

%  6 doesnt need to be flipped


 %%%%%%%%%%%%%
% addpath('/Users/pirondinilab/spinalcordtoolbox/cbiNifti');
addpath('D:\NHP_code\cbiNifti')

% varibales to set up before
subSplit = 10;
% subName = {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_044','SBSN_S_055','SBSN_S_066','SBSN_S_077'}; 
subName = {'SBSN_H_007','SBSN_H_008','SBSN_H_010','SBSN_H_011','SBSN_H_013','SBSN_H_014','SBSN_H_015','SBSN_H_016','SBSN_H_017','SBSN_H_018',...
    'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_007','SBSN_S_044','SBSN_S_008','SBSN_S_009'}; 


fugl = [35, 23, 36, 29, 30, 23, 32, 32, 17, 34];
controls = ones(subSplit, 1)' * 66;

zScore = 3.1;

copeFile = 'cope1.feat';

% [brainLevels, ~] = cbiReadNifti('D:\SBSN\Data\Brain\template\ATLAS\GREICIUS\Sensorimotor\test_final1.nii');
% 
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};


% -----------------------------
% HMAT atlas (single file, 12 labels)
% -----------------------------
% Index mapping (HMAT.nii):
% 1 R_M1, 2 L_M1, 3 R_S1, 4 L_S1,
% 5 R_SMA, 6 L_SMA, 7 R_preSMA, 8 L_preSMA,
% 9 R_PMd, 10 L_PMd, 11 R_PMv, 12 L_PMv
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
    for folder = 3:length(subjectFolder)

        %is dir and name contains gfeat
        if subjectFolder(folder).isdir && contains(subjectFolder(folder).name, 'level_two_force_FLOB')

            disp(subjectFolder(folder).name)

            fileName = strsplit(subjectFolder(folder).name, '.');

            if ~exist(fullfile(direc, subjectFolder(folder).name, copeFile, 'thresh_zstat1.nii'))

                gunzip(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii.gz'));

            end

            [dataFile, hdr] = cbiReadNifti(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'));
           
            % these are the subjects who had lesions on the opposit side
            if ismember(i, [1:4 6:subSplit subSplit+3 subSplit+5 subSplit+9 subSplit+10])
                dataFile = flip(dataFile, 1);
            end

            disp(fullfile(direc, subjectFolder(folder).name,  copeFile, 'thresh_zstat1.nii'))

            numVoxels = sum(sum(sum((dataFile>=zScore).*(brainLevels>=1))));
            mag = dataFile(brainLevels>=1);

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

            fileCounter = fileCounter + 1;
        end

    end
end


for i = 1:length(allData)
%     for j = 1:length(allData{i,1})

        activeVoxels(i) = allData{i,1}{1,1}(1);
        zScores(i) = allData{i,1}{1,1}(2);
        
        actVoxelsSegH(i,:) = allData{i,1}{1,3}(1,:);
        zSegH(i,:) = allData{i,1}{1,3}(2,:);
%     end

end


activeVoxelsH = activeVoxels(1:subSplit);
activeVoxelsS = activeVoxels(subSplit+1:end);
zScoresH = zScores(1:subSplit);
zScoresS = zScores(subSplit+1:end);

actVoxelsSegS = actVoxelsSegH(subSplit+1:end,:);
zSegS = zSegH(subSplit+1:end,:);

actVoxelsSegH(subSplit+1:end,:) = [];
zSegH(subSplit+1:end,:) = [];


figure;
plot(fugl, activeVoxelsS, '.', 'MarkerSize', 48, 'LineWidth', 1.5);
hold on
plot(controls, activeVoxelsH, '.', 'MarkerSize', 48, 'LineWidth', 1.5);
plot(mean(fugl), mean(activeVoxelsS), '.k', 'MarkerSize', 24, 'LineWidth', 1.5)
plot(mean(controls), mean(activeVoxelsH), '.k', 'MarkerSize', 24, 'LineWidth', 1.5)
errorbar( [mean(fugl), mean(controls)], [mean(activeVoxelsS, 'omitnan')', mean(activeVoxelsH, 'omitnan')'], [(std(activeVoxelsS, 'omitnan')/sqrt(length(activeVoxelsS)))',  (std(activeVoxelsH, 'omitnan')/sqrt(length(activeVoxelsH)))'], '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
make_pretty
xlim([min(fugl)-0.25,66+0.25])
ylabel('% Active Voxels');
xlabel('Fugly-Meyer Score')
title('FM vs % Active Voxels')
% Save the plot as a PNG image
saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_FM_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_FM_z', num2str(zScore), '.svg']);

figure;
plot(fugl, zScoresS, '.', 'MarkerSize', 48, 'LineWidth', 1.5);
hold on
plot(controls, zScoresH, '.', 'MarkerSize', 48, 'LineWidth', 1.5);
plot(mean(fugl), mean(zScoresS), '.k', 'MarkerSize', 24, 'LineWidth', 1.5)
plot(mean(controls), mean(zScoresH), '.k', 'MarkerSize', 24, 'LineWidth', 1.5)
errorbar( [mean(fugl), mean(controls)], [mean(zScoresS, 'omitnan')', mean(zScoresH, 'omitnan')'], [(std(zScoresS, 'omitnan')/sqrt(length(zScoresS)))',  (std(zScoresH, 'omitnan')/sqrt(length(zScoresH)))'], '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar

make_pretty
xlim([min(fugl)-0.25,66+0.25])
ylabel('Z-score');
xlabel('Fugly-Meyer Score')
title('FM vs Z-score')
% Save the plot as a PNG image
saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_FM_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_FM_z', num2str(zScore), '.svg']);


% figure;
% plot(fugl, actVoxelsSegS(:,1), '.', 'MarkerSize', 48, 'LineWidth', 1.5);
% figure;
% plot(fugl, actVoxelsSegS(:,2), '.', 'MarkerSize', 48, 'LineWidth', 1.5);
% figure;
% plot(fugl, actVoxelsSegS(:,5), '.', 'MarkerSize', 48, 'LineWidth', 1.5);
% figure;
% plot(fugl, actVoxelsSegS(:,6), '.', 'MarkerSize', 48, 'LineWidth', 1.5);


% figure;
% plot(activeVoxels', '.-r')
% hold on
% plot(mean(activeVoxels), 'k')
% errorbar(1:5,mean(activeVoxels), std(activeVoxels)/sqrt(length(activeVoxels)), 'Color','black')
% make_pretty
figure;
plot(activeVoxelsS);
hold on
plot(activeVoxelsH);
make_pretty
% xlim([0.75,length(subName)+0.25])
% xlabel('Run Combination')
ylabel('Active Voxels');
title('Average % Active Successive runs');
xlabel('Participant')
xticklabels(strrep(subName, '_', '-'))
% xticks(1:length(subName))
% xticklabels( {'SBSN_S_001','SBSN_S_002','SBSN_S_003','SBSN_S_004','SBSN_S_005','SBSN_S_006','SBSN_S_044','SBSN_S_055','SBSN_S_066','SBSN_S_077'})

% Save the plot as a PNG image
saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_success_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_success_z', num2str(zScore), '.svg']);

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
% saveas(gcf, 'D:\SBSN\stroke\Brain_voxel_diff.png');
% saveas(gcf, 'D:\SBSN\stroke\Brain_voxel_diff.svg');

figure;
plot(zScoresH);
hold on
plot(zScoresS);
% figure;
% plot(zScores', '.-r')
% hold on
% plot(mean(zScores), 'k')
% errorbar(1:5,mean(zScores), std(zScores)/sqrt(length(zScores)), 'Color','black')
make_pretty
% xlim([0.75, length(subName)+0.25])
ylabel('Z-Score');
title(sprintf('Average Zscore Successive runs'));
xlabel('Participant')
xticklabels(strrep(subName, '_', '-'))
% [rho,pval] = corr(mean(activeVoxels)', 'Spearman')

% Save the plot as a PNG image
saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_success_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_success_z', num2str(zScore), '.svg']);

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
% saveas(gcf, 'D:\SBSN\stroke\Brain_zscore_diff.png');
% saveas(gcf, 'D:\SBSN\stroke\Brain_zscore_diff.svg');




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
% % saveas(gcf, 'D:\SBSN\stroke\Brain_voxel_slope.png');
% % saveas(gcf, 'D:\SBSN\stroke\Brain_voxel_slope.svg');
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
% % saveas(gcf, 'D:\SBSN\stroke\Brain_zscore_slope.png');
% % saveas(gcf, 'D:\SBSN\stroke\Brain_zscore_slope.svg');

% actVoxelsSeg6 = actVoxelsSeg4(3:end,:);
% zSeg6 = zSeg4(3:end,:);

% actVoxelsSeg4(3:end,:) = [];
% zSeg4(3:end,:) = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alphas = [0.05, 0.01, 0.001];
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};

disp('Control')
for i = 1:2:nRegions
    
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSegH(:, i), actVoxelsSegH(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end

disp('stroke')
for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSegS(:, i), actVoxelsSegS(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end

disp('control vs stroke')
for i = 1:nRegions
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(actVoxelsSegH(:, i), actVoxelsSegS(:, i), 10000, 0.05, 16);
    brainNames{i}
    ci95, rejectNull

end

% Y = randVec + X(1:nRegions, 1).';              
% Y2 = randVec + X(1:nRegions, 2).';    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
hBar=barh([mean(actVoxelsSegH)', mean(actVoxelsSegS)']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(actVoxelsSegH)', mean(actVoxelsSegS)'], X, [(std(actVoxelsSegH)/sqrt(length(actVoxelsSegH)))',  (std(actVoxelsSegS)/sqrt(length(actVoxelsSegS)))'], 'horizontal','.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
randVec = (-1 + (1+1)*rand(subSplit,1))/10;
Y = randVec + X(1:nRegions, 1).';              
scatter(actVoxelsSegH, Y, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(length(subName)-subSplit,1))/10;
Y = randVec + X(1:nRegions, 2).';              
scatter(actVoxelsSegS, Y, 30, 'k','o','filled'); 
set(gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain Area')
xlabel('Active Voxels');
title(sprintf('Average Voxel Pre vs Post'));
make_pretty

% Save the plot as a PNG image
saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_area_z', num2str(zScore), '.svg']);

% figure;
% hBar=barh(mean(actVoxelsSegH)');
% X=get(hBar,'XData').'+[hBar.XOffset];
% hold on  %4 runs
% hEB = errorbar(mean(actVoxelsSegH)', X, (std(actVoxelsSegH)/sqrt(length(actVoxelsSegH)))', 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% randVec = (-1 + (1+1)*rand(subSplit,1))/10;
% scatter(actVoxelsSegH, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 30, 'k','o','filled'); 
% % scatter(actVoxelsSeg6, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 20, 'k','o','filled'); 
% set(gca,'YDir','reverse')
% yticks(1:length(1:8)); yticklabels({'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'});
% ylabel('Brain Area')
% xlabel('Active Voxels');
% title(sprintf('Average Active Voxel 4 Runs'));
% make_pretty

% Save the plot as a PNG image

% saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_area_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\stroke\Brain_voxel_area_z', num2str(zScore), '.svg']);

alphas = [0.05, 0.01, 0.001];
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};

disp('Control')
for i = 1:2:nRegions
    
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSegH(:, i), zSegH(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end

disp('stroke')
for i = 1:2:nRegions

    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSegS(:, i), zSegS(:, i+1), 10000, 0.05, 16);
    brainNames{i}
    rejectNull

end

disp('control vs stroke')
for i = 1:nRegions
    [ci95, rejectNull, diffSampMeans] = bootstrapCompMeans(zSegH(:, i), zSegS(:, i), 10000, 0.05, 16);
    brainNames{i}
    ci95, rejectNull

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
figure;
hBar=barh([mean(zSegH, 'omitnan')', mean(zSegS, 'omitnan')']);
X=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];
hold on  %4 runs
hEB = errorbar([mean(zSegH, 'omitnan')', mean(zSegS, 'omitnan')'], X, [(std(zSegH, 'omitnan')/sqrt(length(zSegH)))',  (std(zSegS, 'omitnan')/sqrt(length(zSegS)))'], 'horizontal','.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal','.', 'Color', 'black', 'Marker', 'none')
randVec = (-1 + (1+1)*rand(subSplit,1))/10;
Y = randVec + X(1:nRegions, 1).';              
scatter(zSegH, Y, 30, 'k','o','filled'); 
randVec = (-1 + (1+1)*rand(length(subName)-subSplit,1))/10;
Y = randVec + X(1:nRegions, 2).';              
scatter(zSegS, Y, 30, 'k','o','filled'); 
set (gca,'YDir','reverse')
yticks(1:length(1:nRegions)); yticklabels(brainNames);
ylabel('Brain Area')
xlabel('Z-score');
title(sprintf('Average Z-score Pre vs Post'));
make_pretty


% Save the plot as a PNG image
saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_area_z', num2str(zScore), '.svg']);

% figure;
% hBar=barh(mean(zSegH, 'omitnan')');
% X=get(hBar,'XData').'+[hBar.XOffset];
% hold on  %4 runs
% hEB = errorbar(mean(zSegH, 'omitnan')', X, (std(zSegH, 'omitnan')/sqrt(length(zSegH)))', 'horizontal', '.', 'Color', 'black', 'Marker', 'none');  % add the errorbar
% % errorbar(mean(actVoxelsSeg4), 1:4, std(actVoxelsSeg4)/sqrt(length(actVoxelsSeg4)), 'horizontal', '.', 'Color','black')
% randVec = (-1 + (1+1)*rand(1,1))/10;
% scatter(zSegH', [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 30, 'k','o','filled'); 
% % scatter(zSeg6, [randVec+X(1,1), randVec+X(2,1), randVec+X(3,1), randVec+X(4,1), randVec+X(5,1), randVec+X(6,1), randVec+X(7,1), randVec+X(8,1)], 30, 'k','o','filled'); 
% set (gca,'YDir','reverse')
% yticks(1:length(1:8)); yticklabels({'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'});
% ylabel('Brain Area')
% xlabel('Z-score');
% title(sprintf('Average Z-Score 4 Runs'));
% make_pretty

% Save the plot as a PNG image
% saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_area_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\stroke\Brain_zscore_area_z', num2str(zScore), '.svg']);

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
% regionNames = {'SM', 'Thalamus', 'Cerebellum', 'BG'};
regionNames = brainNames(1:2:nRegions);

% Calculate Laterality Index for Pre and Post
LI_pre = (actVoxelsSegH(:,leftIdx) - actVoxelsSegH(:,rightIdx)) ./ ...
         (actVoxelsSegH(:,leftIdx) + actVoxelsSegH(:,rightIdx));
LI_post = (actVoxelsSegS(:,leftIdx) - actVoxelsSegS(:,rightIdx)) ./ ...
          (actVoxelsSegS(:,leftIdx) + actVoxelsSegS(:,rightIdx));

% Average and SEM
meanLI_pre = mean(LI_pre, 1);
semLI_pre = std(LI_pre, 0, 1) / sqrt(size(LI_pre, 1));
meanLI_post = mean(LI_post, 1);
semLI_post = std(LI_post, 0, 1) / sqrt(size(LI_post, 1));

alphas = [0.05, 0.01, 0.001];
% brainNames = {'SM (L)','SM (R)','Thalamus (L)', 'Thalamus (R)', 'Cerebellum (L)', 'Cerebellum (R)', 'BG (L)', 'BG (R)'};

disp('Control')
for i = 1:nRegions/2
    
    ranksum(LI_pre(:, i), LI_post(:, i))

end

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
x=cell2mat(get(hBar,'XData')).'+[hBar.XOffset];

% for i = 1:nbars
%     x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
%     errorbar(x, yvals(i,:), errors(i,:), 'k.', 'LineWidth', 1);
% end
randVec = (-1 + (1+1)*rand(subSplit,1))/10;

errorbar(x', yvals, errors, 'k.', 'LineWidth', 1, 'Marker', 'none');

% scatter([randVec+x(1), randVec+x(2)], [LI_pre, LI_post],  30, 'k','o','filled'); 
% randVec = (-1 + (1+1)*rand(subSplit,1))/10;
Y = randVec + X(1:nRegions/2, 1).';              

scatter(Y, LI_pre,  30, 'k','o','filled'); 

randVec = (-1 + (1+1)*rand(length(subName)-subSplit,1))/10;
Y = randVec + X(1:nRegions/2, 2).';              

scatter(Y, LI_post, 30, 'k','o','filled'); 


ylabel('Laterality Index (LI)');
xlabel('Brain Region');
xticks(1:length(regionNames));
xticklabels(regionNames);
legend({'Control', 'Stroke'}, 'Location', 'northeast');
title('Laterality Index Pre vs Post');
ylim([-1, 1]);
make_pretty  % Optional custom styling

% % Save the figure
% Save the plot as a PNG image
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_all_area_z', num2str(zScore), '.png']);
% saveas(gcf, ['D:\SBSN\Manuscript\plots\Brain_zscore_all_area_z', num2str(zScore), '.svg']);
saveas(gcf, ['D:\SBSN\stroke\LI_area_z', num2str(zScore), '.png']);
saveas(gcf, ['D:\SBSN\stroke\LI_area_z', num2str(zScore), '.svg']);

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

%     opac = {[1, 0.5, 0.5]; [1, 0.15, 0.15]; [1, 0.25, 0.25]; [1, 0.35, 0.35]; [1, 0.45, 0.45]; [1, 0.55, 0.55]};

    figure;
    plot(value(1,:)', '.-r', 'MarkerSize', 15)
    hold on
    for i = 2:length(value) 
        
 
        plot(value(i,:)', '.-', 'Color', 'r', 'MarkerSize', 15)
        hold on

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