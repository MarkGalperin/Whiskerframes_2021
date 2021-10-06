function [E,info] = optimization_obj_line(x,s,bio_pts,bio_ang,Cstruct)
    %OBJECTIVE FUNCTION - Mean whisker error as a function of config.
    %   This function returns the cost for a certain configuration of design
    %   variables 
    %   TAKES:  x: [r1 r2 theta] at current time t
    %           s: fixed length ratio
    %           bio_pts: (1xN) vector of biological y-points 
    %           bio_ang: (1xN) vector of biological output angles
    %           mode: either "abs" or "squared" - for absolute value error
    %           or squared error
    
    %% For all pts, calculate error
    N = size(bio_pts,2);
    Errs = zeros(1,N);
    Prot = zeros(1,N);
    Dang = zeros(1,N);
    
    for n = 1:N
        
        %project point to line
        y = bio_pts(2,n);
        
        %get corresponding pts
        F = [0,y];
        c = [-sin(x(3)),cos(x(3))];
        C = [x(1),x(2)] + c*s*y; %note: "C" is not the struct here. Its a vector.
        
        %protraction
        u = F-C;
        P = atan(u(2)/u(1)) + Cstruct.bias(n); %NEW: add bias term
        Prot(n) = P;
        
        %Calculate error
        d_ang = P-bio_ang(n);
        Dang(n) = d_ang;
        switch Cstruct.errmode
            case 'abs'
                Errs(n) = abs(d_ang);
            case 'squared'
                Errs(n) = (d_ang)^2;
            case '4'
                Errs(n) = (d_ang)^4;
        end
    end
    %% return mean error E
    E = mean(Errs);
    
    %% return info
    if Cstruct.objinfo
        info = [Prot ; bio_ang ; Dang ; Errs];
    else
        info = NaN(4,N);
    end
    
end

