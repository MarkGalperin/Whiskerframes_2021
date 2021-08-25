function C_check = optimization_constraint2(x,xm,xmm,s,C)
%CONSTRAINT FUNCTION
%   This function returns the cost for a certain configuration of design
%   variables 
%   TAKES:  x: [r1 r2 theta] at current time t
%           xm: x from t = t-1
%           xmm: x from t = t-2
%           s: constant length fraction

%% define constants
c = C.c; %compatability tolerance
R = C.R; %velocity constraint
accel = C.accel; %acceleration constraint
dtheta = C.dtheta;
ddtheta = C.ddtheta;

%% define constraints
%check for NaN
if any(isnan(xm))
    %compatability constraints
    g1 = x(1) + c; %bottom edge away from face frame
    g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
    %velocity constraints
    g3 = -1; %exempt
    g4 = -1; %exempt
    %acceleration constraints
    g5 = -1; %exempt
    g6 = -1; %exempt  
elseif any(isnan(xmm))
    %velocities
    dx = x(1:2)-xm(1:2);
    dth = x(3) - xm(3);
    %compatability constraints
    g1 = x(1) + c; %bottom edge away from face frame
    g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
    %velocity constraints
    g3 = norm(dx)-R; %dr within radius R
    g4 = abs(dth)-dtheta; %change in theta within "dtheta"
    %acceleration constraints
    g5 = -1; %exempt
    g6 = -1; %exempt
else
    %velocities
    dx = x(1:2)-xm(1:2);
    dxm = xm(1:2)-xmm(1:2);
    dth = x(3) - xm(3);
    dthm = xm(3) - xmm(3);
    
    %accelerations
    ddx = dx-dxm;
    ath = dth-dthm;
    
    %compatability
    g1 = x(1) + c; %bottom edge away from face frame
    g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
    
    %velocity constraints 
    g3 = norm(dx)-R; %dr within radius R
    g4 = abs(dth)-dtheta; %dtheta within "dtheta"
    
    %acceleration constraints
    g5 = norm(ddx)-accel; 
    g6 = abs(ath)-ddtheta; 
end

%% return constraint check
C_check = [g1;g2;g3;g4;g5;g6];

end
