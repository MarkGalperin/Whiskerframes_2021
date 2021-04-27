function Fig = plot_xy(s,r,theta,numwhiskers)
% This function plots the optimized frame configuration in {xy} with face frame length = 1, having
% solved for the ideal configuration in {x'y'}
% Takes...
% 
%   s: fixed frame length ratio
%   r: 2-vector decribing the position of the control frame
%   theta: angle [radians] of the control frame
%   numwhiskers: the number of plotted whiskers
    
    %% Plot parameters
    %axes
    x_lim = [3*r(1)/2,-r(1)/2]; 
    ax_width = abs(x_lim(2)-x_lim(1));
    y_lim = [0.5-ax_width/2,0.5+ax_width/2];

    %% Control frame points...
    %the first control frame point is just the r vector
    CF1 = r;
    
    %the second control frame point is a function of s and theta, 
    % added to CF1;
    c = [-sin(theta),cos(theta)];
    CF2 = CF1 + s*c;
    
    %% whisker lines setup
    %w vector
    w = [s*sin(theta),1-s*cos(theta)];
    
    %linspace
    x_ls = linspace(x_lim(1),x_lim(2));
%     y_ls = linspace(y_lim(1),y_lim(2));
    
    %% Plotting
    % initialize figure
    figure()
    title('Whisker Frames in {xy}')
    hold on
    
    %plotting whiskers
    for ii = 0:1/numwhiskers:1
        %u vector and slope m
        u = w*ii - r;
        m = u(2)/u(1);
        
        %calculating and plotting the line 
        Y_whisk = m*x_ls+ii;
        plot(x_ls,Y_whisk,'-g','LineWidth',1)
    end
    
    %plotting frames
    plot([0,0],[0,1],'-k','LineWidth',4)
    plot([CF1(1),CF2(1)],[CF1(2),CF2(2)],'-k','LineWidth',2)
    
    %axis
    axis equal
    xlim(x_lim)
    ylim(y_lim)
    
    %save figure
    Fig = gcf;
    
end
  