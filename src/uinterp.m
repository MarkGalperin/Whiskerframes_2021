function u = uinterp(theta_t,theta_b,theta,s,y,output)
    % *** KINEMATIC BIOLOGICAL POINTS ***
    % This function takes the biological datasets and produces arrays of
    % points for inputting into the search experiment.
    %
    % Takes kindata: output from get_biopts_kinematic
    %       numpts: number of additional points interpolated
    %       type: "linear" or "model"
    %       side: "right" or "left"
    % 
    % Returns   data_out:
    
    %calculate u based on the stuff
    blep = (s*cosd(theta_t-theta)-cosd(theta_t))/(sind(theta_t-theta_b));
    u = [s*sind(theta),1-s*cosd(theta)]*y - blep*[cosd(theta_b),sind(theta_b)];
    %angle output option
    if strcmp(output,'angle')
        u = atand(u(2)/u(1));
    end
    
end

