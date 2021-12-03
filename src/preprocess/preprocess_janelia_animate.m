function complete = preprocess_janelia_animate(S,other,file)
% *** ANIMATE JANELIA DATA ***
    % This function animates the pre-processed data
    %
    % Takes base:
    %       tip1:
    % 
    % Returns   
    %           
    %
    %% Open struct
    ANG = S.msrangles;
    PTS = S.msrpoints;
    ANG2 = S.pp2angles;
    PTS2 = S.pp2points;
    PTS3 = S.points;
    ANG3 = S.angles;
    WID = S.wid;
    WSK = S.WSK;
    
    %% Initialize time points
    N = size(ANG,2); %number of whiskers
    T = size(PTS,3); %number of time frames
    
    %initialize movie file
    path = append('../data/processed/janelia/animation/',file);
    path = append(path,'.avi'); %add .avi
    v = VideoWriter(path);
    open(v);
    
    %average values for base whisker 
    xavg2 = mean(PTS2(1,1,:));
    yavg2 = mean(PTS2(2,1,:));
    
    %% initialize plot parameters
    x_lim2 = [xavg2-100 xavg2+300];
    y_lim2 = [yavg2-200 yavg2+200];
    x_lim3 = [-1 1];
    y_lim3 = [-0.5 1.5];

    %% other setup
    wlen = 40;
    

    %% Animation loop
    for t = 1:T
        
        %index the input pts
        x_base2 = PTS2(1,:,t);
        y_base2 = PTS2(2,:,t);
        x_base3 = PTS3(1,:,t);
        y_base3 = PTS3(2,:,t);
        
        %print status
        fprintf('animating frame %d / %d \n',t,T);

        %clear the figure
        clf
        
        %% initialize layout
        ha = tight_subplot(1,3,[.06 .06],[.1 .2],[.07 .07]);
        hold on
        
        %% subplot 1: Raw data (step 1)
        axes(ha(1))
            hold on
            %format plot
            xlim([0 640]);
            ylim([-480 0]);
            %overlay video file
            if S.whiskvid{1}
                %get vid file
                vid = S.whiskvid{2};
                %get the current video image and plot with imshow
                I =read(vid,t);
                %flip image over y axis
                I = flip(I,1);

                %plot image
                image(0,-480,I);
            end

            %plot whiskers
            for n = 1:N
                %plot whisker
                wid = WID(t,n)+1;
                if ~isnan(wid)
                    wpts = WSK.WSK_points{t,wid};
                    plot(wpts(1,:),-wpts(2,:),'LineWidth',2);
                end
                %plot point
                plot(PTS(1,n,t),-PTS(2,n,t), 'ok','MarkerFaceColor','w');
                
                %plot labels
                if isfield(S,'labels') && S.labels
                    %plot a numbered label
                    textstr = sprintf('(%d)',n);
                    text(PTS(1,n,t),...
                        -PTS(2,n,t)-20,...
                        textstr,...
                        'Color','white');
                end
            end

            axis equal
            axis tight
            ha(3).PositionConstraint = 'outerposition';

            %plot time
            timestr = sprintf('t = %4d/%d',t,T);
            text(500,...
                -30,...
                timestr,...
                'Color','black',...
                'BackgroundColor', 'white');
  
            % format plot
            title('Raw video data points')
            xlabel('x')
            ylabel('y')
            
            hold off
        
        %% subplot 2: Normalized (step 2)
        axes(ha(2))
            hold on
            for n=1:N
                
                %get tip coords
                x_tip = x_base2(n) + wlen*cos(ANG2(t,n));
                y_tip = y_base2(n) + wlen*sin(ANG2(t,n));

                %plot whisker line
                plot([x_tip,x_base2(n)],[y_tip,y_base2(n)],'-m','LineWidth',2);
                
                %plot base
                if n == 1
                    plot(x_base2(n),y_base2(n),'o','MarkerEdgeColor','black','MarkerFaceColor','red');
                    if isfield(other,'off_angle') %plot the constant offset line from the first point
                        m = tan(other.off_angle);
                        Y = m*(x_lim2-x_base2(n))+y_base2(n);
                        plot(x_lim2,Y,'-r')
                    end
                else
                    plot(x_base2(n),y_base2(n),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
                end
                
                %plot tip
%                 plot(x_tip,y_tip,'o','MarkerEdgeColor','black','MarkerFaceColor','green');
            end
            

            % format plot
            subtitl = sprintf('constant angular offset at %d degrees',other.off_angle*(180/pi));
            title('Data normalized to FF segment',subtitl)
            axis equal
            xlabel('x')
            ylabel('-y')
%             axis([x_lim2, y_lim2])
            hold off
        
        %% SUBPLOT 3: optimization input
        axes(ha(3))
            hold on
            
            m = 0.25;
            
            for n = 1:N
                %plot whisker angles
                ang = ANG3(t,n);
                plot([0,m*cos(ang)],[y_base3(n), y_base3(n)+m*sin(ang)],'-m','LineWidth',2)
                
                %plot the projected points. here, just the y values of base2
                plot(zeros(size(y_base3(n))),y_base3(n),'s','MarkerEdgeColor','black','MarkerFaceColor','white');
            end 
            % format plot
            title('Optimization input')
            axis equal
            axis([x_lim3, y_lim3])
            hold off
           

            
            
            
        %% Add to animation
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    
    %close animation
    close(v);
    
    %% done
    complete = true;
    
end


