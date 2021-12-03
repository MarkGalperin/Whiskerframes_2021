function TRIAL = trajopt(DATA,mode,file,animate,C)
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
%   C: [struct] Constraint and setting struct
%
% Returns...
%   TRIAL: [struct] with all the relevant trial data in it. Both inputs and
%   output trajectory.

    %% Including code
    addpath('../src');
    addpath('../src/deming');
    addpath('../src/optimization');

    %% Initialize optimization 
    %initialize s
    s = C.s;

%     %upper and lower bounds
%     thmax = pi/3;
%     th_lb = -thmax;
%     th_ub = thmax;
%     x_lb = [-1,-0.25,th_lb];
%     x_ub = [0,1.25,th_ub];
    
    %split open DATA
    PTS = DATA.points;
    ANG = DATA.angles;
    
    % set bias values if zeros
    if strcmp(C.bias,'zeros')
        C.bias = zeros(1,size(ANG,2));
    end
    
    %% apply omits to point data 
    if isfield(C,'omit') 
        %applying omit via logical indexing
        PTS(:,C.omit,:) = [];
    end

    %% Optimization Loop
    %INITIALIZE
    T = size(ANG,1); %9/2 changed to ANG to cover discrepancies
    N = size(ANG,2);
    x_log = zeros(T,3);
    E_log = zeros(T,1);
    overc = zeros(T,1); %9/24 - overconstraint log
    info_log = zeros(4,N,T);
    resetflag = 0;
    
    %LOOP
    for t = 1:T
        %display status
        fprintf('performing optimization %d/%d \n',t,T);
        
        % GET BIO DATA
        bio_pts = PTS(:,:,t); %
        bio_ang = ANG(t,:);

        % GET PREVIOUS CONFIGURATION
        % Here, NaN will signal the higher order constraints to
        % deactivate.
        if t==1
            xm = NaN(1,3);
            xmm = NaN(1,3);
        elseif t==2
            xm = x_log(t-1,:);
            xmm = NaN(1,3);
        else
            xm = x_log(t-1,:);
            xmm = x_log(t-2,:);
        end

        %MODE
        switch mode
            case 'line_3dof' %3DOF OPTIMIZER
                
                %% perform optimization
                %define function handles
                objective = @(x) optimization_obj_line(x,s,bio_pts,bio_ang,C);
                constraint = @(x) optimization_constraint(x,xm,xmm,s,C);
                
                %get search box as function of previous state
                SB_u = xm + (0.5)*C.sb;
                SB_l = xm - (0.5)*C.sb;
                
                % Evaluate theta limits based on compat. 
                % This uses previous state which is not totally correct, so
                % a buffering term is added. This is ok because the
                % constraint function should check again to make sure the
                % limits are okay.
%                 if C.thlim
%                     %set buffer
%                     buff = pi/20;
%                     %calculate theta limits
%                     th_lower = 1 - buff;
%                     th_upper = atan2(-xm(2),xm(1)) + buff;
%                     
%                     %assign to search frame
%                     SB_l(3) = th_lower;
%                     SB_u(3) = th_upper;
%                 end
                
                if any(isnan(xm)) || resetflag %first frame chooses from entire seach space
                    xlb = C.lb;
                    xub = C.ub;
                    resetflag = 0;
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
                    
                    %OCT 5 FIX: if th_lower >= th_upper, subtract pi or go
                    %to global lower bound. Upper bound is solid.
                    if xlb(3) >= xub(3)
                        %subtract pi
                        xlb(3) = xlb(3) - pi;
                        
                        %check again
                        if xlb(3) >= xub(3)
                            xlb(3) = C.lb(3); 
                        end
                    end
                    
                end               
                

                %run brute-force optimizer
                res = C.res; %resolution for r1,r2,th
                [x, err] = opt3dof(objective,xlb,xub,res,constraint);
                
                %handle overconstraint
                if isnan(x)
                    %log overconstraint event and error
                    overc(t,1) = 1;
                    [err,~] = objective(xm);
                    
                    %set control frame to previous position
                    x = xm;
                    xm = xmm;
                    
                    % RESET CASE
                    if t >= C.ovrct && sum(overc(1+t-C.ovrct:t)) == C.ovrct %if there have been C.ovrct events in the last C.ovrct time frames
                        %RESET CONSTRAINTS
                        fprintf('PERFORMING RESET \n')
                        resetflag = 1; %this will trigger no constraints in the next loop
%                         %RESET TIME?
%                         timereset = false;
%                         if timereset
%                             t = 1+t-C.ovrct; %reset time to the first time overconstraint occurred
%                         end
                    end
                    
                else
                    %possibly overwrite previous overconstraints in the
                    %case that time was reset
                    overc(t,1) = 0;
                end
                
                %get info
                [~,info] = objective(x);
                
                
                %% log values
                x_log(t,:) = x;
                E_log(t,1) = err;
                info_log(:,:,t) = info;

            case 'line_1dof' %1DOF OPTIMIZER
                %% get angle info
                a = bio_ang(end); %top
                b = bio_ang(1); %bottom (check this)
                ma = tan(a);
                mb = tan(b);
                M = [ma/(ma-mb) , 1/(mb-ma) ; 1/((1/mb)-(1/ma)) , mb/(mb-ma)];
                
                %% Get previous thetas
                thm = xm(3);
                thmm = xmm(3);
                
                %% Perform optimization to get theta
                %bounds
                thlb = a - pi/2;
                thub = b + pi/2;
                %modify bounds in reset case
                if resetflag
                    thlb = C.lb(3);
                    thub = C.ub(3);
                end
                
                %define objective and constraint
                objective =  @(th) optimization_obj_line_1dof(th,M,s,bio_pts,bio_ang,C);
                constraint = @(th) optimization_constraint_1dof(th,thm,thmm,M,C,t);

                %run brute-force optimizer
                res = C.res(3);
                [th, err, graph] = opt1dof(objective,[thlb,thub],res,constraint);
                
                %% Handle overconstraint
                if isnan(th)
                    %log overconstraint and error
                    overc(t,1) = 1;
                    [err,~] = objective(thm);
                    
                    %set control frame to previous position
                    th = thm;
                    thm = thmm;
                    
                    %RESET CASE (for when overconstraint occurs (C.ovrct) times in a row)
                    if t >= C.ovrct && sum(overc(1+t-C.ovrct:t)) == C.ovrct
                        %RESET CONSTRAINTS
                        fprintf('PERFORMING RESET \n')
                        resetflag = 1;                    
                    end
                    
                else
                    overc(t,1) = 0;
                end

                %% get r
                %w vector
                w = [s*sin(th);1-s*cos(th)];
                r = M*w;
                
                %% make x
                x = [r',th];
                
                %% get info
                [~,info] = objective(x);
                
                %% log values
                x_log(t,:) = x;
                E_log(t,1) = err;
                info_log(:,:,t) = info;
                
                %% set previous
                x = xm;
                xm = xmm;

        end
    end

    %% get trajectory
    traj = x_log;
    
    %% calcuate absolute error mean          
    info_derror = permute(info_log(3,:,:),[3 2 1]);
    aem = mean(abs(info_derror));
    
    %% derive other stuff from trajectory...
    %calculate p1 p2
    traj_w = coordchange(traj,C.s,'rp');
    %calculate m1 m2
    traj_m = coordchange(traj,C.s,'rm');
    %mechanical protractions
    prot = permute(info_log(1,:,:),[3 2 1]);
    
    
    %% Saving trial data
    %for my own sake, should package everything into this struct...
    TRIAL = struct('traj',traj,...
                   'error',E_log,...
                   'info',info_log,...
                   'mode',mode,...
                   'constraints',C,...
                   's',s,...
                   'PTS_bio',PTS,...
                   'ANG_bio',ANG,...
                   'file',file,...
                   'overc',overc,...
                   'abserrmean',aem,...
                    'traj_w',traj_w,...
                    'traj_m',traj_m,...
                    'prot',prot,...
                    'dataset_num',C.datasetnum,...
                    'constraint_num',C.constraintnum);  
               
    %% ANIMATE %%
    if animate
        complete = optimization_animate(TRIAL);
    else
        complete = 1;
    end

end

