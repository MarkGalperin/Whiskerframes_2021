function Fig = plot_trajcomp(X,traj,err)
% *** TRAJECTORY COMPARISON PLOT ***
% Summary of this function goes here
%   Detailed explanation goes here

    %% Plot trajectory
    hold on
    for cf = 1:3
        %get each trajectory curve
        tj = transpose(traj(:,cf));
        
        %cut down
        tj = tj(X);

        %plot
        width = 1;
        plot(X,tj,'LineWidth',width)

    end
    
    %% plot error
    plot(X,err(X),'r','LineWidth',2);
    
    
    %% format plot
    ylabel('r1,r2,θ');
    
    hold off
    
    %% return figure
    Fig = gcf;
end
