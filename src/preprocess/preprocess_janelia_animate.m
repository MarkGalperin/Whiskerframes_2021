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
    ANG1 = S.msrangles;
    PTS1 = S.msrpoints;
    ANG2 = S.pp2angles;
    PTS2 = S.pp2points;
    PTS3 = S.points;
    ANG3 = S.angles;
    
    %% Initialize time points
    N = size(ANG1,2); %number of whiskers
    T = size(PTS1,3); %number of time frames
    
    %initialize movie file
    path = append('../data/processed/janelia/animation/',file);
    path = append(path,'.avi'); %add .avi
    v = VideoWriter(path);
    open(v);
    
    %average values for base whisker 
    xavg1 = mean(PTS1(1,1,:));
    yavg1 = mean(PTS1(2,1,:));
    xavg2 = mean(PTS2(1,1,:));
    yavg2 = mean(PTS2(2,1,:));
    
    %% initialize plot parameters
    x_lim1 = [xavg1-100 xavg1+300];
    y_lim1 = [yavg1-200 yavg1+200];
    x_lim2 = [xavg2-100 xavg2+300];
    y_lim2 = [yavg2-200 yavg2+200];
    x_lim3 = [-1 1];
    y_lim3 = [-0.5 1.5];

    %% other setup
    wlen = 40;
    
    
    %% Animation loop
    for t = 1:T
        
        %index the input pts
        x_base1 = PTS1(1,:,t);
        y_base1 = PTS1(2,:,t);
        x_base2 = PTS2(1,:,t);
        y_base2 = PTS2(2,:,t);
        x_base3 = PTS3(1,:,t);
        y_base3 = PTS3(2,:,t);
        
        %print status
        fprintf('animating frame %d / %d \n',t,T);

        %clear the figure
        clf
        
        %% subplot 1: Raw data (step 1)
        subplot(1,3,1)
            hold on
            for n=1:N
                %get tip coords
                x_tip = x_base1(n) + wlen*cosd(ANG1(t,n));
                y_tip = y_base1(n) + wlen*sind(ANG1(t,n));

                %plot whisker line
                plot([x_tip,x_base1(n)],[y_tip,y_base1(n)],'-m','LineWidth',2);
                
                %plot base
                plot(x_base1(n),y_base1(n),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
                %plot tip
%                 plot(x_tip,y_tip,'o','MarkerEdgeColor','black','MarkerFaceColor','green');
                
            end

            % format plot
            title('Raw video data points')
            axis equal
            xlabel('x')
            ylabel('y')
            axis([x_lim1, y_lim1])
            hold off
        
        %% subplot 2: Normalized (step 2)
        subplot(1,3,2)
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
            axis([x_lim2, y_lim2])
            hold off
        
        %% SUBPLOT 3: optimization input
        subplot(1,3,3)
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


