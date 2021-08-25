%% OFFSET BIAS EXPERIMENT %%
% In this experiment, the mechanism is modified to point each whisker a
% constant angle ("bias term") away from the mechanistic angle. Like the
% frame length ratio s, these biases are constant throughout the whisking
% motion, but can be optimized beforehand. 
%

clear;
clc;
clf;

%% Includes
addpath('../src');
addpath('../src/deming');
addpath('../src/optimization');

%% Fetch pre-processed data
DATA_i = load('../data/processed/filtered/filt_janelia_19_(2_09_18).mat');
% cut down the data to a manageble or target time range
X = 1:427; %X = 1:size(DATA_i.ANG,1)
ANG_cut = DATA_i.angles(X,:);
PTS_cut = DATA_i.points(:,:,X);
%re-define data
DATA.angles = ANG_cut;
DATA.points = PTS_cut;

%% Define optimization constraints as struct C
C.s = 0.75;%compatability constraint
C.c = 0.1; %compatability tolerance
C.errmode = 'squared'; %'abs' or 'squared'
C.R = 1; %xy jump tolerance (NEW: this now only makes sense to be less than the search box, otherwise the searchbox defines the constraint)
C.accel = 0.04; %xy acceleration tolerance
C.dtheta = (pi/2); %theta jump tolerance
C.ddtheta = 0.05; %theta acceleration constraint
C.res = [0.01,0.01,0.005]; %search resolution for r1,r2,th
C.lb = [-1,-0.25,-pi/3]; %lower value bounds
C.ub = [0,1.25,pi/3]; %upper value bounds
C.sb = [0.2,0.2,pi/3]; %search box absolute dimensions
C.bias = zeros(1,size(ANG_cut,2)); %initial biases are zero

%% MODE AND SETUP FOR BOTH OPTIMIZATIONS
mode = 'line_3dof';     % 3 modes: 'line_3dof' , 'line_1dof', 'circular' (circular not yet implemented)
file = 'test1'; % file name
animate = 0;            % generate animation?

%% RUN OPTIMIZATION #1
% TODO: iterate over all new filtered data
TRIAL1 = trajopt(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s

%% Calculate Biases
ypts = TRIAL1.PTS_bio(2,:,1); 
prot = traj2prot(TRIAL1.traj,TRIAL1.s,ypts); %prot is [T,N]
error = prot2error(prot,TRIAL1.ANG_bio,'sign','all');
%rewrite bias
C.bias = -mean(error);

%% RUN OPTIMIZATION #2
TRIAL2 = trajopt(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s
% %add original trial info
% TRIAL2.TRIAL1 = TRIAL1;

%% Saving trials
%part 1
file_trial = append('../output/trial_data/bias/one/',file);
save(file_trial,'-struct','TRIAL1');
%part 2
file_trial = append('../output/trial_data/bias/two/',file);
save(file_trial,'-struct','TRIAL2');



