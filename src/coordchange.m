function traj2 = coordchange(traj,s,mode)
    % *** COORDINATE CHANGE ***
    % This function takes a trajectory and s to change (r1,r2,th)
    % coordinates into (p1,p2,th) coordinates, as defined in the coordinate
    % change section 3.
    %
    % Takes traj: (Tx3) trajectory
    %       s: length ratio (constant)
    %       mode: 'rp' or 'pr' to indicate a transformation from r to p or
    %       p to r, respectively
    % 
    % Returns   traj2: trajectory with

    
    %% init output
    traj2 = zeros(size(traj));
    %% trajectory loop
    for t = 1:size(traj,1)
        %get position (r or p, expressed as v)
        v = transpose(traj(t,1:2));
        %get theta
        th = traj(t,3);
        % get w vector
        w = [s*sin(th),1-s*cos(th)];
        % define W matrix and inverse
        W = [w(2),w(1);-w(1),w(2)];
        Winv = inv(W);
        
        %% apply transformation
        if strcmp(mode,'rp')
            v2 = transpose(Winv*v);
        elseif strcmp(mode,'pr')
            v2 = transpose(W*v);
        end
        
        %% construct new trajectory
        traj2(t,:) = [v2,th];
        
    end
    
end

