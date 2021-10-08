function [ANG,PTS] = pp1_janelia(MSR,fillnans,omitlast,extrasel,numfile)
% *** Data Preprocess (STEP 1) - Janelia Data ***
% This function does the first step of preprocessing (fetching data,
% filling in all the gaps). Step 2 repositions and visualizes the data.
%
% Takes MSR:    measurements file struct, output from function
%               LoadMeasurements() provided by the janelia whisker tracker library
%       fillnans: boolean input for whether to interpolate away NaN
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
    len = [MSR.length];
    ang = [MSR.angle];
    scr = [MSR.score];
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
    
    %% Add additional 
    EXTRA = zeros(T,3);
    if extrasel
        %define selection. Select for unlabeled whiskers above a length
        %threshold.
        lenthres = 100;
        select = (lab == -1 & len >= lenthres);

        %get selected values
        fidsel = fid(select);
        lensel = len(select);
        anglesel = ang(select);
        xsel = fx(select);
        ysel = fy(select);
        
        %reconstruct array
        B = [fidsel',lensel',anglesel',xsel',ysel'];
        
        %run through array to deal with certain cases...
        for t = 0:T
            %get the rows for the time
            Bsel = B(fidsel == t,:); 
            
            %deal with gaps (NaN)
            if isempty(Bsel)
                %angle, x, and y are given a NaN value
                EXTRA(t+1,1) = NaN;
                EXTRA(t+1,2) = NaN;
                EXTRA(t+1,3) = NaN;
            
            %log values
            elseif size(Bsel,1) == 1
                %angle, x, and y are logged
                EXTRA(t+1,1) = Bsel(1,3);
                EXTRA(t+1,2) = Bsel(1,4);
                EXTRA(t+1,3) = Bsel(1,5);
            
            %deal with multiple selection
            else 
                %get the index of maximum length
                [~,ind] = max(Bsel(:,2));
                %log the maximum length values
                EXTRA(t+1,1) = Bsel(ind,3);
                EXTRA(t+1,2) = Bsel(ind,4);
                EXTRA(t+1,3) = Bsel(ind,5); 
            end
            
        end

    %remove and fill outliers manually (CURRENTLY ONLY FOR 14 AND 15. ADD MORE IF NEEDED)
    EXTRA_fill = EXTRA;
    if numfile == 14
        out_i = 942;
        %interpolate out a new value
        EXTRA_fill(out_i,1) = (1/2)*(EXTRA_fill(out_i-1,1)+EXTRA_fill(out_i+1,1));
        EXTRA_fill(out_i,2) = (1/2)*(EXTRA_fill(out_i-1,2)+EXTRA_fill(out_i+1,2));
        EXTRA_fill(out_i,3) = (1/2)*(EXTRA_fill(out_i-1,3)+EXTRA_fill(out_i+1,3));
    elseif numfile == 15
        out_i = 1626;
        %interpolate out a new value
        EXTRA_fill(out_i,1) = (1/2)*(EXTRA_fill(out_i-1,1)+EXTRA_fill(out_i+1,1));
        EXTRA_fill(out_i,2) = (1/2)*(EXTRA_fill(out_i-1,2)+EXTRA_fill(out_i+1,2));
        EXTRA_fill(out_i,3) = (1/2)*(EXTRA_fill(out_i-1,3)+EXTRA_fill(out_i+1,3));
    end
    
    %append extra row
    N = N+1; %increase N!
    ANG = [EXTRA_fill(:,1),ANG]; %recall, N has been iterated up
    X = [EXTRA_fill(:,2),X];
    Y = [EXTRA_fill(:,3),Y];
    
    end
    
    %% interpolating to replace NaN values
    if fillnans
        %run function to fill NaN values
        [ANG,X,Y] = preprocess_fillNaN(ANG,X,Y);
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
    
    %% process figures
    procfig = false;
    if procfig
        %define X range
        range = 1:T;
        
        %first: filter by length threshold
        f1 = figure(1);
            sgtitle('(1/4): filtered by length threshold')
            subplot(3,1,1)
                %plot angle
                plot(EXTRA(range,1))
                title('Angle')
                xlabel('t')
                ylabel('angle')
                
                
            subplot(3,1,2)
                %plot x
                plot(EXTRA(range,2))
                title('x')
                xlabel('t')
                ylabel('x')
                
                
            subplot(3,1,3)
                %plot y
                plot(EXTRA(range,3))
                title('y')
                xlabel('t')
                ylabel('y')
                
        
        %second: remove outliers  
        figure(2)
            sgtitle('(2/4): outliers removed via filloutliers()')
            subplot(3,1,1)
                %plot angle
                plot(EXTRA_fill(range,1))
                title('Angle')
                xlabel('t')
                ylabel('angle')
                
                
            subplot(3,1,2)
                %plot x
                plot(EXTRA_fill(range,2))
                title('x')
                xlabel('t')
                ylabel('x')
                
                
            subplot(3,1,3)
                %plot y
                plot(EXTRA_fill(range,3))
                title('y')
                xlabel('t')
                ylabel('y')
                
        
        %third: NaN removed
        figure(3)
            sgtitle('(3/4): NaNs removed')
            subplot(3,1,1)
                %plot angle
                plot(ANG(range,1))
                title('Angle')
                xlabel('t')
                ylabel('angle')
                
                
            subplot(3,1,2)
                %plot x
                plot(X(range,1))
                title('x')
                xlabel('t')
                ylabel('x')
                
            subplot(3,1,3)
                %plot y
                plot(Y(range,1))
                title('y')
                xlabel('t')
                ylabel('y')
         
        figure(4)
            sgtitle('(4/4): low-pass filter to 50 Hz')
            sfreq = 500; %500 fps video
            freq = 50; %Hz - frequency for mice
            ANG_f = bwfilt(ANG(range,1),sfreq,0,freq);
            X_f = bwfilt(X(range,1),sfreq,0,freq);
            Y_f = bwfilt(Y(range,1),sfreq,0,freq);
            
            subplot(3,1,1)
                %plot angle
                plot(ANG_f)
                title('Angle')
                xlabel('t')
                ylabel('angle')
                
                
            subplot(3,1,2)
                %plot x
                plot(X_f)
                title('x')
                xlabel('t')
                ylabel('x')
                
            subplot(3,1,3)
                %plot y
                plot(Y_f)
                title('y')
                xlabel('t')
                ylabel('y')
    end
    
    
end

