function Fig = plot_whiskercomp(X,N,ANG,prot,error)
% *** WHISKER OUTPUT COMPARISON ***
% This function is a wrapper for plot_shadededcomp() to produce the output
% plot for N whiskers. It also optionally plots the sum error underneath.

    %% determine number of subplots
    if isnan(error)
        numplots = N;
    else
        numplots = N+1;
    end
    
    
    %% loop over N whiskers
    for w = 1:N
        %get curves
        Y1 = transpose(ANG(X,w));
        Y2 = transpose(prot(X,w));

        %plot
        subplot(numplots,1,N+1-w)
        comp_plot = plot_shadedcomp(X,Y1,Y2,N+1-w);
    end
    
    %% optional error plot
    if ~isnan(error)
        %plot
        subplot(numplots,1,numplots)
            err_plot = plot_error2(X,error,'-r');
    end
    
    % format plot
    xlabel('time frame');
    Fig = gcf;

end
