function output = idealProtraction(r1,r2,th,s,y)
%returns local protraction for a point in parabola space
%   Detailed explanation goes here
    %w values...
    w1 = s*sin(th);
    w2 = 1-s*cos(th);
    %protraction...
    output = atan((w2*y-r2)/(w1*y-r1));
end
