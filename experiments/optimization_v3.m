%% TRAJECTORY OPTIMIZATION (v3)
% Trajectory Optimization for biomimetic whiskers

% This experiment finds an optimal trajectory of the Whisker Frames
% control frame given biologically-observed time data for N whiskers
%
% v3 loops through all pre-processed files, performing calculations in the
% trajopt() function (../src/optimization)
clear;
clc;
clf;

%% Including code
addpath('../src');
addpath('../src/deming');
addpath('../src/optimization');

%% Fetch pre-processed data
% DATA_i = load('../data/processed/filtered/dlc_MSE_filt.mat');
% DATA_i = load('../data/processed/filtered/filt_janelia_2_(8_31_16).mat');
DATA_i = load('../data/processed/filtered/filt_janelia_14_(3_25_17).mat');
% DATA_i = load('../data/processed/filtered/filt_janelia_18_(2_09_18).mat');

%% cut down the data to a manageble or target time range
X = 1:500; %X = 1:size(DATA_i.ANG,1)
ANG_cut = DATA_i.angles(X,:);
PTS_cut = DATA_i.points(:,:,X);
%re-define data
DATA.angles = ANG_cut;
DATA.points = PTS_cut;

% dynamics = {struct('R',1,'accel',0.06,'dtheta',pi/2,'ddtheta',0.01)};
% 
% 
% %put all values to loop over in cell arrays (WARNING currently only works for current multiple-value arrays)
% PARAMS = struct('s',{0.75},...  's',{0.3,0.45,0.6,0.75,0.9},
%                 'c',{0.1},...
%                 'errmode',{'squared'},...
%                 'res',{RES},...
%                 'lb',{[-1 -0.2500 -1.0472]},...
%                 'ub',{[0 1.2500 1.0472]},...
%                 'sb',{[0.2000 0.2000 1.0472]},...
%                 'bias',{'zeros'});

%% Define optimization constraints as struct C
C.s = 0.3;
%compatability constraint
C.c = 0.1; %compatability tolerance
%error mode
C.errmode = 'squared'; %'abs' or 'squared'
%debug switches
C.objinfo = true;
C.ovrct = 3; %overconstraint threshold
%dynamic constraints
C.R = 1; %xy jump tolerance (NEW: this now only makes sense to be less than the search box, otherwise the searchbox defines the constraint)
C.accel = 0.1; %xy acceleration tolerance
C.dtheta = (pi/2); %theta jump tolerance
C.ddtheta = 0.1; %theta acceleration constraint
% C.jerk = .5; %third-order constraint
% C.jth = .5;
C.thlim = false; %theta limit option - works as a compatability constraint
%search parameters
C.res = [0.05, 0.05, 0.001]; %search resolution for r1,r2,th
C.lb = [-3,-0.25,-pi/2]; %lower value bounds
C.ub = [0,1.25,pi/2]; %upper value bounds
C.sb = [0.2,0.2,pi/3]; %search box absolute dimensions
C.bias = zeros(1,size(ANG_cut,2)); %initial biases are zero

%omit point data?
C.omit = [];

%% OPTIMIZATION MODE AND SETUP
mode = 'line_3dof';   % 3 modes: 'line_3dof' , 'line_1dof', 'circular' (circular not yet implemented)
file = 'Oct8test';         % file name
animate = 0;         % generate animation?

%% Run optimization
% TODO: iterate over all new filtered data
TRIAL = trajopt(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s

%% Saving trial 
file_trial = append('../output/trial_data/',file);
save(file_trial,'-struct','TRIAL');

%% done
fprintf('DONE \n');
