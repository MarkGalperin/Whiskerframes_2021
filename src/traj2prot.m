function protraction = traj2prot(traj,s,y_in)
    % *** TRAJ2PROT ***
    % Trajectory to protraction: takes trajectory data and returns
    % protraction (output) of the whisker frames system.
    %
    % Takes traj: [Tx3] time trajectory for r1, r2, theta
    %       s: whisker frames length ratio
    %       y: [1xN] y positions of the whiskers
    % 
    % Returns protraction: [TxN] array of 
    
    %init
    T = size(traj,1);
    N = length(y_in);
    protraction = zeros(T,N);
    
    %loop over trajectory
    for t = 1:T
        for n = 1:N

            %project point to line
            y = y_in(n);

            %get corresponding pts
            F = [0,y];
            c = [-sin(traj(t,3)),cos(traj(t,3))];
            C = [traj(t,1),traj(t,2)] + c*s*y;

            %protraction
            u = F-C;
            p = atan(u(2)/u(1));
            
            %save
            protraction(t,n) = p;

        end
    end
    
end

