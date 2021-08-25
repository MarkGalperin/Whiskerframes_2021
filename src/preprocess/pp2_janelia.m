function [ANG2,PTS2] = pp2_janelia(PTS,ANG)
% *** Data Preprocess (STEP 2) - Janelia Data ***
% This function does the second  step of preprocessing (blah, blah). Step 1 fetches and interpolates gaps.
    %
    % Takes PTS, ANG: output from step 1
    % 
    % Returns ANG2: [TxN] array of whisker angles for N whiskers
    %         PTS2: [3xNxT] array of follicle positions in homogenous (x;y;1)
    %         coordinates for N whiskers over T frames

    %% PREPROCESS SETTINGS
    % !angles currently hard-coded to convert to Radians (i dont want to write another conditional)
    flipy = true;
    
    %% change to radians
    ANG = deg2rad(ANG);
    
    %% apply y flip
    if flipy
        %invert angle
        ANG2 = -ANG;
        %flip y
        PTS2 = PTS.*[1;-1;1]; %invert y values
    else
        ANG2 = ANG;
        PTS2 = PTS;
    end
    
    
end

