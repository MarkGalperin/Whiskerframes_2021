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
DATA_i = load('../data/processed/filtered/filt_janelia_19_(2_09_18).mat');

%% cut down the data to a manageble or target time range
X = 1:427; %X = 1:size(DATA_i.ANG,1)
ANG_cut = DATA_i.angles(X,:);
PTS_cut = DATA_i.points(:,:,X);
%re-define data
DATA.angles = ANG_cut;
DATA.points = PTS_cut;


%% Define optimization constraints as struct C
C.s = 0.75;
%compatability constraint
C.c = 0.1; %compatability tolerance
%error mode
C.errmode = 'squared'; %'abs' or 'squared'
%debug switches
C.objinfo = true;
%dynamic constraints
C.R = 1; %xy jump tolerance (NEW: this now only makes sense to be less than the search box, otherwise the searchbox defines the constraint)
C.accel = 0.05; %xy acceleration tolerance
C.dtheta = (pi/2); %theta jump tolerance
C.ddtheta = 0.05; %theta acceleration constraint
% C.jerk = .5; %third-order constraint
% C.jth = .5;
%search parameters
C.res = [0.01,0.01,0.01]; %search resolution for r1,r2,th
C.lb = [-1,-0.25,-pi/3]; %lower value bounds
C.ub = [0,1.25,pi/3]; %upper value bounds
C.sb = [0.2,0.2,pi/3]; %search box absolute dimensions
C.bias = zeros(1,size(ANG_cut,2)); %initial biases are zero

%% OPTIMIZATION MODE AND SETUP
mode = 'line_3dof';   % 3 modes: 'line_3dof' , 'line_1dof', 'circular' (circular not yet implemented)
file = 'parfortest_0';         % file name
animate = 0;         % generate animation?

%% Run optimization
% TODO: iterate over all new filtered data
TRIAL = trajopt(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s

%% Saving trial 
file_trial = append('../output/trial_data/',file);
save(file_trial,'-struct','TRIAL');

%% Keeping track of results via table?
% if
% end

%% done
fprintf('DONE \n');
