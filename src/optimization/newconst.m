function [g_arr,S_i,rlxi] = newconst(x,xm,xmm,C)
%NEWCONST new (test) constraint function. 
% Takes...
%   x:   [Ncand x 3] Candidate set of configurations to loop through
%   xm:  [1x3] Configuration at t = t-1
%   xmm: [1x3] Configuration at t = t-2
% Returns...
%   g_arr: [Ncand x 9] Boolean constraint satisfied or not
%   S_i: [Ncand x 1] indices of feasible set

    %% define constraint constants
    c = C.c; %compatability tolerance
    R = C.R; %velocity constraint
    s = C.s;
    accel = C.accel; %acceleration constraint
    dtheta = C.dtheta;
    ddtheta = C.ddtheta;

    %% pre-calculate a thing
    w1 = s*sin(x(:,3));
    rwcross = x(:,1).*(1 - s*cos(x(:,3)))-x(:,2).*w1;
    exempt = true(size(x,1),1);

    %% calculate constraints for all candidates
    if any(isnan(xm))
        %compatability
        g1 = (x(:,1) + c) <= 0; %bottom edge away from face frame
        g2 = (x(:,1) - s*sin(x(:,3)) + c) <= 0; %top edge away from face frame
        g3 = (-x(:,1)./rwcross + 1) <= 0; %control frame not parallel to bottom whisker.
        g4 = ((w1-x(:,1))./rwcross + 1) <= 0; %control frame not parallel to top whisker.

        %velocity constraints 
        g5 = exempt; %exempt
        g6 = exempt; %exempt
        %acceleration constraints
        g7 = exempt; %exempt
        g8 = exempt; %exempt
        
    elseif any(isnan(xmm))        
        %compatability
        g1 = (x(:,1) + c) <= 0; %bottom edge away from face frame
        g2 = (x(:,1) - s*sin(x(:,3)) + c) <= 0; %top edge away from face frame
        g3 = (-x(:,1)./rwcross + 1) <= 0; %control frame not parallel to bottom whisker.
        g4 = ((w1-x(:,1))./rwcross + 1) <= 0; %control frame not parallel to top whisker.

        %velocity constraints 
        g5 = (vecnorm([x(:,1)-xm(1),x(:,2) - xm(2)],2,2)-R) <= 0; %dr within radius R
        g6 = (abs(x(:,3) - xm(3))-dtheta) <= 0; %dtheta within "dtheta"

        %acceleration constraints
        g7 = exempt; %exempt
        g8 = exempt; %exempt
        
    else
        %compatability
        g1 = (x(:,1) + c) <= 0; %bottom edge away from face frame
        g2 = (x(:,1) - s*sin(x(:,3)) + c) <= 0; %top edge away from face frame
        g3 = (-x(:,1)./rwcross + 1) <= 0; %control frame not parallel to bottom whisker.
        g4 = ((w1-x(:,1))./rwcross + 1) <= 0; %control frame not parallel to top whisker.

        %velocity constraints 
        g5 = (vecnorm([x(:,1)-xm(1),x(:,2) - xm(2)],2,2)-R) <= 0; %dr within radius R
        g6 = (abs(x(:,3) - xm(3))-dtheta) <= 0; %dtheta within "dtheta"

        %acceleration constraints
        g7 = (vecnorm([x(:,1)-xm(1),x(:,2) - xm(2)]-(xm(1:2)-xmm(1:2)),2,2)-accel) <= 0; 
        g8 = (abs((x(:,3) - xm(3))-(xm(3) - xmm(3)))-ddtheta) <= 0; 
    end
    
    %% Collect constraints and evaluate feasible set
    g_arr = [g1,g2,g3,g4,g5,g6,g7,g8]; %array of constraint equation values < 0
    clear g1 g2 g3 g4 g5 g6 g7 g8
    
    %% relaxation algorithm, if overconstraint
    rlxi = 0; 
    if ~any(all(g_arr,2)) && isfield(C,'relax') && C.relax == 1
        %try to measure which constraints are "most problematic"
        sums = zeros(1,8);
        for gi = 1:8
            b = ones(8,1);
            b(gi,1) = 0;
            sums(gi) = sum(g_arr*b == 7); %sums records how many candidates remain when a certain constraint gi is relaxed.
        end
        
        %check if any feasible set occurs...
        if any(sums)
            %find "most problematic" constraint and exclude it
            [~,rlx_i] = max(sums);
            if rlx_i > 4 %avoid compat. constraints
                g_arr(:,rlx_i) = exempt;        
                %pass this up to be logged
                rlxi = rlx_i;
            end
        end
    end
    
    %% feasible set returned where all constraints are satisfied
    S_i = all(g_arr,2);
    

end



% %% HOW THE CODE USED TO LOOK BEFORE MEMORY CONSIDERATIONS
% The reason this code is not very easily readible is due to me
% restricting myself from replicating variables, which can be in the
% gigabyte range for this brute-force thing. Below is how it used to be.

% %% define constraint constants
%     c = C.c; %compatability tolerance
%     R = C.R; %velocity constraint
%     s = C.s;
%     accel = C.accel; %acceleration constraint
%     dtheta = C.dtheta;
%     ddtheta = C.ddtheta;
% 
%     %% unpack candidates
%     r1 = x(:,1);
%     r2 = x(:,2);
%     th = x(:,3);
% 
%     %% pre-calculate a thing
%     w1 = s*sin(th);
%     w2 = 1 - s*cos(th);
%     rwcross = r1.*w2-r2.*w1;
%     exempt = -1*ones(size(x,1),1,'int8');
% 
%     %% calculate constraints for all candidates
%     if any(isnan(xm))
%         %compatability
%         g1 = r1 + c; %bottom edge away from face frame
%         g2 = r1 - s*sin(th) + c; %top edge away from face frame
%         g3 = -r1./rwcross + 1; %control frame not parallel to bottom whisker.
%         g4 = (w1-r1)./rwcross + 1; %control frame not parallel to top whisker.
% 
%         %velocity constraints 
%         g5 = exempt; %exempt
%         g6 = exempt; %exempt
%         %acceleration constraints
%         g7 = exempt; %exempt
%         g8 = exempt; %exempt
%         
%     elseif any(isnan(xmm))
%         %velocities
%         dx = [r1-xm(1),r2 - xm(2)]; %candidate dx
%         dxm = [xm(1:2)-xmm(1:2)]; %existing dxm
%         dth = th - xm(3); %candidate dth
%         dthm = xm(3) - xmm(3); %existing dthm
%         
%         %compatability
%         g1 = r1 + c; %bottom edge away from face frame
%         g2 = r1 - s*sin(th) + c; %top edge away from face frame
%         g3 = -r1./rwcross + 1; %control frame not parallel to bottom whisker.
%         g4 = (w1-r1)./rwcross + 1; %control frame not parallel to top whisker.
% 
%         %velocity constraints 
%         g5 = vecnorm(dx,2,2)-R; %dr within radius R
%         g6 = abs(dth)-dtheta; %dtheta within "dtheta"
% 
%         %acceleration constraints
%         g7 = exempt; %exempt
%         g8 = exempt; %exempt
%         
%     else
%         %velocities
%         dx = [r1-xm(1),r2 - xm(2)]; %candidate dx
%         dxm = [xm(1:2)-xmm(1:2)]; %existing dxm
%         dth = th - xm(3); %candidate dth
%         dthm = xm(3) - xmm(3); %existing dthm
% 
%         %accelerations
%         ddr = dx-dxm; %candidate ddx
%         ddth = dth-dthm; %candidate ddth
% 
%         %compatability
%         g1 = r1 + c; %bottom edge away from face frame
%         g2 = r1 - s*sin(th) + c; %top edge away from face frame
%         g3 = -r1./rwcross + 1; %control frame not parallel to bottom whisker.
%         g4 = (w1-r1)./rwcross + 1; %control frame not parallel to top whisker.
% 
%         %velocity constraints 
%         g5 = vecnorm(dx,2,2)-R; %dr within radius R
%         g6 = abs(dth)-dtheta; %dtheta within "dtheta"
% 
%         %acceleration constraints
%         g7 = vecnorm(dx,2,2)-accel; 
%         g8 = abs(ddth)-ddtheta; 
%     end
%     
%     %% Return stuff
%     g_arr = [g1 <= 0,g2 <= 0,g3 <= 0,g4 <= 0,...
%              g5 <= 0,g6 <= 0,g7 <= 0,g8 <= 0]; %array of constraint equation values < 0
%     S_i = all(g_arr,2); %indices of accepted constraints 


