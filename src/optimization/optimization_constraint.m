function [C,Ceq] = optimization_constraint(x,xm,xmm,s,C)
%CONSTRAINT FUNCTION
%   This function returns the cost for a certain configuration of design
%   variables 
%   TAKES:  x: [r1 r2 theta] at current time t
%           xm: x from t = t-1
%           xmm: x from t = t-2
%           s: constant length fraction

%% define constants
c = C.c; %compatability tolerance
R = C.R; %jump tolerance
dtheta = C.dtheta;

%% define constraints
%compatability
g1 = x(1);
g2 = x(1) - s*sin(x(3)) + c;

%smoothness
g3 = (x(1)-xm(1))^2 + (x(2)-xm(2))^2 - R^2;
g4 = abs(x(3)-xm(3)) - dtheta;
g5 = -((x(1)-xm(1))*(xm(1)-xmm(1)))-((x(2)-xm(2))*(xm(2)-xmm(2))); %might discard this one

%% return constraints
% C = [g1;g2;g3;g4];
C = [g1;g2;g3;g4;g5];
Ceq = [];

end
