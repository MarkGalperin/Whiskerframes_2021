function data_out = get_MSEset(row,mode)
    % *** STATIC BIOLOGICAL POINTS ***
    % This function returns basepoints from the MSE dataset, an averaged
    % set of mouse data which might be cleaner than the mousemap data.
    %
    % Takes row: [str] letter from 'A' to 'E'
    %       mode: [str] "get_data", "3D_points", or "flattenz" determines
    %               the output array by the following:
    %               - "get_data" returns the struct containing all
    %                 measurements
    %               - "xyz" returns [x;y;z] column vectors of
    %                 selected points, in cubic mm
    %               - "flattenz" returns [x;y;1] column vectors in
    %                 homogenous coordinates that can be transformed using
    %                 SE(2)
    % 
    % Returns   mousedata: an array of column vectors, each with [xyz] or
    %               [x;y;1] homogenous coordinates
    
    %% fetch data
    path = '../data/MSE.mat';
    data = importdata(path);
    
    %get row indices
    k = cell2mat(transpose(keys(data)));
    ind = (k(:,1) == row);
    
    %% get Gamma whisker (NEW: for oconnor data)
    %index data
    s_gam = data('C01');
    %get spherical
    R = mean(s_gam.BPR);
    th = mean(s_gam.BPTheta);
    ph = mean(s_gam.BPPhi);
    %calculate xy, z = 0
    x= R*cosd(th)*cosd(ph);
    y= R*sind(th)*cosd(ph);
    %save point
    gamma = [x;y;1]; %Gamma coordinates
        
        
    %% return points based on mode
    switch mode
        case 'get_data'
            %return data struct
            out = data;
        case 'flattenz'
            %initialize
            c = 0;
            out = zeros(3,length(k(ind,:)));
            for point = transpose(k(ind,:))
                %index data
                s = data(point);
                %get spherical
                R = mean(s.BPR);
                th = mean(s.BPTheta);
                ph = mean(s.BPPhi);
                %calculate xy, z = 0
                x= R*cosd(th)*cosd(ph);
                y= R*sind(th)*cosd(ph);
                %save point
                c = c+1;
                out(1:3,c) = [x;y;1]; %homogenous coord vector
            end
        case 'flattenz_oconnor' %NEW: THIS ATTRIBUTES GAMMA TO THE B ROW
            %initialize
            c = 0;
            out = zeros(3,length(k(ind,:)));
            for point = transpose(k(ind,:))
                %index data
                s = data(point);
                %get spherical
                R = mean(s.BPR);
                th = mean(s.BPTheta);
                ph = mean(s.BPPhi);
                %calculate xy, z = 0
                x= R*cosd(th)*cosd(ph);
                y= R*sind(th)*cosd(ph);
                %save point
                c = c+1;
                out(1:3,c) = [x;y;1]; %homogenous coord vector
            end
            %now, replace "Beta" with "Gamma"
            if strcmp(row,'B')
                out(1:3,1) = gamma;
            end

        case 'xyz'
            %initialize
            c = 0;
            out = zeros(3,length(k(ind,:)));
            for point = transpose(k(ind,:))
                %index data
                s = data(point);
                %get spherical
                R = mean(s.BPR);
                th = mean(s.BPTheta);
                ph = mean(s.BPPhi);
                %calculate xyz
                x= R*cosd(th)*cosd(ph);
                y= R*sind(th)*cosd(ph);
                z= R*sind(ph);
                %save point
                c = c+1;
                out(1:3,c) = [x;y;z];
            end
    end
    data_out = out;
    
end

