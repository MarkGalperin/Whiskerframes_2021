%% analysis script for quick data analysis
clear;
clc;

%% add to path
addpath('../src');
addpath('../src/optimization');

%% LOAD DATA
% choose batch directory
batch_dir = '../output/trial_data/fullbatch_09_04/';
SETS = batch_load(batch_dir);

%% LOOP OVER DATA TO FIND MIN ERROR AND LOG RESULTS
%min values
standard_min = struct('value',inf,'info',[]);

for set_i = 1:length(SETS)
    set = SETS{set_i};
    for trial_i = 1:length(set)
        trial = set(trial_i);
        %get trial error
        error_standard = trial.TRIAL(1).abserrmean;
        error_bias = trial.TRIAL(2).abserrmean;
        
        %evaluate minimum
        %debug
            fprintf('err = %f \n',error_standard)
        if error_standard < standard_min.value
            standard_min.value = error_standard;
            stamdard_min.info = [set_i,trial_i];
        end
        
    end
end





