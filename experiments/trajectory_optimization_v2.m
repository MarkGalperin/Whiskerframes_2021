%% TRAJECTORY OPTIMIZATION
% Trajectory Optimization for biomimetic whiskers

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
% 3 modes: 'line_3dof' , 'line_1dof', 'circular'
mode =   'line_3dof';
file = 'apr28test';
animate = true;

%% Define optimization constraints as struct C
C.c = 0.1; %compatability tolerance
C.R = 0.1; %jump tolerance
C.dtheta = pi/10; %theta jump tolerance

%% Initialize optimization 
%initialize s
s = 0.45;

% initialize values for x = [r1,r2,theta]
xa = [-0.5,1,-0.45];
xb = [-0.5,-0.25,-0.45];
xc = [-0.5,-0.25,+0.45];
xd = [-0.25,0.25,+0.45];

% select initial point % TODO: optimize first point <- throw out first vals
x0 = xd;
th0 = -pi/6;

%equate first two values
xm0 = x0;
xmm0 = x0;

%upper and lower bounds
thmax = pi/3;
thlb = -thmax;
thub = thmax;
vlb = [-1,-0.25,thlb];
vub = [0,1.25,thub];

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
T = size(PTS,3);
x_log = zeros(T + 2 ,3); %two extra entries
x_log(1,:) = xm0;
x_log(2,:) = xm0; %filling the first two values of the log as x0
E_log = zeros(T,1);

%for 1dof
if strcmp(mode,'line_1dof')
    th_log = zeros(T + 1 ,1); %one extra entry
    th_log(1,:) = th0; %initial val
    r_log = zeros(2,T);
elseif strcmp(mode,'debug_test')
    th_lin = linspace(-thmax,thmax,T);
end

%loop
for t = 1:T %loop over each frame
    log_index = t+2; %to not confuse myself <-- this did not work out
    
    %get xm values
    xm = x_log(log_index-1,:);
    xmm = x_log(log_index-2,:);
    if strcmp(mode,'line_1dof')
        thm = th_log(t,:);
    end
    
    %get bio information
    bio_pts = PTS(:,:,t);
    bio_ang = ANG(t,:);
    
    %perform optimization
    fprintf('performing optimization %d \n',t);
    if strcmp(mode,'line_3dof')
        %perform optimization
        objective = @(x) optimization_obj_line(x,s,bio_pts,bio_ang);
        constraint = @(x) optimization_constraint(x,xm,xmm,s,C);
        [x_opt1, fval1, exitflag1, output1] = fmincon(objective,xm, [], [], [], [], vlb, vub, constraint, options);
        %log and update variables
        x_log(log_index,:) = x_opt1;
        E_log(t,1) = fval1;
        
    elseif strcmp(mode,'line_1dof')
        %% get angle info
        a = bio_ang(1); %top
        b = bio_ang(end); %bottom (check this)
        ma = tan(a);
        mb = tan(b);
        M = [ma/(ma-mb) , 1/(mb-ma) ; 1/((1/mb)-(1/ma)) , mb/(mb-ma)];
        
        %% get theta
        %bounds
%         thlb = a - pi/2;
%         thub = b + pi/2;
        thlb = - pi/2;
        thub = pi/2;

        
        %run my brute-force optimizer
        objective_1dof = @(th) optimization_obj_line_1dof(th,M,s,bio_pts,bio_ang);
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
    end
    
    %% loopwise debug
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
if strcmp(mode,'line_3dof')
    traj = x_log(3:end,:); %chop off the first two entries
elseif strcmp(mode,'line_1dof')
    traj = [transpose(r_log),th_log(2:end,:)];
elseif strcmp(mode,'debug_test')
    traj = [transpose(r_log),transpose(th_lin)];
end

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
