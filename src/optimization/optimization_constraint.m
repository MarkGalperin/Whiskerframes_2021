function C_check = optimization_constraint(x,xm,xmm,s,C)
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
%check for NaN
if any(isnan(xmm))
    %compatability
    g1 = x(1) + c; %bottom edge away from face frame
    g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
    %smoothness (configuration)
    g3 = (x(1)-xm(1))^2 + (x(2)-xm(2))^2 - R^2; %r within a radius R
    g4 = abs(x(3)-xm(3)) - dtheta; %th within a delta th
    g5 = -1; %exempted
elseif any(isnan(xm))
    %compatability
    g1 = x(1) + c; %bottom edge away from face frame
    g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
    %smoothness (configuration)
    g3 = -1; %exempted
    g4 = -1; %exempted
    g5 = -1; %exempted
else
    %compatability
    g1 = x(1) + c; %bottom edge away from face frame
    g2 = x(1) - s*sin(x(3)) + c; %top edge away from face frame
    %smoothness (configuration)
    g3 = (x(1)-xm(1))^2 + (x(2)-xm(2))^2 - R^2; %r within a radius R
    g4 = abs(x(3)-xm(3)) - dtheta; %th within a delta th
    g5 = -((x(1)-xm(1))*(xm(1)-xmm(1)))-((x(2)-xm(2))*(xm(2)-xmm(2))); %might discard this one
end




%% return constraint check
% C = [g1;g2;g3;g4];
C_check = [g1;g2;g3;g4;g5];

end
