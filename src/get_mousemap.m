function mousedata = get_mousemap(row,animal,side,mode)
% *** STATIC BIOLOGICAL POINTS ***
    % This function returns data from mousemap (MSE_cubic_all.mat)
    %
    % Takes row: [char] letter "A" through "E" corresponding to whisker row
    %       animal: [int] number (1) through (8) corresponding to mouse
    %       side: [char] ("L") or ("R") corresponding to side of mouse face 
    %       mode: [str] "get_data", "3D_points", or "flattenz" determines
    %               the output array by the following:
    %               - "get_data" returns the struct containing all
    %                 measurements
    %               - "xyz" returns [x;y;z] column vectors of
    %                 selected points, in cubic mm
    %               - "flattenz" returns [x;y;1] column vectors in
    %                 homogenous coordinates that can be transformed using
    %                 SE(2)
   
    
    
    %% check and translate input
    letrs = {'A','B','C','D','E'};
    sides = {'L','R'};
    row = find(strcmp(row,letrs)); %translate letter to number
    side = find(strcmp(side,sides)) - 1; %translate letter to 0/1
    if isempty(row)
        error('invalid row. Input ''A'', ''B'', ''C'', or ''D''');
    elseif animal <= 0 || animal > 8
        error('invalid animal. should be 1 through 8')
    elseif isempty(side)
        error('invalid side. Input ''L'' or ''R''')
    end
    
    %% fetch data
    path = '../data/MSE_cubic_all.mat';
    data = importdata(path);
    
    %% get relevant data
    num = data.AnimalNum;
    rows = data.Row;
    sides = data.Side;
    points = cell2mat(data.BPPoints);

    %% get relevant points
    index = (sides==side & num==animal & rows==row);
    
    %% return points based on mode
    switch mode
        case 'get_data'
            mousedata = data;
        case 'xyz'
            %call xyz points
            select = points(index,:);

            %return x and y points as matrix of homogenous coord vectors 
            mousedata = transpose(select);
        case 'flattenz'
            %call xyz points
            select = points(index,:);

            %return x and y points as matrix of homogenous coord vectors 
            mousedata = transpose(select);
            
            %sub z values for ones
            mousedata(3,:) = ones(1,size(mousedata,2));

        otherwise
            error('invalid mode')
    end
end

