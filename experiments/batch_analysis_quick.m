%% analysis script for quick data analysis
% should generate a folder of csv files with results
clear;
clc;

%% add to path
addpath('../src');
addpath('../src/optimization');

%% LOAD DATA
% choose batch directory
batch_dir = '../output/trial_data/FULLBATCH/'; %make sure to end with "/"
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
        if error_standard < standard_min.value
            standard_min.value = error_standard;
            standard_min.info = [set_i,trial_i];
        end
        
        %print statements
        fprintf('Dataset (%d/%d) Trial (%d/%d) Std. error = %f \n',set_i,length(SETS),trial_i,length(set),error_standard);
    end
    fprintf('Min error for set (%d/%d) at trial (%d/%d) = %f \n',set_i,length(SETS),standard_min.info(2),length(set),standard_min.value);
end





