function output = ProtractionMap(x,y)
%returns local protraction for a point in parabola space
%   Detailed explanation goes here
    if (x*x-y >= 0)
        m1 = 2*x+2*sqrt(x*x-y);
        m2 = 2*x-2*sqrt(x*x-y);
        output = pi/2 - (atan(m1)-atan(m2));
    else
        output = NaN;
    end
end

