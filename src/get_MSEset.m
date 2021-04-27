function data_out = get_MSEset(row,mode)
    % *** STATIC BIOLOGICAL POINTS ***
    % This function returns basepoints from the MSE dataset, an averaged
    % set of mouse data which might be cleaner than the mousemap data.
    %
    % Takes Input1: rdsfkjhsdfk
    %       Input2: dsfhjsdf
    % 
    % Returns   mousedata: an array of column vectors, each with homogenous
    %           coordinates of points projected onto {xy}
    %           ang: a corresponding array of projected base angles
    
    %% fetch data
    path = '../data/MSE.mat';
    data = importdata(path);
    
    %get row indices
    k = cell2mat(transpose(keys(data)));
    ind = (k(:,1) == row);
    
    %% return points based on mode
    if strcmp(mode,'flattenz')
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
    elseif strcmp(mode,'rotate')
        data_out = 'poopy';
    elseif strcmp(mode,'xyz')
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

