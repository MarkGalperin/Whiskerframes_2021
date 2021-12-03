%% ANALYZING 100 TRIALS
clear;
clf;
clc;

%% Include files
addpath('../src')
addpath('../src/figures');

%% Get Trial data
path = '../output/trial_data/3dof_trials/trial_data/';
tfile = 'TRIALS_3dof.csv';
TABLE = readtable([path,tfile]);
% 
% loadstr = append(path,trial);
% TRIAL = load(loadstr);

%% Min avg error overall
%get trials
files = TABLE.file_name;
Errs = zeros(size(files));
%loop
for ii = 1:length(files)
    %get relevant data
    file = files{ii};
    data = load([path,file,'.mat']);
    %get error mean
    error = mean(data.error);
    Errs(ii) = error;
end
%% calculate minimum mean and get info
[m,mi] = min(Errs);
min_data = load([path,files{mi},'.mat']);
% APR 28th DATA:
% min error = 0.0302 rad
% i = 79


%% Reading individual data
% %selection values
% Rvals =[0.05,0.1,0.2,0.4,0.8];
% dthvals =[0.1571,0.3142,0.3927,0.5236,0.7854];
% svals = [0.3,0.45,0.6,0.75];
% R = Rvals(1);
% dth = dthvals(1);
% s = svals(1);
% 
% 
% % select values
% select_s = round(T.dtheta,4) == dth & T.R == R;
% 
% % index table
% s_table = T(select_s,:);
% s_files = s_table.file_name;
% 
% %get relevant data
% file = s_files{ii};
% data = load([path,file,'.mat']);
% 
% %get error
% error = data.error;
% t = 1:length(error);
