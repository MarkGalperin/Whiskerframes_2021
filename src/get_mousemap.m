function mousedata = get_mousemap(row,animal,side,mode)
% *** STATIC BIOLOGICAL POINTS ***
    % This function returns 
    %
    % Takes Input1: rdsfkjhsdfk
    %       Input2: dsfhjsdf
    % 
    % Returns   mousedata: an array of column vectors, each with homogenous
    %           coordinates of points projected onto {xy}
    %           ang: a corresponding array of projected base angles
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
    if strcmp(mode,'flattenz')
        %call xyz points
        select = points(index,:);
        
        %return x and y points as matrix of homogenous coord vectors 
        mousedata = transpose(select);
        mousedata(3,:) = ones(1,size(mousedata,2));
    elseif strcmp(mode,'rotate')
        %IMPLEMENT
    else
        error('invalid mode')
    end
end

