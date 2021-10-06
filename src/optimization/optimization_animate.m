function complete = optimization_animate(TRIAL)
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
    %NEW: support for batch-trial files
    trialselect = 1; %can be 1 or 2, depending on 1st or 2nd optimization
    if isfield(TRIAL,'TRIAL')
        TRIAL = TRIAL.TRIAL(trialselect);
    end
    
    %Unpack Trial
    traj = TRIAL.traj;
    bio_points = TRIAL.PTS_bio;
    bio_angles = TRIAL.ANG_bio;
    error = TRIAL.error;
    s = TRIAL.s;
    mode = TRIAL.mode;
    file = TRIAL.file;

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
            bias = TRIAL.constraints.bias(n);
            
            %plot the rods
            plot([C(1),F(1)],[C(2),F(2)],'-g','LineWidth',1)
            
            %also plot whiskers?
        
        %% plotting whiskers
            %decide whether to plot green (normal) or yellow (bias offset)
            veclen = 0.25;
            if all(TRIAL.constraints.bias == 0)
               %plot mechanism whisker
               plot([F(1), F(1)+veclen*cos(prot)],[F(2), F(2)+veclen*sin(prot)],'g','LineWidth',2) 
            else
               %plot offset bias whisker
               plot([F(1), F(1)+veclen*cos(prot+bias)],[F(2), F(2)+veclen*sin(prot+bias)],'b','LineWidth',2)
            end
        
            %plotting a little unit vector for bio pts
            angle = bio_angles(t,n);
            plot([F(1), F(1)+veclen*cos(angle)],[F(2), F(2)+veclen*sin(angle)],'m','LineWidth',2)
            
            %determine Pmin and Pmax
            wc = [s*sqrt(1-s^2);(1-s)];
            Pmax = atan((F(2)*wc(2)-CF1(2))/(F(2)*wc(1)-CF1(1)));
            Pmin = atan((F(2)*wc(2)-CF1(2))/(-F(2)*wc(1)-CF1(1)));
            %plot Pmin and Pmax 
%             plot([F(1), F(1)+(0.5)*veclen*cos(Pmax)],[F(2), F(2)+(0.5)*veclen*sin(Pmax)],'MarkerEdgeColor',[0.8500, 0.3250, 0.0980],'LineWidth',1)
%             plot([F(1), F(1)+(0.5)*veclen*cos(Pmin)],[F(2), F(2)+(0.5)*veclen*sin(Pmin)],'MarkerEdgeColor',[0.8500, 0.3250, 0.0980],'LineWidth',1)
            
            %plot the point
            if strcmp(mode,'line_1dof')
                if (angle < Pmax && angle > Pmin) || (angle < Pmin && angle > Pmax) %if angle is between
                        plot(F(1),F(2),'o','MarkerEdgeColor','black','MarkerFaceColor','red');    
                else
                    plot(F(1),F(2),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
                end
            else
                plot(F(1),F(2),'o','MarkerEdgeColor','black','MarkerFaceColor','white');
            end
        
         
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

