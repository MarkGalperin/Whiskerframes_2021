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
trial = 'const2_3dof.mat';
loadstr = append('../output/trial_data/',trial);
TRIAL = load(loadstr);

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
    subplot(N,1,N+1-w)
    comp_plot = plot_shadedcomp(X,Y1,Y2);
end

comp_plots = gcf;

% save plot
path_err = '../output/figures/comparison';
comp_file = 'test';    %append(file,'_err');
saveas(comp_plots, fullfile(path_err, comp_file), 'png');





    
    
    
    
