%% Making figures based on trials of the optimization runs!!
% IDEAS:
% - plot angle values. x axis t, y axis angles. plot for bio (violet) and
% mechanism
% - compare errors between...
%   - 3dof and 1dof
%   - constrained and unconstrained
%   - increase different constraints
% - plot normalized configuration over time
% - compare bounding boxes?
% - change s values
clear;
clf;
clc;

%% Include files
addpath('../src')
addpath('../src/figures');

%% Get bio data
DATA = load('../data/processed/dlc_MSE.mat');
PTS = DATA.points; %[3xNxT]
ANG = DATA.angles; %[T,N]
ypts = PTS(2,:,1); %assuming these are constant (MSE data)

%% Get (1) trial data TODO: make all
trial = 'const035.mat';
path = '../output/trial_data/4_27/';
loadstr = append(path,trial);
TRIAL = load(loadstr);
TABLE = readtable('../output/trial_data/4_27/TRIALS_Apr26.csv');

%% Calcs
%getting a bunch of protractions
prot = traj2prot(TRIAL.traj,TRIAL.s,ypts); %prot is [T,N]


%% Shaded comparison plot
N = 5;
for w = 1:N
    %get curves
    X = 1:size(prot,1);
    Y1 = transpose(prot(:,w));
    Y2 = transpose(ANG(:,w));

    %plot
    subplot(N,1,w)
    comp_plot = plot_shadedcomp(X,Y1,Y2,N+1-w);
end
% format plot
xlabel('time frame');

comp_plots = gcf;

% save plot
path_comp = '../output/figures/comparison';
comp_file = 'Comparison';    %append(file,'_err');
saveas(comp_plots, fullfile(path_comp, comp_file), 'png');

%% average whisker prot and error over t


%% error wrt change in parameters over t
clf;
%selection values
Rvals =[0.05,0.1,0.2,0.4,0.8];
dthvals =[0.1571,0.3142,0.3927,0.5236,0.7854];
svals = [0.3,0.45,0.6,0.75];
R = Rvals(1);
dth = dthvals(1);
s = svals(4);

% change in s
error_s = plot_errors('s',TABLE,s,dth,R,path,[400,600]);
path_err = '../output/figures/errorcomp';
errs_file = 'error_wrt_s';
saveas(error_s, fullfile(path_err, errs_file), 'png');
clf;

% change in R constraint
error_R = plot_errors('R',TABLE,s,dth,R,path,[]);
errs_file = 'error_wrt_R';
saveas(error_R, fullfile(path_err, errs_file), 'png');
clf;

% change in dtheta constraint
error_dth = plot_errors('dth',TABLE,s,dth,R,path,[400,550]);
errs_file = 'error_wrt_dth';
saveas(error_dth, fullfile(path_err, errs_file), 'png');




    
    
    
    
