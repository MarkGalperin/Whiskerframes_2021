function complete = trajopt(DATA,mode,file,animate,C)
%% TRAJECTORY OPTIMIZATION
% Trajectory Optimization for biomimetic whiskers
%
% This experiment finds an optimal trajectory of the Whisker Frames
% control frame given biologically-observed time data for N whiskers
%
% Takes... 
%   DATA: [struct] Struct containing PTS and ANG
%   mode: [str] mode: 'line_1dof' or 'line_3dof' or 'debug'
%   file: [str] filename
%   animate: [bool] Generate animation
%   C: [struct] Constraint struct

    %% Including code
    addpath('../src');
    addpath('../src/deming');
    addpath('../src/optimization');

    %% Initialize optimization 
    %initialize s
    s = C.s;

    %upper and lower bounds
    thmax = pi/3;
    th_lb = -thmax;
    th_ub = thmax;
    x_lb = [-1,-0.25,th_lb];
    x_ub = [0,1.25,th_ub];
    
    %split open DATA
    PTS = DATA.points;
    ANG = DATA.angles;
    

    %% Optimization Loop
    %INITIALIZE
    T = size(PTS,3);
    x_log = zeros(T,3);
    E_log = zeros(T,1);
    
    %LOOP
    for t = 1:T
        %display status
        fprintf('performing optimization %d/%d \n',t,T);
        
        % GET BIO DATA
        bio_pts = PTS(:,:,t);
        bio_ang = ANG(t,:);

        % GET PREVIOUS CONFIGURATION
        % Here, NaN will signal the higher order constraints to
        % deactivate.
        if t==1
            xm = NaN(1,3);
            xmm = NaN(1,3);
            xmmm = NaN(1,3);
        elseif t==2
            xm = x_log(t-1,:);
            xmm = NaN(1,3);
            xmmm = NaN(1,3);
        elseif t==3
            xm = x_log(t-1,:);
            xmm = x_log(t-2,:);
            xmmm = NaN(1,3);
        else
            xm = x_log(t-1,:);
            xmm = x_log(t-2,:);
            xmmm = x_log(t-3,:);
        end

        %MODE
        switch mode
            case 'line_3dof' %3DOF OPTIMIZER
                
                %% perform optimization
                %define function handles
                objective = @(x) optimization_obj_line(x,s,bio_pts,bio_ang);
                constraint = @(x) optimization_constraint3(x,xm,xmm,xmmm,s,C);
                
                %get search box as function of previous state
                SB_u = xm + (0.5)*C.sb;
                SB_l = xm - (0.5)*C.sb;
                if any(isnan(xm))
                    xlb = C.lb;
                    xub = C.ub;
                else
                    %make sure nothing exceeds global bounds
                    for ii = 1:3
                        if SB_u(ii) > C.ub(ii)
                            SB_u(ii) = C.ub(ii);
                        end
                        if SB_l(ii) < C.lb(ii)
                            SB_l(ii) = C.lb(ii);
                        end
                    end
                    %assign local search space
                    xlb = SB_l;
                    xub = SB_u;
                end

                %run brute-force optimizer
                res = C.res; %resolution for r1,r2,th
                [x, err] = opt3dof(objective,xlb,xub,res,constraint);
                if isnan(x)
                    x = xm;
                    err = E_log(t-1,1);
                end
                
                %% log values
                x_log(t,:) = x;
                E_log(t,1) = err;

            case 'line_1dof' %1DOF OPTIMIZER
                %% get angle info
                a = bio_ang(1); %top
                b = bio_ang(end); %bottom (check this)
                ma = tan(a);
                mb = tan(b);
                M = [ma/(ma-mb) , 1/(mb-ma) ; 1/((1/mb)-(1/ma)) , mb/(mb-ma)];

                %% Perform optimization to get theta
                %bounds
                thlb = C.lb(3);
                thub = C.ub(3);

                %define objective and constraint
                objective_1dof =  @(th) optimization_obj_line_1dof(th,M,s,bio_pts,bio_ang);
                constraint_1dof = @(th) optimization_constraint_1dof(th,thm,M,s,C);

                %run brute-force optimizer
                res = 0.005;
                [th, err, graph] = opt1dof(objective_1dof,[thlb,thub],res,constraint_1dof);

                %% get r
                %w vector
                w = [s*sin(th);1-s*cos(th)];
                r = M*w;
                
                %% make x
                x = [r',th];

                %% log values
                x_log(t,:) = x;
                E_log(t,1) = err;

        end
    end

    %% get trajectory
    traj = x_log;
    
    %% Saving trial data
    TRIAL = struct('traj',traj,'error',E_log,'mode',mode,'constraints',C,'s',s);
    file_trial = append('../output/trial_data/',file);
    save(file_trial,'-struct','TRIAL');

    %% ANIMATE %%
    if animate
        complete = optimization_animate(traj,PTS,ANG,E_log,s,mode,file);
    else
        complete = 1;
    end

end

