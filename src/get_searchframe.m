function [V2,P2,ang2,Fig] = get_searchframe(basepoints,angles,regtype,rowselect,plotarg)

    %% INPUT FRAME
    % adjust for differences in input size
    % if the size(basepoints,2) is more than the size of size(angles,2),
    % then delete the excess points. ALSO, if any angles are NaN, meaning
    % they should be omitted, their corresponding basepoint info is omitted
    % first, deal with NaN values...
    nans = isnan(angles);
    if any(nans)
        %delete out the entries from each set. This effectively removes any
        %whiskers whose index was marked by the NaN in the angles.
        angles = angles(~nans);
        basepoints = basepoints(:,~nans);
    end
    %now, deal with size difference
    if size(basepoints,2) > size(angles,2)
        N = size(angles,2);
        basepoints = basepoints(:,1:N);
    end
    
    %input points (result should be column vectors in homogenous coordinates 
    %               with a 4th row indicating the associated whisker angle)
    V = basepoints;
    
    %length for plotted frame axes
    axislength = 0.5;
    axisX = [axislength 0];
    axisY = [0,axislength];
    
    
    %% Finding a least-squares best fit for the points... (TODO - try in terms of Y?)
%     X = ones(size(V,2),2);
%     X(:,2) = transpose(V(1,:));
%     Y = transpose(V(2,:));
%     B = X\Y;
    if strcmp(regtype,'SSR')
        Y = ones(size(V,2),2);
        Y(:,2) = transpose(V(2,:));
        X = transpose(V(1,:));
        B = Y\X;
    end
    %% Other Regressions
    if strcmp(regtype,'deming')
        poop=0;
        B = deming(transpose(V(2,:)),transpose(V(1,:)));
    end
    
    %% Projecting points onto the line...
    % project each point in V_pro to the line vector u and store
    % those points in the matrix P...
%     u = [1 ; B(2)];
    u = [B(2) ; 1];
    P = ones(size(V));

    for ii = 1:size(V,2) 
%         %calculate projection
%         pt = [V(1,ii);V(2,ii)-B(1)];
%         pt_proj = (dot(pt,u)/dot(u,u))*u;
%         pt_proj(2) = pt_proj(2)+ B(1);
%         %store points...
%         P(1:2,ii) = pt_proj;
        pt = [V(1,ii)-B(1);V(2,ii)];
        pt_proj = (dot(pt,u)/dot(u,u))*u;
        pt_proj(1) = pt_proj(1)+ B(1);
        %store points...
        P(1:2,ii) = pt_proj;
    end

    %% Calculate d = distance betweeen furthest points...
    [~,Imax] = max(P(2,:));
    [~,Imin] = min(P(2,:));
    Pmax = P(:,Imax);
    Pmin = P(:,Imin);
    d = norm(Pmax-Pmin);
    %D and D_inv are transforms that scale by d...
    D = [d 0 0 ; 0 d 0 ; 0 0 1];
    D_inv = [1/d 0 0 ; 0 1/d 0 ; 0 0 1];
    

    %% Transform Pmin to be the new origin
    %set Pmin as the origin 
    O_in = Pmin;

    %Frame parameter and transform...
%     slope_ang = pi/2 - atan(B(2));
    slope_ang = atan(B(2));
    TO_i = get_SE2(-slope_ang,Pmin);
    TO = get_SE2(slope_ang,0)*get_SE2(0,-Pmin);

    %% Transformed V
    V2 = TO*V;
    %scale V2 by D_inv...
    V2 = D_inv*V2;
    %% Transformed P 
    P2 = TO*P;
    %scale P2 by D_inv...
    P2 = D_inv*P2;
    
    %% Transformed Angles...
    ang2 = angles + slope_ang;
    
    
    %% PLOTS
    if plotarg == true
            %SUBPLOT 1: Input space (arbitrary frame)
            subplot(1,2,1)
            title('Input Frame')
            hold on
            
            %plot limits and linspace
            x_lim = [min(V(1,:))-3, max(V(1,:))+3];
            y_lim = [min(V(2,:))-3, max(V(2,:))+3];
            x_ls = linspace(x_lim(1),x_lim(2));
            y_ls = linspace(y_lim(1),y_lim(2));

            %plot the origin axes
            plot(axisX,[0 0],'b','MarkerEdgeColor','red','LineWidth',2)
            plot([0 0],axisY,'b','MarkerEdgeColor','red','LineWidth',2)
            
            % Subplot 1 = input base points with colors and unit vectors
            for ii = 1:size(V,2)
                %plotting little unit vectors to show angle
%                 fprintf("ii = %d, x = %f, y = %f, angle = %f \n",ii,V(1,ii),V(2,ii),angles(ii));
                plot([V(1,ii), V(1,ii)+cos(angles(ii))],[V(2,ii), V(2,ii)+sin(angles(ii))],'r','LineWidth',1)
                
                %red =   (0.5) + (angles(ii)/pi); % value in [0,1] describing red or green
                %green = (0.5) - (angles(ii)/pi);
                red =   cos(pi/4 + angles(ii)/2); 
                green = sin(pi/4 + angles(ii)/2);
                %overflow check
                if red > 1
                    red = 0.99;
                elseif red < 0
                    red = 0;
                end
                if green > 1
                    green = 0.99;
                elseif green < 0
                    green = 0;
                end
                plot(V(1,ii),V(2,ii),'o','MarkerEdgeColor','black','MarkerFaceColor',[red green 0]);
            end
            
            %Subplot 1 - Best fit line
%             X_ls = ones(length(x_ls),2);
%             X_ls(:,2) = transpose(x_ls);
%             Yfit = X_ls*B;
%             plot(x_ls,Yfit,'--');
            Y_ls = ones(length(y_ls),2);
            Y_ls(:,2) = transpose(y_ls);
            Xfit = Y_ls*B;
            plot(Xfit,y_ls,'--');            

            %Subplot 1 - Projected points
            for ii = 1:size(P,2) 
                %plot...
                plot(P(1,ii),P(2,ii),'*','MarkerEdgeColor','black');
            end
            
            %Subplot 1 - Pre-transform Origin @ Pmin
            O_axisX = TO_i*transpose([axisX 1]);
            O_axisY = TO_i*transpose([axisY 1]);
            plot([O_in(1),O_axisX(1)],[O_in(2),O_axisX(2)],'r','LineWidth',2)
            plot([O_in(1),O_axisY(1)],[O_in(2),O_axisY(2)],'r','LineWidth',2)
            
            %Subplot 1 - Axis Limits
            axis equal
            axis square
            xlim(x_lim)
            ylim(y_lim)
        
        subplot(1,2,2)
        title('Search Frame')
        
            %Subplot2 - origin axes
            hold on
            plot([0.1 0],[0 0],'r','LineWidth',2)
            plot([0 0],[0 0.1],'r','LineWidth',2)
        
            %Subplot 2 - V2
            for ii = 1:size(V2,2)
                hold on
                %plot(V2(1,ii),V2(2,ii),'o','MarkerEdgeColor','black','MarkerFaceColor',[0.5 0.5 0.5]);
            
                %plotting little unit vectors to show angle
                plot([V2(1,ii), V2(1,ii)+(0.25)*cos(ang2(ii))],...
                    [V2(2,ii), V2(2,ii)+(0.25)*sin(ang2(ii))],'r','LineWidth',1)
                %Plotting the points with colors as angles
                red =   cos(pi/4 + ang2(ii)/2); 
                green = sin(pi/4 + ang2(ii)/2);
                plot(V2(1,ii),V2(2,ii),'o','MarkerEdgeColor','black','MarkerFaceColor',[red green 0]);
            
            end
            
            
            %Subplot 2 - P2
            for ii = 1:size(P2,2)
                hold on
                plot(P2(1,ii),P2(2,ii),'*','MarkerEdgeColor','black');
            end
    
            %Subplot2 - origin axes
            hold on
%             plot(axisX,[0 0],'r','LineWidth',2)
%             plot([0 0],axisY,'r','LineWidth',2)
            
            %Subplot 2 - Axis Limits
%             x_lim2 = [min(V2(1,:))-3, max(V2(1,:))+3];
%             y_lim2 = [min(V2(2,:))-3, max(V2(2,:))+3];
            x_lim2 = [min(V2(1,:))-1, max(V2(1,:))+1];
            y_lim2 = [-0.5,1.5];
            axis equal
            xlim(x_lim2)
            ylim(y_lim2)
            
            %Subplot 2 - fit line (vertical)
            plot([0 0],y_lim2,'b--')
            
            %hold off
            hold off;
            debug = 'here';
            
    %figure title
    ttl = sprintf('Input processing for row %c',rowselect);
    sgtitle(ttl)
    
    %save figure
    Fig = gcf;
    else
        Fig = 0;
    end %IN CASE SOMETHING BROKE, I MOVED THIS ON 3/16 FROM 194 TO HERE
    
end
