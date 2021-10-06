function complete = animate_filtered(S,file)
% *** ANIMATE FILTERED JANELIA DATA ***
% Just a quickie to animate filtered whisker data

    %% Open struct
    PTS3 = S.points;
    ANG3 = S.angles;
    
    %% Initialize time points
    N = size(ANG3,2); %number of whiskers
    T = size(PTS3,3); %number of time frames
    
    %initialize movie file
    path = append('../data/processed/janelia/animation/filtered/',file);
    path = append(path,'.avi'); %add .avi
    v = VideoWriter(path);
    open(v);
    
    
    %% initialize plot parameters
    x_lim = [-1 1];
    y_lim = [-0.5 1.5];

    %% other setup
    wlen = 40;
    
    %% Animation loop
    for t = 1:T
        
        %index the input pts
        x_base3 = PTS3(1,:,t);
        y_base = PTS3(2,:,t);
        
        %print status
        fprintf('animating frame %d / %d \n',t,T);

        %clear the figure
        clf
        
        %% SUBPLOT 3: optimization input
        hold on

        m = 0.25;

        for n = 1:N
            %plot whisker angles
            ang = ANG3(t,n);
            plot([0,m*cos(ang)],[y_base(n), y_base(n)+m*sin(ang)],'-m','LineWidth',2)

            %plot the projected points. here, just the y values of base2
            plot(zeros(size(y_base(n))),y_base(n),'s','MarkerEdgeColor','black','MarkerFaceColor','white');
        end 
        % format plot
        title('Optimization input')
        axis equal
        axis([x_lim, y_lim])
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


