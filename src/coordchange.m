function traj2 = coordchange(traj,s,mode)
    % *** COORDINATE CHANGE ***
    % This function takes a trajectory and s to change (r1,r2,th)
    % coordinates into (p1,p2,th) coordinates or (m1,m2,th) coordinates. It
    % also allows to change back.
    %
    % Takes traj: (Tx3) trajectory
    %       s: length ratio (constant)
    %       mode: 'rp','pr','rm', or 'mr' to indicate a transformation from
    %       one system to another. For example, 'mr' is m -> r
    %       
    % 
    % Returns   traj2: trajectory with

    
    %% init output
    traj2 = zeros(size(traj));
    
    
    %% mode select
    switch mode
        %% mode 1: 
        case {'rp','pr'} 
            % trajectory loop
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

                % apply transformation
                if strcmp(mode,'rp')
                    v2 = transpose(Winv*v);
                elseif strcmp(mode,'pr')
                    v2 = transpose(W*v);
                end

                % construct new trajectory
                traj2(t,:) = [v2,th];
            end
            
        %% mode 2: r -> m or m -> r    
        case {'rm','mr'} % r -> m or m -> r
            for t = 1:size(traj,1)
                %get position (r or m, expressed as v) 
                v = transpose(traj(t,1:2));
                
                %get theta
                th = traj(t,3);

                % apply transformation
                if strcmp(mode,'rm')
                    v2(1) = v(1) - (s/2)*sin(th);
                    v2(2) = v(2) + (s/2)*cos(th);
                elseif strcmp(mode,'mr')
                    v2(1) = v(1) + (s/2)*sin(th);
                    v2(2) = v(2) - (s/2)*cos(th);
                end

                % construct new trajectory
                traj2(t,:) = [v2,th];
            end
    end
end

