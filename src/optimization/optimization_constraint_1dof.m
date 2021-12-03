function G = optimization_constraint_1dof(th,thm,thmm,M,C,t)
%CONSTRAINT FUNCTION
%   This function returns the cost for a certain configuration of design
%   variables 
%   TAKES:  th: theta at current time t
%           thm: theta from t = t-1
%           thmm: theta from t = t-2
%           s: constant length fraction


%% define constants
c = C.c; %compatability tolerance
s = C.s;
dtheta = C.dtheta; %velocity tolerance
ddtheta = C.ddtheta; %acceleration tolerance

%% get r (for compat. constraint)
%w vector
w = [s*sin(th);1-s*cos(th)];
r = M*w;

%% evaluate constraints
if isnan(thm) %first frame

    %% Constraints
    %compatability
    g1 = r(1) + c; %bottom edge away from face frame
    g2 = r(1) - s*sin(th) + c; %top edge away from face frame
      
    %velocity constraint
    g3 = -1; %exempt
    
    %acceleration constraint
    g4 = -1; %exempt
    
elseif isnan(thmm) %second frame
    %calculate velocity
    dth  = th - thm;
    dthm = thm - thmm;
    
    %% Constraints
    %compatability
    g1 = r(1) + c; %bottom edge away from face frame
    g2 = r(1) - s*sin(th) + c; %top edge away from face frame
      
    %velocity constraint
    g3 = abs(dth)-dtheta; %dtheta within velocity constraint
    
    %acceleration constraint
    g4 = -1; %exempt
    
else %all next frames
    %calculate velocity
    dth  = th - thm;
    dthm = thm - thmm;
    
    %calculate acceleration
    ddth = dth - dthm;
    
    %% Constraints
    %compatability
    g1 = r(1) + c; %bottom edge away from face frame
    g2 = r(1) - s*sin(th) + c; %top edge away from face frame
      
    %velocity constraint
    g3 = abs(dth)-dtheta; %dtheta within velocity constraint
    
    %acceleration constraint
    g4 = abs(ddth)-ddtheta; %ddtheta within acceleration constraint

    %debug
    if t == 124
        debug = 'here';
    end
    
    
end

%% return constraints
G = [g1;g2;g3;g4];

end

% 3 dof comparison below...
% %% define constraints
% %check for NaN
% if any(isnan(xm))
%     %compatability
%     g1 = x(1) + c; %bottom edge away from face frame
%     g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
%     g3 = -x(1)/rwcross + 1; %control frame not parallel to bottom whisker.
%     g4 = (w1-x(1))/rwcross + 1; %control frame not parallel to top whisker.
%     
%     %velocity constraints
%     g5 = -1; %exempt
%     g6 = -1; %exempt
%     %acceleration constraints
%     g7 = -1; %exempt
%     g8 = -1; %exempt 
%     
% elseif any(isnan(xmm))
%     %velocities
%     dx = x(1:2)-xm(1:2);
%     dth = x(3) - xm(3);
%     %compatability constraints
%     g1 = x(1) + c; %bottom edge away from face frame
%     g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
%     g3 = -x(1)/rwcross + 1; %control frame not parallel to bottom whisker.
%     g4 = (w1-x(1))/rwcross + 1; %control frame not parallel to top whisker.
% 
%     %velocity constraints
%     g5 = norm(dx)-R; %dr within radius R
%     g6 = abs(dth)-dtheta; %change in theta within "dtheta"
%     %acceleration constraints
%     g7 = -1; %exempt
%     g8 = -1; %exempt
% else
%     %velocities
%     dx = x(1:2)-xm(1:2);
%     dxm = xm(1:2)-xmm(1:2);
%     dth = x(3) - xm(3);
%     dthm = xm(3) - xmm(3);
%     
%     %accelerations
%     ddx = dx-dxm;
%     ath = dth-dthm;
%     
%     %compatability
%     g1 = x(1) + c; %bottom edge away from face frame
%     g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
%     g3 = -x(1)/rwcross + 1; %control frame not parallel to bottom whisker.
%     g4 = (w1-x(1))/rwcross + 1; %control frame not parallel to top whisker.
%     
%     %velocity constraints 
%     g5 = norm(dx)-R; %dr within radius R
%     g6 = abs(dth)-dtheta; %dtheta within "dtheta"
%     
%     %acceleration constraints
%     g7 = norm(ddx)-accel; 
%     g8 = abs(ath)-ddtheta; 
% end
% 
% %% return constraint check
% C_check = [g1;g2;g3;g4;g5;g6;g7;g8];

