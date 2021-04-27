%% MARK GALPERIN - ME441 (Design Optimization) Final Project
% Trajectory Optimization for biomimetic whiskers

% This experiment finds an optimal trajectory of the Whisker Frames
% control frame given biologically-observed time data for N whiskers

%% Including code
addpath('../src');
addpath('../src/deming');

%% Fetch pre-processed data
DATA = load('../data/processed/dlc_MSE.mat');
YPTS = DATA.points;
ANG = DATA.angles;

%% Initialize optimization
%initialize s
s = 0.45;

% initialize values for x = [r1,r2,theta]
xa = [-0.5,1,-0.45];
xb = [-0.5,-0.25,-0.45];
xc = [-0.5,-0.25,+0.45];
xd = [-0.25,0.25,+0.45];

% select initial point
x0 = xd;

%equate first two values
xm0 = x0;
xmm0 = x0;

%upper and lower bounds
thmax = pi/3;
vlb = [-1,-0.25,-thmax];
vub = [0,1.25,thmax];

%% Define Optimization options
% options = optimset('Display', 'iter',...
%                     'MaxFunEvals', 3000, ... 
%                     'LargeScale', 'off', ... 
%                     'TolCon', 0.0001, ... 
%                     'TolX', 0.0001,...
%                     'PlotFcns','optimplotfval');
options = optimset('Display','none', ...
                    'MaxFunEvals', 3000, ... 
                    'LargeScale', 'off', ... 
                    'TolCon', 0.0001, ... 
                    'TolX', 0.0001);

%% Optimization Loop
%initialize log values
T = size(YPTS,1);
x_log = zeros(T + 2 ,3); %two extra entries
x_log(1,:) = xm0;
x_log(2,:) = xm0; %filling the first two values of the log as x0
E_log = zeros(T,1);

%loop
for ii = 1:T %loop over every timestep
    log_index = ii+2; %to not confuse myself
    
    %get xm values
    xm = x_log(log_index-1,:);
    xmm = x_log(log_index-2,:);
    
    %get bio information
    bio_pts = YPTS(ii,:);
    bio_ang = ANG(ii,:);
    
    %perform optimization
    fprintf('performing optimization %d \n',ii);
    [x_opt1, fval1, exitflag1, output1] = fmincon(@(x) opterror(x,s,bio_pts,bio_ang),xm, [], [], [], [], vlb, vub, @(x) optconst(x,xm,xmm,s), options);
    %log and update variables
    x_log(log_index,:) = x_opt1;
    E_log(ii,1) = fval1;
    
end

%% Get trajectory
traj = x_log(3:end,:); %chop off the first two entries

%% Animate, etc. TODO: debug if necessary?
file = 'apr10test';
complete = animate_optimized(traj,ANG,E_log,s,file);

%% Generate trajectory plot
traj_plot = trajectory_plot(traj);
path = '../output/movies/optimization/';
%save plot
traj_file = append(file,'_traj');
saveas(traj_plot, fullfile(path, traj_file), 'png');

%% Generate error plot
err_plot = error_plot(E_log);
%save plot
err_file = append(file,'_err');
saveas(err_plot, fullfile(path, err_file), 'png');

%% done
fprintf('DONE \n');
