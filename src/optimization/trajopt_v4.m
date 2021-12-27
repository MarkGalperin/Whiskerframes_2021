function TRIAL = trajopt_v4(DATA,mode,file,animate,C)
%% TRAJECTORY OPTIMIZATION (v4)
% Trajectory Optimization for biomimetic whiskers - version 4
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
    %initialize timer
    tic;
    
    %initialize s
    s = C.s;
    
    %split open DATA
    PTS = DATA.points;
    ANG = DATA.angles;
    
    % set bias values if zeros
    if strcmp(C.bias,'zeros')
        C.bias = zeros(1,size(ANG,2));
    end

    %% Optimization Loop
    %INITIALIZE
    T = size(ANG,1);
    N = size(ANG,2);
    x_log = zeros(T,3);
    E_log = zeros(T,1);
    overc = zeros(T,1); 
    rlx_log = zeros(T,1); 
    info_log = zeros(4,N,T);
    resetflag = 0;
    
    %calculate full search space mesh, based on mode
    if strcmp(mode,'line_3dof')
        %3-dof search space
        r1_range = C.lb(1):C.res(1):C.ub(1);
        r2_range = C.lb(2):C.res(2):C.ub(2);
        th_range = C.lb(3):C.res(3):C.ub(3);
        [R1,R2,TH] = meshgrid(r1_range,r2_range,th_range);    
        %assemble full search space 
        S0 = [R1(:),R2(:),TH(:)];
        
    elseif strcmp(mode,'line_1dof')
        %1-dof search space
        th_range = C.lb(3):C.res(3):C.ub(3);
        TH = th_range';   
    end
    
    %TRANSFORM SEARCH SPACE FOR 3-DOF
    if isfield(C,'axis') && strcmp(mode,'line_3dof')
        switch C.axis
            case 'r'
                %do nothing!
            case 'm'
                % transform the search space from "m" to "r" coordinates
                S0 = coordchange(S0,s,'mr');
        end
    end

    %LOOP
    for t = 1:T
    %%%%%%%%%%%%%%%%%%%%%%%% TIME LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %display status at t = t
        fprintf('Performing Optimization %d/%d \n',t,T);
        
        % GET BIO DATA
        bio_pts = PTS(:,:,t); 
        bio_ang = ANG(t,:);
        
        % (1-dof setup)
        if strcmp(mode,'line_1dof')
            % get M matrix
            a = bio_ang(end); %top
            b = bio_ang(1); %bottom (check this)
            ma = tan(a);
            mb = tan(b);
            M = [ma/(ma-mb) , 1/(mb-ma) ; 1/((1/mb)-(1/ma)) , mb/(mb-ma)];
            
            % get w array
            w = [s*sin(TH),1-s*cos(TH)]';
            
            % construct S0
            S0 = [(M*w)',TH]; %this calculates r = M*w for the first two columns, then theta for third
        end

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

        %% OPTIMIZER               
        %first frame chooses from entire seach space
        if any(isnan(xm)) || resetflag 
            %search set is the entire set
            S1 = S0;
            if resetflag == 1
                db = 'here';
            end
            resetflag = 0;
            
        else
            %get the unconstrained search set S1 as fxn of xm
            r1_min = max([C.lb(1),xm(1)-C.sb(1)/2]);
            r1_max = min([C.ub(1),xm(1)+C.sb(1)/2]);
            r2_min = max([C.lb(2),xm(2)-C.sb(2)/2]);
            r2_max = min([C.ub(2),xm(2)+C.sb(2)/2]);
            th_min = max([C.lb(3),xm(3)-C.sb(3)/2]);
            th_max = min([C.ub(3),xm(3)+C.sb(3)/2]);
            S0_i = (S0(:,1) > r1_min) & (S0(:,1) < r1_max) &...
                   (S0(:,2) > r2_min) & (S0(:,2) < r2_max) &...
                   (S0(:,3) > th_min) & (S0(:,3) < th_max); %index
            %index full search space
            S1 = S0(S0_i,:); %this is the unconstrained search set
        end               

        % APPLY CONSTRAINTS %
        [~,S1_i,rlxi] = newconst(S1,xm,xmm,C);
        %apply index
        S2 = S1(S1_i,:); %S2 is the feasible set
        clear S1 %clear S1 so its not in memory
        
        %log relaxation
        rlx_log(t) = rlxi;

        %handle overconstraint
        if ~isempty(S2)
            % EVALUATE FEASIBLE SET % 
            [Errs,Prot,Dang] = newobj(S2,C,bio_pts,bio_ang);
            %get mean error
            E = mean(Errs,2); %error over candidate configs
            %EVALUATE MINIMUM ERROR CONFIG
            [err,min_i] = min(E);
            x = S2(min_i,:);
            %return info at minimum error
            info = [Prot(min_i,:);  ...
                    bio_ang;        ...
                    Dang(min_i,:);  ...
                    Errs(min_i,:)];
        else
            %announce overconstraint
            fprintf('OVERCONSTRAINED \n');

            %log overconstraint event and error
            overc(t,1) = 1;

            %calculate error based on previous config
            [Errs,Prot,Dang] = newobj(xm,C,bio_pts,bio_ang);
            E = mean(Errs,2); %error over candidate configs
            [err,min_i] = min(E);
            info = [Prot(min_i,:);  ...
                    bio_ang;        ...
                    Dang(min_i,:);  ...
                    Errs(min_i,:)];

            %set control frame to previous position (stay in place)
            x = xm;
            xm = xmm; 

            % RESET CASE
            if t >= C.ovrct && sum(overc(1+t-C.ovrct:t)) == C.ovrct %if there have been C.ovrct events in the last C.ovrct time frames
                %RESET CONSTRAINTS
                fprintf('PERFORMING RESET \n')
                resetflag = 1; %this will trigger no constraints in the next loop
            end
        end

        % log values
        x_log(t,:) = x;
        E_log(t,1) = err;
        info_log(:,:,t) = info;

        % set previous
        x = xm;
        xm = xmm;

    %%%%%%%%%%%%%%%%%%%% END TIME LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    %% get trajectory
    traj = x_log;
    
    %% calcuate absolute error mean          
    info_derror = permute(info_log(3,:,:),[3 2 1]);
    aem = mean(abs(info_derror),'omitnan');
    
    %% derive other stuff from trajectory...
    %calculate p1 p2
    traj_w = coordchange(traj,C.s,'rp');
    %calculate m1 m2
    traj_m = coordchange(traj,C.s,'rm');
    %mechanical protractions
    prot = permute(info_log(1,:,:),[3 2 1]);
    
    %% end timer
    telapsed = toc;
    
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
                    'constraint_num',C.constraintnum,...
                    'timer',telapsed,...
                    'relax',rlx_log);  
               
    %% ANIMATE %%
    if animate
        complete = optimization_animate(TRIAL);
    else
        complete = 1;
    end

end

