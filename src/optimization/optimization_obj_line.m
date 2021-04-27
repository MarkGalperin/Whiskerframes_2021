function E = opterror(x,s,bio_pts,bio_ang)
    %OBJECTIVE FUNCTION - Mean whisker error as a function of config.
    %   This function returns the cost for a certain configuration of design
    %   variables 
    %   TAKES:  x: [r1 r2 theta] at current time t
    %           s: fixed length ratio
    %           bio_pts: (1xN) vector of biological y-points 
    %           bio_ang: (1xN) vector of biological output angles
    
    %% For all pts, calculate error
    E = 0;
    N = size(bio_pts,2);
    for n = 1:N
        
        %project point to line
        y = bio_pts(2,n);
        
        %get corresponding pts
        F = [0,y];
        c = [-sin(x(3)),cos(x(3))];
        C = [x(1),x(2)] + c*s*y;
        
        %protraction
        u = F-C;
        p = atan(u(2)/u(1));
        
        %Calculate error
        E = E + (1/N)*abs(p-bio_ang(n));
        
        %debug
        %fprintf('y = %f, bio = %f, prot = %f, E = %f \n',y,bio_ang(ii),P,E);
    end
end

