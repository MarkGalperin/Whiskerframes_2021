function mousepoints = pp_mousemap2norm(row,includes,N)
% *** Data Preprocess (Step 3) - Get mouse points in Janelia order ***
% Given a row, omitted whiskers, and [], this function uses get_MSEset and
% get_searchframe() to return normalized whisker positions in the same
% order (rostral -> caudal) as Janelia whisker tracker
    %
    % Takes row: (char) uppercase character of the selected row
    %       includes: row vector of integer values indicating which
    %           whiskers to include. should be in order caudal -> rostral,
    %           with 0 being the associated greek whisker.
    %       N: number of relevant tracked whiskers
    % 
    % Returns mousepoints: homogenous coordinate column-vectors of
    % mousepoints projected onto the y-axis, ommiting all whiskers that are
    % not in includes.
    
    %% get full row of mseset points
    %points are projected onto the z-axis.
    mserow = get_MSEset(row,'flattenz_oconnor'); %homogeneous coords
    mse_includes = 0:(length(mserow)-1); %to compare with includes
    
    %% omit all whiskers not in includes
    %sort includes, in case its not in order
    includes = sort(includes);
    %initialize vector of "dummy angles" to signal which whiskers to omit
    dummy_angles = zeros(1,N);
    %find which whiskers to omit (are not in includes) and assign NaN
    omit = mse_includes(~ismember(mse_includes,includes));
    for idx = (omit+1) %add 1 to convert into index
        dummy_angles(idx) = NaN; 
    end
    
    %% normalize with get_searchframe
    %shift via deming regression and normalize, project to y axis.
    [mousepoints,~] = get_searchframe(mserow,dummy_angles,'deming',row, false);

    
    
    
    
    
    