function Fig = error_plot(E_log)
    % *** PLOTTING A SHADED TRAJECTORY ***
    % SDFSDF
    %
    % Takes Input1: DFKJSDFSD
    % 
    % Returns   FDSFF
    
    %% Initialize
    loops = length(E_log);
    clf
    hold on
    
    %% Get mean error
    E_mean = mean(E_log);
    meantitle = sprintf('Error with Respect to time. Mean error = %f',E_mean);
    
    %% plotting the error
    x = 1:loops;
    plot(x,E_log) %error curve

    %% format plot
    hold off
    title(meantitle)
    xlabel('time step')
    ylabel('Error (rad)')

    %% save figure
    Fig = gcf;
    
end
