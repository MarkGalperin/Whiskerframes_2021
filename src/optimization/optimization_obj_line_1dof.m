function E = optimization_obj_line_1dof(th,M,s,bio_pts,bio_ang)
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
    E_per = zeros(1,N);
    
    for n = 1:N
        
        %project point to line
        y = bio_pts(2,n);
        
        %using M,y,w, get u
        u = (y*eye(2)-M)*w;
        
        %get protraction
        p = atan(u(2)/u(1));
        
        %Calculate error
        E_per(1,n) = abs(p-bio_ang(n));
        
        %debug
%         fprintf('y = %f, bio = %f, prot = %f, E = %f \n',y,bio_ang(n),p,E);
    end
    
    %% get mean error
    E = mean(E_per);
    
    
    %debug
%     fprintf('Error is %f \n \n',E)
    
end

