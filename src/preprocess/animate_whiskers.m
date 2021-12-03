function complete = animate_whiskers(S,WSK,path)
% *** ANIMATE JANELIA WHISKERS! ***
% Animating whisker data

    %% Open structs
    PTS = S.PTS;
    ANG = S.ANG;
    WID = S.WID;
    WSK_points = WSK.WSK_points;
    whiskvid = S.whiskvid;
    
    %number of sub-plots?
    if isfield(S,'plotANG')
        Nplots = 1+sum(S.plotANG);
    else
        Nplots = 1;
    end
    nplot = 0; %this counts up
    
    %% open video
    vid = whiskvid{2};
    
    %% Initialize 
    N = size(ANG,2); %number of whiskers
    T = size(PTS,3); %number of time frames
    
    %initialize movie file
    v = VideoWriter(path,'MPEG-4');
    v.Quality = 75; %set compression level
    open(v);
    
    %init figure size if needed
    if isfield(S,'plotANG') && sum(S.plotANG) == 1
        figure('Renderer', 'painters', 'Position', [10 10 450 450])
    elseif isfield(S,'plotANG') && sum(S.plotANG) == 2
        figure('Renderer', 'painters', 'Position', [10 10 600 800])
    end
    
    
    %% Animation loop
    for t = 1:T
        %print status
        fprintf('animating frame %d / %d \n',t,T);

        %clear the figure
        clf
        
        %% initialize layout
        ha = tight_subplot(3,1,[.06 .03],[.1 .01],[.07 .05]);
        hold on
        
        %% SUBPLOT 1: static ANG plot with moving wiper
        if isfield(S,'plotANG') && S.plotANG(1)
            axes(ha(1))
            hold on
            plot(ANG)
            xline(t,'-r','LineWidth',1)
            %set aspect ratio
            pbaspect([6,1,1]);
        end
       
        %% SUBPLOT 2: Moving window on ANG
        if isfield(S,'plotANG') && S.plotANG(2)
            axes(ha(2))
            hold on
            %set window
            win = 25;
            if ismember(t,1:win)
                t1 = 1;
                t2 = 2*win;
            elseif ismember(t,(win+1):(T-win))
                t1 = t-win;
                t2 = t+win;
            elseif ismember(t,(T-win+1):T)
                t1 = T-2*win;
                t2 = T;
            end
            
            %plot
            plot(ANG)
            xlim([t1,t2]);
            xline(t,'-r','LineWidth',2)
            
            %set aspect ratio
            pbaspect([6,1,1]);
        end
      
        %% Whisker video plot
        axes(ha(3))
            hold on
            %format plot
            x_lim = [0 640];
            y_lim = [-480 0];
            xlim(x_lim);
            ylim(y_lim);
            %overlay video file
            if whiskvid{1}
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
                    wpts = WSK_points{t,wid};
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
            
            hold off
        
        %% rearrange plot positions to equal width (NEEDS OPTIONS FOR DIFFERENT NPLOT)
        getpos1 = get(ha(1),'Position');
        getpos2 = get(ha(2),'Position');
        getpos3 = get(ha(3),'Position');

        %set values
        set(ha(2),'Position',[getpos2(1),0.57,getpos2(3:4)])
        set(ha(3),'Position',[getpos3(1),-0.17,getpos3(3),1])
       
        %% Add to animation
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    
    %close animation
    close(v);
    
    %% done
    complete = true;
    
end


