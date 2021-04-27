function data_out = get_interpolated_kinematic(kindata,numpts,type,side)
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
    %
    %% check for side
    if strcmp(side,'right')
        data_in = kindata(:,1:2);
    else
        data_in = kindata(:,3:4);
    end
    
    %% perform interpolation based on type
    %initialize output
    numwhisk = numpts + 2;
    numframes = length(data_in);
    data_out = zeros(numframes,numwhisk);
    s = 0.5;
    theta = -30; %[deg]
    
    %interpolation loop...
    for ii = 1:numframes
        if strcmp(type,'linear')
            data_out(ii,:) = linspace(data_in(ii,1),data_in(ii,2),numwhisk);
        end
        if strcmp(type,'model')
            theta_b = data_in(ii,1);
            theta_t = data_in(ii,2);
            data_out(ii,1) = theta_b;
            data_out(ii,numwhisk) = theta_t;
            y = linspace(0,1,numwhisk);
            %grep
            for jj = 1:numpts
                data_out(ii,1+jj) = uinterp(theta_t,theta_b,theta,s,y(jj+1),'angle');
            end
        end
    end
end

