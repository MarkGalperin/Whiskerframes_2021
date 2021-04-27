function complete = preprocess_dlc_animate(base1,tip1,base2,tip2,other,file)
% *** ANIMATE DEEPLABCUT DATA ***
    % This function just goes and animates the deeplabcut data I have. I need to  
    %
    % Takes base:
    %       tip1:
    % 
    % Returns   
    %           
    %
    %% Initialize time points
    N = size(base1,2); %number of whiskers
    T = size(base1,3); %number of time frames
    
    %initialize movie file
    path = append('../output/movies/preprocess/',file);
    path = append(path,'.avi'); %add .avi
    v = VideoWriter(path);
    open(v);
    
    %average values for base whisker 1
    xavg = mean(base1(1,1,:));
    yavg = mean(base1(2,1,:));
    xavg2 = mean(base2(1,1,:));
    yavg2 = mean(base2(2,1,:));
    
    %% initialize plot parameters
    x_lim1 = [xavg-100 xavg+300];
    y_lim1 = [yavg-200 yavg+200];
    x_lim2 = [-1 1];
    y_lim2 = [-0.5 1.5];
%     x_lim2 = [xavg2-100 xavg2+300];
%     y_lim2 = [yavg2-200 yavg2+200];
    x_ls1 = linspace(x_lim1(1),x_lim1(2));
    y_ls1 = linspace(y_lim1(1),y_lim1(2));
    x_ls2 = linspace(x_lim2(1),x_lim2(2));
    y_ls2 = linspace(y_lim2(1),y_lim2(2));
    
    %extra subplots
    c = 0; %number of extra subplots
    if isfield(other,'SP3')
        c = 1;
    end
    if isfield(other,'SP4')
        c = 2;
    end
    
    %% Animation loop
    for ii = 1:T
        %index the pack EDIT IF USING OTHER SIZES OF DATASET
        x_base = base1(1,:,ii);
        y_base = base1(2,:,ii);
        x_tip = tip1(1,:,ii);
        y_tip = tip1(2,:,ii);
        x_base2 = base2(1,:,ii);
        y_base2 = base2(2,:,ii);
        x_tip2 = tip2(1,:,ii);
        y_tip2 = tip2(2,:,ii);
        
        %print status
        fprintf('animating frame %d / %d \n',ii,T);

        %clear the figure
        clf
        
        %% subplot 1
        subplot(1,2+c,1)
        hold on
        for jj=1:N
            %plot base
            plot(x_base(jj),y_base(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
            %plot tip
            plot(x_tip(jj),y_tip(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','green');
        end
        %% OTHER plots
        %best-fit line for sfk
        if isfield(other,'B')
            Y_ls = ones(length(y_ls1),2);
            Y_ls(:,2) = transpose(y_ls1);
            Xfit = Y_ls*other.B(:,ii);
            plot(Xfit,y_ls1,'--b'); 
        %offset angle line for MSE
        elseif isfield(other,'off')
            %plot line
            Y = (x_ls1-x_base(1))*tan(other.off) + y_base(1);
            plot(x_ls1,Y,'r');
        end
        
        % format plot
        title('Raw video data with ','constant angular offset line')
        axis equal
        axis([x_lim1, y_lim1])
        hold off
        
        %% subplot 2
        subplot(1,2+c,2)
        hold on
        for jj=1:N
            %plot base
            plot(x_base2(jj),y_base2(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
            %plot tip
            plot(x_tip2(jj),y_tip2(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','green');
            
            %% plot OTHER stuff
            if isfield(other,'bestrot')
                p = other.bestrot(1:2,jj,ii);
                plot(p(1),p(2),'*','MarkerEdgeColor','black');
            end
            if isfield(other,'ang')
                %fetch stuff
                a = other.ang(ii,jj);
                m = tan(a);
                %plot line
                Yang = (x_ls2 - x_base2(jj))*m + y_base2(jj);
                plot(x_ls2,Yang,'--g');
                
                %plot vertical
                plot([0,0],y_lim2,'--k');    
            end
            if isfield(other,'ang_mse')
                %plot a red line between base and tip
                plot([x_base2(jj),x_tip2(jj)],[y_base2(jj),y_tip2(jj)],'r')
            end
            
            
        end
        % format plot
        title('Angles determined','Basepoints from mousemap')
        axis equal
        axis([x_lim2, y_lim2])
        hold off
        
        %% 3rd subplot
        if isfield(other,'SP3')
            subplot(1,2+c,3)
            hold on
            
            m = 0.25;
            
            for jj = 1:N
                %plot the projected points. here, just the y values of base2
                plot(zeros(size(y_base2(jj))),y_base2(jj),'*k');

                %plot whisker angles
                ang = other.ang_mse(ii,jj);
                plot([0,m*cos(ang)],[y_base2(jj), y_base2(jj)+m*sin(ang)],'g','LineWidth',2)
            end 
            % format plot
            title('Optimization input')
            axis equal
            axis([x_lim2, y_lim2])
            hold off
           
        end
        
        %% Add to animation
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    
    %close animation
    close(v);
    
    %% done
    complete = true;
    
end


% if jj == 1
% %plot base of "whisker 1", labeled in red
% plot(x_base(jj),y_base(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','red');
% else
% %plot base
% plot(x_base(jj),y_base(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
% end
% %plot tip
% plot(x_tip(jj),y_tip(jj),'o','MarkerEdgeColor','black','MarkerFaceColor','green');
