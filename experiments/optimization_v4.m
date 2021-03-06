%% TRAJECTORY OPTIMIZATION (V4)
% Trajectory Optimization for biomimetic whiskers. Mark Galperin 2021

% This experiment finds an optimal trajectory of the Whisker Frames
% control frame given biologically-observed time data for N whiskers
% GOAL FOR THIS ITERATION: reduce overconstraint and improve speed.
clear;
clc;
clf;

%% Including code
addpath('../src');
addpath('../src/deming');
addpath('../src/optimization');

%% Fetch pre-processed data
DATA_i = load('../data/processed/filtered/filt_janelia_14_(3_25_17).mat');

%% cut down the data to a manageble or target time range
X = 1:size(DATA_i.angles,1); %1:500; 
ANG_cut = DATA_i.angles(X,:);
PTS_cut = DATA_i.points(:,:,X);
%re-define data
DATA.angles = ANG_cut;
DATA.points = PTS_cut;

%% Define optimization constraints as struct C
C.s = 0.6; %frame length ratio
C.c = 0.1; %compatability tolerance
C.errmode = 'squared'; %error mode: 'abs' or 'squared'
C.ovrct = 3; %overconstraint threshold
%dynamic constraints
C.R = 1; %xy jump tolerance (NEW: this now only makes sense to be less than the search box, otherwise the searchbox defines the constraint)
C.accel = 1; %xy acceleration tolerance
C.dtheta = .1; %theta jump tolerance
C.ddtheta = 0.050; %theta acceleration constraint
%search parameters
C.res = [0.02, 0.02, 0.0001]; %search resolution for r1,r2,th (or m1,m2,th)
C.lb = [-1,-0.25,-pi/2]; %lower value bounds
C.ub = [0,1.25,pi/2]; %upper value bounds
C.sb = [0.4,0.4,pi/3]; %search box absolute dimensions
C.bias = zeros(1,size(ANG_cut,2)); %initial biases are zero
C.axis = 'r'; %center axis for control frame. Can be 'm' or 'r'
C.relax = 1; %constraint relaxation mode

%Stuff that goes into batch trials but not here
C.datasetnum = 14;
C.constraintnum = 1;

%% OPTIMIZATION MODE AND SETUP
mode = 'line_1dof';   % 3 modes: 'line_3dof' , 'line_1dof', 'circular' (circular not yet implemented)
file = 'V4_1dof_relaxtest';         % file name
animate = 0;         % generate animation?

%% RUN OPTIMIZATION
TRIAL = trajopt_v4(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s

%% Saving trial 
file_trial = append('../output/trial_data/',file);
save(file_trial,'-struct','TRIAL');


%% done
fprintf('DONE \n');

