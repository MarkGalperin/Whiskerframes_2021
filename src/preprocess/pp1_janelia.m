function [ANG,PTS] = pp1_janelia(MSR,interpolate,omitlast)
% *** Data Preprocess (STEP 1) - Janelia Data ***
% This function does the first step of preprocessing (fetching data,
% filling in all the gaps). Step 2 repositions and visualizes the data.
    %
    % Takes MSR:    measurements file struct, output from function
    %               LoadMeasurements() provided by the janelia whisker tracker library
    %       interpolate: boolean input for whether to interpolate away NaN
    %               values in the output arrays. Highly reccomended!
    %       omitlast: boolean input for whether to omit the last whisker
    % 
    % Returns ANG: [TxN] array of whisker angles for N whiskers
    %         PTS: [3xNxT] array of follicle positions in homogenous (x;y;1)
    %         coordinates for N whiskers over T frames
    
    %% Get data
    
    % get relevant columns from MSR
    fid = [MSR.fid];
    wid = [MSR.wid];
    lab = [MSR.label];
    ang = [MSR.angle];
    fx = [MSR.follicle_x];
    fy = [MSR.follicle_y];

    % indices to filter out non-whiskers
    idx = (lab ~= -1);
    wsk = lab(idx);

    % find uniquely identified whisker values
    unq = unique(wsk);

    %calculate proportions
    prop = zeros(length(unq),1);
    for ii = 1:length(unq)
        whisk = unq(ii);
        prop(ii) = length(wsk(wsk==whisk))/length(wsk);
    end
    %normalize proportions
    prop_n = prop/max(prop);

    %filter out by threshold
    threshold = 0.1;
    filter = prop_n > threshold;

    %get whiskers and other data
    whiskers = unq(filter)+ 1; %+1 because janelia indices start with 0
    N = max(whiskers);
    T = max(fid);

    %% GETTING ANG & X,Y
    ANG = zeros(T,N);
    X = zeros(T,N);
    Y = zeros(T,N);
    for t = 0:T
        %define and apply selection parameters
        select = fid==t & wid < N & lab>-1; 
        labsel = lab(select);
        angsel = ang(select);
        xsel = fx(select);
        ysel = fy(select);

        %sorting matrices
        A = [double(labsel) ; angsel];
        Ax = [double(labsel) ; xsel];
        Ay = [double(labsel) ; ysel];

        %initialize row of NaN to identify missing elements
        init_row = NaN(1,N);
        if isempty(labsel)
            %log row
            ANG(t+1,:) = init_row;
            X(t+1,:) = init_row;
            Y(t+1,:) = init_row;
        else
            %reorder data
            [~,sorti] = sort(labsel);
            A_s = A(:,sorti);
            A_sx = Ax(:,sorti);
            A_sy = Ay(:,sorti);
            %assign and log angles
            init_row(A_s(1,:)+1) = A_s(2,:); %+1 to turn whisker id into MATLAB indices
            ANG(t+1,:) = init_row; 
            %assign and log x
            init_row = NaN(1,N);
            init_row(A_sx(1,:)+1) = A_sx(2,:); %+1 to turn whisker id into MATLAB indices
            X(t+1,:) = init_row; 
            %assign and log y
            init_row = NaN(1,N);
            init_row(A_sy(1,:)+1) = A_sy(2,:); %+1 to turn whisker id into MATLAB indices
            Y(t+1,:) = init_row;
        end 
    end

    %% interpolating to replace NaN values
%     interpolate = true;
    if interpolate
        %initialize interpolated arrays and check for NaN locations (should be the same for ang, x, and y)
        ANG_inp = ANG;
        X_inp = X;
        Y_inp = Y;
        NaNs = isnan(ANG);

        for n = 1:size(NaNs,2) %iterate over columns (whiskers)
            %edge case 1: first row is NaN
            t = 1;
            if NaNs(1,n) 
                while NaNs(t,n)
                    if NaNs(t+1,n)
                        t = t+1; %advance
                    else
                        endi = t+1;
                        %set all values in column to first non-NaN value
                        ANG_inp(1:endi,n) = ANG(endi,n);
                        X_inp(1:endi,n) = X(endi,n);
                        Y_inp(1:endi,n) = Y(endi,n);
                        
                        break
                    end
                end
            end

            %edge case 2: last row is NaN
            if NaNs(end,n)
                t = size(NaNs,1); %set that last thing
                while NaNs(t,n)
                    if NaNs(t-1,n)
                        t = t-1; %advance back
                    else
                        endi = t-1;
                        %set all values in column to first non-NaN value
                        ANG_inp(endi:end,n) = ANG(endi,n);
                        X_inp(endi:end,n) = X(endi,n);
                        Y_inp(endi:end,n) = Y(endi,n);                                              
                        break
                    end
                end
            end
            
            %debug: what are the NaNs right here at this point?
            what = {ANG_inp,X_inp,Y_inp};
            whatnan = {isnan(ANG_inp),isnan(X_inp),isnan(Y_inp)};

            %begin search - assuming no NaN in first or last rows now
            t = 2;
            while t<size(NaNs,1)
                if NaNs(t,n) && ~NaNs(t-1,n)
                    starti = t-1; %mark the value before the first NaN 
                    while NaNs(t,n) && t<size(NaNs,1)
                        if NaNs(t+1,n)
                            t = t+1; %advance
                        else
                            endi = t+1; %mark the value after the last NaN
                            %calculate interpolated values
                            ang_fill = linspace(ANG(starti,n),ANG(endi,n),1+(endi-starti));
                            x_fill = linspace(X(starti,n),X(endi,n),1+(endi-starti));
                            y_fill = linspace(Y(starti,n),Y(endi,n),1+(endi-starti));
                            %fill in the values
                            ANG_inp(starti:endi,n) = ang_fill;
                            X_inp(starti:endi,n) = x_fill;
                            Y_inp(starti:endi,n) = y_fill;
                            
                            if isnan(ANG(starti,n))
                                fprintf('STARTI IS NAN');
                            elseif isnan(ANG(endi,n))
                                fprintf('ENDI IS NAN');
                            end
                            %advance
                            t = t+1;
                            break
                        end
                    end
                else
                    t = t+1; %advance
                end
            end
        end
        
        %check remaining NaN
        if any(isnan(ANG_inp(:)))
            fprintf('(!!!!) NaN remaining in ANG \n');
        end
        if any(isnan(X_inp(:)))
            fprintf('(!!!!) NaN remaining in X \n');
        end
        if any(isnan(Y_inp(:)))
            fprintf('(!!!!) NaN remaining in Y \n');
        end
        
        %replace arrays
        X = X_inp;
        Y = Y_inp;
        ANG = ANG_inp;

    end
    
    %% Chop off end column
    if omitlast
        X = X(:,1:end-1);
        Y = Y(:,1:end-1);
        ANG = ANG(:,1:end-1); 
        N = N-1;
    end

    %% Contruct PTS as (3xNxT)
    %re-define T
    T = size(ANG,1);
    %initialize PTS
    PTS = ones(3,N,T);
    %assign x and y
    PTS(1,:,:) = permute(X,[3,2,1]);
    PTS(2,:,:) = permute(Y,[3,2,1]);
    
end

