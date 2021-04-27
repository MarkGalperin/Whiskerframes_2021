function G = optimization_constraint_1dof(th,thm,M,s,C)
%CONSTRAINT FUNCTION
%   This function returns the cost for a certain configuration of design
%   variables 
%   TAKES:  x: [r1 r2 theta] at current time t
%           xm: x from t = t-1
%           xmm: x from t = t-2
%           s: constant length fraction

%% define constants
c = C.c; %compatability tolerance
dtheta = C.dtheta; %jump tolerance

%% get r
w = [s*sin(th);1-s*cos(th)];
r = M*w;

%% define constraints
%compatability
g1 = r(1);
g2 = r(1) - s*sin(th) + c;
%smoothness
g3 = abs(th-thm) - dtheta;

%% return constraints
G = [g1;g2;g3];
% G = [g1;g2];


%% debug


end
