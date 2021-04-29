function Fig = trajectory_plot(traj,thbounds)
    % *** PLOTTING THE OPTIMIZATION OUTPUT ***
    % This function takes the trajectory obtained by the optimization
    % program and plots it
    %
    % Takes traj: (T x 4) time-trajectory of [r1 r2 theta s] solved for by
    %                     the optimizer.
    
    %% Initialize
    %Initialize animation
    loops = size(traj,1);
    clf
    hold on
    
    %% plotting the face frame
    plot([0,0],[0,1],'-k','LineWidth',4) %face frame
    
    %% initialize start point
    xm = [traj(1,1),traj(1,2)];
    x_start = xm;

    %% get color map
    colors = parula(100); %using the colormap "turbo"
        
    %% trajectory loop
    for ii = 1:loops
        %update points
        x = [traj(ii,1),traj(ii,2)];
        angle = traj(ii,3);
        %get color
        ci = round(100*(angle-thbounds(1))/(thbounds(2)-thbounds(1))); 
        if ci == 0, ci = 1; elseif ci > 100, ci = 100; end
        
        %% plotting the trajectory path 
        plot([xm(1),x(1)],[xm(2),x(2)],'color',colors(ci,:),'LineWidth',1) %trajectory path
        
        %% Update previous point
        xm = x;
    end
    
    %% plot start and end points
    %start pt
    plot(x_start(1),x_start(2),'o','MarkerEdgeColor','black','MarkerFaceColor','green') %start point
    %end pt
    plot(xm(1),xm(2),'o','MarkerEdgeColor','black','MarkerFaceColor','red') %start point
    
    %% format plot
    hold off
    axis equal
    axis([-1.75 0.25 -0.5 1.5])
    h = colorbar('AxisLocation','out');
    ylabel(h,'θ (rad)');
    %% save figure
    Fig = gcf;
    
end