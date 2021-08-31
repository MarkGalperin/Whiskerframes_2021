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

% function [TRIALS,constraints] = generate_runs(s_vals,R_vals,dtheta_vals)
% % *** GENERATING MANY TRIALS ***
%     % This function takes the biological datasets and produces arrays of
%     % points for inputting into the search experiment.
%     %
%     % Takes Input1: DJKFHDS
%     %       Input2: SDFDS
%     % 
%     % Returns   DSFSDF
%     %
% 
%     %% generating the trials map
%     %building constraint structs in a "Map" container
%     TRIALS = containers.Map('KeyType','char','ValueType','any');
%     constraints = {};
%     
%     c = 0;
%     for s = s_vals
%         for R = R_vals
%             for dth = dtheta_vals
%                 %make string
%                 c = c+1;
%                 constr = append('const',num2str(c,'%03d'));
% 
%                 %append to constraints cell
%                 constraints{end+1} = constr;
% 
%                 %make struct
%                 C.c = 0.1;
%                 C.R = R;
%                 C.dtheta = dth;
%                 C.s = s;
% 
%                 %add to map
%                 TRIALS(constr) = C;
%             end
%         end
%     end
% end