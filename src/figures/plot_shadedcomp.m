function Fig = plot_shadedcomp(X,Y1,Y2,w)
% *** SHADED COMPARISON PLOT ***
% Summary of this function goes here
%   Detailed explanation goes here


    %% get transition booleans
    dif = Y2>Y1;
    sz = size(dif,2);
    ON = strfind(dif,[0,1])+1;
    OFF = strfind(dif,[1,0])+1;

    %% make bounds arrays depending on case
    if dif(1) 
        if dif(end) %B
            Xb1 = transpose([1 ON;OFF sz]);
            Xb0 = transpose([OFF;ON]);
        else %A
            Xb1 = transpose([1 ON;OFF]);
            Xb0 = transpose([OFF;ON sz]);
        end
    else 
        if dif(end) %C
            Xb1 = transpose([1 OFF ; ON]);
            Xb0 = transpose([ON ; OFF sz]);
        else %D
            Xb1 = transpose([1,OFF;ON, sz]);
            Xb0 = transpose([ON;OFF]);
        end
    end
    
    %% Plot
    hold on
    
    %2 loops for each fill
    for ii = 1:size(Xb0,1)
        %get polygon data
        rng = Xb0(ii,1):Xb0(ii,2);
        X2 = [X(rng), X(fliplr(rng))];
        inBetween = [Y1(rng), fliplr(Y2(rng))];

        %plot
        fill(X2, inBetween,'g','LineStyle','none','FaceAlpha',0.5);
    end
    for ii = 1:size(Xb1,1)
        %get polygon data
        rng = Xb1(ii,1):Xb1(ii,2);
        X2 = [X(rng), X(fliplr(rng))];
        inBetween = [Y1(rng), fliplr(Y2(rng))];

        %plot
        fill(X2, inBetween,'r','LineStyle','none','FaceAlpha',0.25);
    end
    
    %get two curves
    width = 1;
    plot(X,Y1,'m','LineWidth',width)
    plot(X,Y2,'g','LineWidth',width)
    
    %% format plot
    ystr = sprintf('θ%d',w);
    ylabel(ystr);
    hold off
    
%     ylim([-pi/2,pi/2])
    
    %% return figure
    Fig = gcf;
end
