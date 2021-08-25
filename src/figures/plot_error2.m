function Fig = plot_error2(X,error,linespec)
% *** Plotting error ***
% This function just plots the output of prot2error() easy peasy

    % sum and cut error
    err_sum = mean(error,2);
    err_cut = err_sum(X);
    err_plot = err_cut*(180/pi); %convert to degrees here
    
    % plot
    plot(X,err_plot,linespec)

    % format plot
    titlestr = sprintf('Total avg absolute error = %f degrees',mean(err_plot));
    title(titlestr)
    xlabel('time');
    ylabel('error (deg)');
    ylim([0,max(err_plot)*1.25]);

        
    %% return figure
    Fig = gcf;
        
end

