clear all

addpath('D:\NHP_code\cbiNifti')

subject = 'SBSN_S_005';
direc_start = 'D:\SBSN\Data\Brain';
direc_end = '\task\';
load(fullfile(direc_start, subject, direc_end, 'param.mat'))

tr = 2.2;
volRemoved = 5;
timeSubtraction = tr * volRemoved;

for i = 1:length(param.trial)

    taskTiming = zeros(8, 3);
    taskTiming(:, 1) = uint16(param.trial(i).absoluteTime(find(param.trial(i).trialIndex == 1))) - timeSubtraction;
    taskTiming(:, 2) = 18;
    taskTiming(:, 3) = 1;

    taskTiming_20 = [];
    taskTiming_45 = [];
    taskTiming_70 = [];

    for j = 1:length(param.trial(i).targetForce)
    
        if param.trial(i).targetForce(j) == 0.2

            taskTiming_20 = [taskTiming_20; taskTiming(j, :)];
            
        elseif param.trial(i).targetForce(j) == 0.45

            taskTiming_45 = [taskTiming_45; taskTiming(j, :)];

        elseif param.trial(i).targetForce(j) == 0.7

            taskTiming_70 = [taskTiming_70; taskTiming(j, :)];

        end

    end

    %mkdir(fullfile(direc_start, subject, direc_end, ['task', num2str(i)]))
    writematrix(taskTiming, fullfile(direc_start, subject, direc_end, ['task', num2str(i)], 'events.txt'), 'Delimiter','space')

    % save 20
    writematrix(taskTiming_20, fullfile(direc_start, subject, direc_end, ['task', num2str(i)], 'force20.txt'), 'Delimiter','space')
    % save 40
    writematrix(taskTiming_45, fullfile(direc_start, subject, direc_end, ['task', num2str(i)], 'force45.txt'), 'Delimiter','space')
    % save 0
    writematrix(taskTiming_70, fullfile(direc_start, subject, direc_end, ['task', num2str(i)], 'force70.txt'), 'Delimiter','space')
    
end