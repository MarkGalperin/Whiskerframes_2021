%% TRAJECTORY OPTIMIZATION (1dof)
% Trajectory Optimization for biomimetic whiskers. This subtracts out all
% the 3dof garbage

% This experiment finds an optimal trajectory of the Whisker Frames
% control frame given biologically-observed time data for N whiskers
clear;
clc;
clf;

%% Including code
addpath('../src');
addpath('../src/deming');
addpath('../src/optimization');

%% Fetch pre-processed data
DATA = load('../data/processed/dlc_MSE.mat');
PTS = DATA.points; %[3xNxT]
ANG = DATA.angles; %[T,N]

%% OPTIMIZATION MODE AND SETUP
mode = 'line_1dof';
file = 'apr22test';
animate = true;

%% Define optimization constraints as struct C
C.c = 0.1; %compatability tolerance
C.R = 0.05; %jump tolerance
C.dtheta = pi/8; %theta jump tolerance

%% Initialize optimization
%initialize s
s = 0.6;

% select initial point % TODO: optimize first point <- throw out first vals
th0 = -pi/6;
                
%% Optimization Loop
%initialize loop
T = size(PTS,3);
E_log = zeros(T,1);

th_log = zeros(T + 1 ,1); %one extra entry
th_log(1,1) = th0; %initial val
r_log = zeros(2,T);

%loop
for t = 1:T %loop over every timestep
    %thm is the previous theta value, used in constraint
    thm = th_log(t,1);

    %get bio information
    bio_pts = PTS(:,:,t); %[3xN]
    bio_ang = ANG(t,:); %[1xN]
    bio_traj(t,:) = bio_ang;
    
    %perform optimization
    fprintf('performing optimization %d \n',t);
        
    %% get angle info
    a = bio_ang(1); %top
    b = bio_ang(end); %bottom (check this)
    ma = tan(a);
    mb = tan(b);
    M = [ma/(ma-mb) , 1/(mb-ma) ; 1/((1/mb)-(1/ma)) , mb/(mb-ma)];

    %% get theta
    %bounds
    thlb = a - pi/2;
    thub = pi/2 + b;

    %run my brute-force optimizer
    objective_1dof = @(th) optimization_obj_line_1dof(th,M,s,bio_pts,bio_ang,t);
    constraint_1dof = @(th) optimization_constraint_1dof(th,thm,M,s,C);
    res = 0.005;
    [th, err, graph] = opt1dof(objective_1dof,[thlb,thub],res,constraint_1dof);

    %% get r
    %w vector
    w = [s*sin(th);1-s*cos(th)];
    r = M*w;

    %% log values
    th_log(t+1,:) = th; %next value will be thm later
    r_log(1:2,t) = r;
    E_log(t,1) = err;
    
    %% stepwise debug
    debug = false;
    if debug
        %state time
        fprintf('t = %d \n',t);
        %theta vals
        fprintf('current theta = %f, new theta = %f \n',thm,th);
        fprintf('Error val = %f \n',err);
        fprintf('thlb = %f, thub = %f \n',thlb,thub);
        %plot stuff
        hold on
        plot(graph.x,graph.y);
        plot([graph.x(1),graph.x(end)],[err,err], '--r')
        titlestr = sprintf('Error min = %f',err);
        title(titlestr);
        hold off
        %wait for user input
        input('next? \n');
    end
end

%% Get trajectory
traj = [transpose(r_log),th_log(2:end,:)];


%% Generate trajectory plot
traj_plot = trajectory_plot(traj,[thlb,thub]);
%save plot
path_traj = '../output/figures/trajectory/';
traj_file = append(file,'_traj');
saveas(traj_plot, fullfile(path_traj, traj_file), 'png');

%% Generate error plot
err_plot = error_plot(E_log);
%save plot
path_err = '../output/figures/error/';
err_file = append(file,'_err');
saveas(err_plot, fullfile(path_err, err_file), 'png');

%% Saving trial data
TRIAL = struct('traj',traj,'error',E_log,'mode',mode,'constraints',C,'s',s);
file_trial = append('../output/trial_data/',file);
save(file_trial,'-struct','TRIAL');

%% ANIMATE %%
if animate
    complete = optimization_animate(traj,PTS,ANG,E_log,s,mode,file);
end

%% done
fprintf('DONE \n');
