function [E,info] = optimization_obj_line_1dof(th,M,s,bio_pts,bio_ang,Cstruct)
    %OBJECTIVE FUNCTION - Mean whisker error as a function of config.
    %   This function returns the cost for a certain configuration of design
    %   variables 
    %   TAKES:  x: [r1 r2 theta] at current time t
    %           s: fixed length ratio
    %           bio_pts: (1xN) vector of biological y-points 
    %           bio_ang: (1xN) vector of biological output angles
    
    %% define w
    w = [s*sin(th);1-s*cos(th)];
    
    %% For all pts, calculate error
    N = size(bio_pts,2);
    Errs = zeros(1,N);
    Prot = zeros(1,N);
    Dang = zeros(1,N);
    
    for n = 1:N
        
        %project point to line
        y = bio_pts(2,n);
        
        %using M,y,w, get u
        u = (y*eye(2)-M)*w;
        
        %get protraction
        P = atan(u(2)/u(1));
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
        
        %debug
%         fprintf('y = %f, bio = %f, prot = %f, E = %f \n',y,bio_ang(n),p,E);
    end
    
    %% return mean error
    E = mean(Errs);
    
    %% return info
    if Cstruct.objinfo
        info = [Prot ; bio_ang ; Dang ; Errs];
    else
        info = NaN(4,N);
    end
    
    
    %debug
%     fprintf('Error is %f \n \n',E)
    
end

