function [ANG,PTS,WID] = pp1_janelia(MSR)
% *** Data Preprocess (STEP 1) - Janelia Data ***
% This function does the first step of preprocessing (fetching data,
% filling in all the gaps). Step 2 repositions and visualizes the data.
%
% Takes MSR:    measurements file struct, output from function
%               LoadMeasurements() provided by the janelia whisker tracker library
% 
% Returns ANG: [TxN] array of whisker angles for N whiskers
%         PTS: [3xNxT] array of follicle positions in homogenous (x;y;1)
%         coordinates for N whiskers over T frames

    %% Get data
    % get relevant columns from MSR
    fid = [MSR.fid];
    wid = [MSR.wid];
    len = [MSR.length];
    ang = [MSR.angle];
    scr = [MSR.score];
    fx = [MSR.follicle_x];
    fy = [MSR.follicle_y];

    %% narrow down to candidate points by asserting a length threshold
    lenthres = 120;
    select = (len >= lenthres);

    %get selected values
    fidsel = fid(select);
    lensel = len(select);
    anglesel = ang(select);
    xsel = fx(select);
    ysel = fy(select);
    widsel = wid(select);

    %reconstruct array
    A = [fidsel',lensel',anglesel',xsel',ysel',widsel'];
    
    %% Estimating T and N
    %get T
    T = max(fidsel) + 1;
    Nsamps = zeros(1,T+1);
    for t = 1:T
        %get values at fid = t-1 (fid starts at 0)
        tsel = A(:,1) == t-1;
        samps = A(tsel,:);
        %find and log how many things you get
        Nsamps(t) = size(samps,1);
    end
    N = mode(Nsamps); %most common number of samples
    
    %% Initialize arrays
    %stuff
    B_log = zeros(N,5,T);
    
    %outputs
    ANG = nan(T,N);
    X = nan(T,N);
    Y = nan(T,N);
    LEN = nan(T,N);
    
    %% LABELING ALGORITHM
    for t = 1:T
        %get values at time = t
        tsel = A(:,1) == t-1;
        B = double(A(tsel,2:end));

        %INITIAL CASE
        if t == 1
            %Sort selection by increasing value of X - Y
            XmY = B(:,3) - B(:,4);
            [~,si] = sort(XmY);
            Bsort = B(si,:);

            %log first sort
            B_log(:,:,1) = Bsort;

        %ELSE
        else
            %calculate distances from previous point. Don't include wid
            Bm = B_log(:,:,t-1);
            D = get_distances(B(:,3),Bm(:,3)); %1:3 for (x,y,th), 1:4 for (x,y,th,l)
            
            %% construct sort indices (new algorithm for classifying whiskers)
            algmodes = {'min1','big2'}; 
            algmode = algmodes{1};
            
            % get rankings per new point (1 = min distance to prev point --> N = max distance to prev point)
            % the rows of the matrix "rnk" encode the nth min distance to each new point! this is neat.
            [Dsort,rnk] = sort(D,1);
            
            %check if all numbers are represented in row of rnk. If not,
            %use some algorithm to sort them up to 1-1
            if all(sort(rnk(1,:)) == 1:N)
                %sort index is the top row of rnk
                si = rnk(1,:)';
            else
                %initialize sort_i
                si = rnk(1,:)';
                
                %here, the sort index is non-unique! Start algorithms...
                switch algmode
                    case 'min1' %sort by shortest 1st distance
                        %find which points are in conflict...
                        mocc = find(histcounts(rnk(1,:)) > 1); %list of all multiple-occuring values
                        
                        %find "available points"
                        avail = find(~ismember(1:N,rnk(1,:))); %list of all old point values that havent been chosen
                        
                        for m = mocc %iterate over mocc to resolve conflicts
                            %get indices in conflict
                            conf_i = find(rnk(1,:)==m);
                            
                            %get the 1st-distances from those indices
                            conf_1d = Dsort(1,conf_i);
                            notmin = conf_i(conf_1d ~= min(conf_1d)); %"which of these is NOT the minimum?" (the minimum is already correct)
                            
                            %now loop over the not-mins and assign new values from available points 
                            r = 2;
                            while r <= N && ~isempty(avail)
                                for nm = notmin
                                    %check the r'th-distance index from the
                                    %notmin value in question...
                                    rth = rnk(r,nm);
                                    if ismember(rth,avail)
                                        %assign new index
                                        si(nm) = rth;
                                        %delete from avail
                                        avail(avail ~= rth);
                                    end
                                end
                                %increment r
                                r = r + 1;
                            end
                        end
                        
                        
                        
                end
            end
            
            %apply sort
            Bsort = B(si,:);

            %log sort
            B_log(:,:,t) = Bsort;
            
        end
        
        %assign output
        LEN(t,:) = Bsort(:,1)';
        ANG(t,:) = Bsort(:,2)';
        X(t,:) = Bsort(:,3)';
        Y(t,:) = Bsort(:,4)';
        WID(t,:) = Bsort(:,5)';
        
    end

    %convert X and Y to PTS
    PTS = ones(3,N,T);
    %assign x and y
    PTS(1,:,:) = permute(X,[3,2,1]);
    PTS(2,:,:) = permute(Y,[3,2,1]);
    
    getdiff = 0;
    if getdiff %plot the difference in distance values across the array. This gives a good estimate of how well tracking is performed
        %get distances
        figure;
        plot(pts2distances(PTS));
    end

end

