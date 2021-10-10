function Fig = plot_config(S,TRIAL,X,prot)
% *** WHISKER CONFIGURATION TRAJECTORIES ***
% This function is a wrapper for plot_shadededcomp() to produce the output
% plot for N whiskers

    %% setup
    LGD = {};
    traj = TRIAL.traj;
    
    %% plots
    figure('Renderer', 'painters', 'Position', [10 10 900 600])
        hold on
        
        %plot the configuration over the time range
        if S.conf_r1r2{1}
            plot(X,traj(X,1),S.conf_r1r2{2},...
                 X,traj(X,2),S.conf_r1r2{3},...
                 X,traj(X,3),S.conf_r1r2{4});
            %append to legend
            LGD = [LGD,{'r1','r2','th'}];
        end
        %plot the w-basis configuration
        if S.conf_p1p2{1}
            %get w-basis trajectory
            traj_w = coordchange(traj,TRIAL.s,'rp');
            %plot
            plot(X,traj_w(X,1),S.conf_p1p2{2},...
                 X,traj_w(X,2),S.conf_p1p2{3},...
                 X,traj_w(X,3),S.conf_p1p2{4});
            %append to legend
            LGD = [LGD,{'p1','p2','th'}];
        end
        %plot negative inverted w-basis config with inverted p1
        if S.conf_p1invp2{1}
            %get w-basis trajectory
            traj_w = coordchange(traj,TRIAL.s,'rp');

            %invert p1
            traj_w(:,1) = -1./traj_w(:,1);

            %normalize
            normalizep1 = 1;
            if normalizep1
                traj_w(:,1) = normalize(traj_w(:,1));
            end

            %plot
            plot(X,traj_w(X,1),S.conf_p1p2{2},...
                 X,traj_w(X,2),S.conf_p1p2{3},...
                 X,traj_w(X,3),S.conf_p1p2{4});
            %append to legend
            LGD = [LGD,{'1/p1','p2','th'}];
        end
        %plot trajectory velocity (in xy frame)
        if S.conf_v1v2{1}
            dtraj = 7*(traj(1:size(traj,1)-1,:) - traj(2:end,:));
            dX = 2:length(X);
            plot(dX,dtraj(dX-1,1),...
                 dX,dtraj(dX-1,2)); %dX,dtraj(dX-1,3)
                 
            %append to legend
            LGD = [LGD,{'dr1','dr2'}];%'dth'
        end
        %plot trajectory acceleration (in xy frame)
        if S.conf_a1a2{1}
            ddtraj = 10*(dtraj(1:size(dtraj,1)-1,:) - dtraj(2:end,:));
            ddX = 3:length(X);
            plot(ddX,ddtraj(ddX-2,1),...
                 ddX,ddtraj(ddX-2,2));%ddX,ddtraj(ddX-2,3)
            %append to legend
            LGD = [LGD,{'ddr1','ddr2','ddth'}];
        end      
        %plot the mean biological protractions
        if S.conf_biomeanp{1}
            %get mean bio angles
            ANG_m = mean(TRIAL.ANG_bio,2);
            %plot
            plot(X,ANG_m(X),'-b','LineWidth',1)
            %append to legend
            LGD = [LGD,'mean bio. angle'];
        end
        if S.conf_biospread{1}
            %get mean bio angles
            ANG_top = TRIAL.ANG_bio(:,end);
            ANG_bot = TRIAL.ANG_bio(:,1);
            ANG_spread = (ANG_top-ANG_bot);
            %plot
            plot(X,ANG_spread(X),S.conf_biomeanp{2},'LineWidth',1)
            %append to legend
            LGD = [LGD,'biological spread'];
        end
        if S.conf_bioallp{1}
            %subtract out means?
            if S.biomeans
                biowhisk = TRIAL.ANG_bio - repmat(mean(TRIAL.ANG_bio),[size(TRIAL.ANG_bio,1),1]);
            else
                biowhisk = TRIAL.ANG_bio;
            end
            %plot
            plot(biowhisk(X,:),'Color',S.conf_bioallp{2},'LineWidth',1)
            %append to legend
            LGD = [LGD,'biological whisker protractions'];
        end
        if S.conf_mecallp{1}
            %subtract out means?
            if S.mecmeans
                mecwhisk = prot - repmat(mean(prot),[size(prot,1),1]);
            else
                mecwhisk = prot;
            end
            %plot
            plot(mecwhisk,'Color',S.conf_mecallp{2},'LineWidth',1)
            %append to legend
            LGD = [LGD,'mechanical whisker protractions'];
        end
        %plot the mean mechanical protractions
        if S.conf_mecmeanp{1}
            %get mean mechanical protractions
            prot_m = mean(prot,2);
            %plot
            plot(X,prot_m(X),S.conf_mecmeanp{2})
            %append to legend
            LGD = [LGD,'mean mech. angle'];
        end
        %plot error over time
        err = TRIAL.error(X);
        if S.conf_error{1}
            if normalized
                err = normalize(err);
            end
            plot(X,err,'LineWidth',1)
            %append to legend
            LGD = [LGD,'mean error'];
        end
        %plot overconstraint events
        if S.overc{1}
            if isfield(TRIAL,'overc')
                events = find(TRIAL.overc(X));
                if ~isempty(events)
                    for linx = events
                        top = pi/2;
                        bottom = -pi/2;
                        plot([linx,linx],[top,bottom],S.overc{2})
                    end
                end
            end
        end
        

        %get constraint info (for title)
        C = TRIAL.constraints;
%         conf_title = sprintf('dx < %.3f , dth < %.3f , ddx < %.3f, ddth < %.3f, dddx < %.3f, dddth < %.3f',C.R,C.dtheta,C.accel,C.ddtheta,C.jerk,C.jth);
        conf_title = sprintf('dx < %.3f , dth < %.3f , ddx < %.3f, ddth < %.3f',C.R,C.dtheta,C.accel,C.ddtheta);
        

        % format plot
        xlabel('time frame');
        legend(LGD,'Location','northeastoutside');
        title(conf_title);
        subtitle(sprintf('average trial error = %f deg',mean(err)*(180/pi)));%show mean error in subtitle
    %% return figure
    Fig = gcf;
        
end

