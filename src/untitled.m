function Fig = trajectory_plot(traj);
    % *** ANIMATING THE OPTIMIZATION OUTPUT ***
    % This function takes the trajectory obtained by the optimization
    % program and animates both the whiskers and the frames
    %
    % Takes traj: (T x 4) time-trajectory of [r1 r2 theta s] solved for by
    %                     the optimizer.
    
    %% plot stuff
    %% Initialize
    %Initialize animation
    loops = size(traj,1);



