%% AUTOMATING THE OPTIMIZATION SCRIPT
% I'm tired of doing this by hand so I'm making this script do it
clear;
clc;

%% add files to path
addpath('../src/optimization')
addpath('./functionized/')

%% constraint and mode values
dtheta_vals = [pi/20,pi/10,pi/8,pi/6,pi/4];
R_vals = [0.05, 0.1, 0.2, 0.4, 0.8];
s_vals = [0.3, 0.45, 0.6, 0.75];
modes = {'_3dof'}; %i'll be doing these 1 at a time

%% generate trials and constraint strings
[TRIALS,constraints] = generate_runs(s_vals,R_vals,dtheta_vals);

%% Initialize table
trial_table = array2table(zeros(0,6));
trial_table.Properties.VariableNames = {'TrialNum','file_name','c', 'R','dtheta','s'};

%% LOOP: perform each trial
K = keys(TRIALS);
for tr = 1:length(K)
    %fetch trial
    trial = TRIALS(K{tr});
    file = constraints{tr};
    
    %fetch values
    c = trial.c;
    R = trial.R;
    dtheta = trial.dtheta;
    s = trial.s;
    
    %log values in table
    log_cell = {tr,file,c,R,dtheta,s};
    trial_table = [trial_table;log_cell];
    
    %run program script
    fprintf('*** RUNNING TRIAL %d ***\n',tr);
    complete = do_trajectory_optimization_v2('line_3dof',file,false,trial);
    fprintf('*** COMPLETED TRIAL %d ***\n\n\n',tr);
    
end

%% Saving the table
name = 'TRIALS_Apr26.csv';
table_file = append('../output/trial_data/',name);
writetable(trial_table,table_file,'Delimiter',',');
