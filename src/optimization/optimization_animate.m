function complete = optimization_animate(traj,bio_points,bio_angles,error,s,mode,file)
    % *** ANIMATING THE OPTIMIZATION OUTPUT ***
    % This function takes the trajectory obtained by the optimization
    % program and animates both the whiskers and the frames
    %
    % Takes traj: (T x 4) time-trajectory of [r1 r2 theta s] solved for by
    %                     the optimizer.
    %       bio_whiskers: (TxN) time-trajectory for the angles processed at
    %                     the input.
    %       error
    %       file: (str)name of 
    
    %% Initialize
    %Initialize animation
    T = size(traj,1);
    N = size(bio_points,2);
    
    %initialize movie file
    path = append('../output/movies/optimization/',file);
    path = append(path,'.mp4'); %add .mp4
    v = VideoWriter(path);
    v.Quality = 50; %set lower quality to reduce filesize
    open(v);
    
    %% Animation loop
    annotate = false;
    for t = 1:T
        fprintf('animating frame %d / %d \n',t,T);
        %calculate stuff for the frames
        c = [-sin(traj(t,3)),cos(traj(t,3))];
        
        %get CF points
        CF1 = [traj(t,1),traj(t,2)];
        CF2 = CF1 + s*c;

        %clear the figure
        clf
        hold on
        
        %% plotting the frames
        plot([0,0],[0,1],'-k','LineWidth',4) %face frame
        plot([CF1(1),CF2(1)],[CF1(2),CF2(2)],'-k','LineWidth',2) %control frame
        
        %% debug info
        x_edge = [-(1/(tan(bio_angles(t,1))-tan(bio_angles(t,end)))) 1];
        
        %% plotting rods
        for n = 1:N
            %get corresponding pts
            pt = bio_points(1:2,n,t); 
            F = [0,pt(2)]; %might need to transpose?
            C = CF1 + c*s*pt(2);
            
            %protraction
            u = F-C;
            prot = atan(u(2)/u(1));
            
            %plot the rods
            plot([C(1),F(1)],[C(2),F(2)],'-g','LineWidth',1)
            
            %also plot whiskers?
        
        %% plotting bio whiskers
        
            %plotting little unit vectors for the output
            veclen = 0.25;
            plot([F(1), F(1)+veclen*cos(prot)],[F(2), F(2)+veclen*sin(prot)],'g','LineWidth',2)
        
            %plotting a little unit vector for bio pts
            angle = bio_angles(t,n);
            plot([F(1), F(1)+veclen*cos(angle)],[F(2), F(2)+veclen*sin(angle)],'m','LineWidth',2)
            
            %plot the point
            plot(F(1),F(2),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
        
         
        %% add debugging annotations
            if annotate
            ann = sprintf('angle = %f, prot = %f',angle,prot);
            text(pt(1)+0.25,pt(2),ann);
            end 
            
            %1 dof lines
            if strcmp(mode,'line_1dof')
                dof1_lines = true;
                if dof1_lines
                    if n == 1 || n == N
                        y_1dof0 = (tan(angle))*x_edge + F(2);
                        plot(x_edge,y_1dof0,'--m')
                    end
                end
            end
        end
        
        
        %% annotate error
        err = sprintf('mean error = %f rad',error(t));
        text(-0.25,-0.25,err)
        
        hold off

        %% format plot
        axis equal
        xlabel('x');
        ylabel('y');    
        axis([-2 1 -0.5 1.5])
        
        %% Add to animation
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    
    %close animation
    close(v);
    
    %% done
    complete = true;
end

