function plot_PMap(x_lim,y_lim)
% This function plots the "Protraction Map", a contour plot of all possible
% values of protraction relative to the unit parabola.
    
    %bounds
    x = linspace(x_lim(1),x_lim(2),500);
    y = linspace(y_lim(1),y_lim(2),500);

    %function
    [X,Y] = meshgrid(x,y);
    m1 = 2*X+2*sqrt(X.*X-Y);
    m2 = 2*X-2*sqrt(X.*X-Y);
    Z = pi/2 - (atan(m1)-atan(m2));

    %Filtering out complex numbers
    for m = 1:length(Z(1,:))
        for n = 1:length(Z(:,1))
            if isreal(Z(m,n)) == false
                Z(m,n) = NaN;
            end
        end
    end
    
    %% Plotting the contours...
    %protractionmap contours
    figure;
    contourf(X,Y,Z,50,'LineColor','none')
    colormap(spring)
    colorbar('AxisLocation','out')
    axis equal
    title('Optimal Frame positioning in {x''y''}')
    xlim(x_lim)
    ylim(y_lim)

end
