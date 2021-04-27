function [pts,ang] = get_biopts_static(row)
    % *** STATIC BIOLOGICAL POINTS ***
    % This function takes the biological datasets and produces arrays of
    % points for inputting into the search experiment.
    %
    % Takes Input1: row
    %       Input2: kljfsdljds
    % 
    % Returns   pts: an array of column vectors, each with homogenous
    %           coordinates of points projected onto {xy}
    %           ang: a corresponding array of projected base angles
    %% Dataset 
    RATMAP = importdata('NewRatMapModelOutput.mat');
    %Select rows..
    rows = ['A','B','C','D','E'];
    rowNames = RATMAP.modelNamesBP;
    
    %% Get data
    %initialize cell array
    data = cell(1,3);
    
    %Assemble cell array from data
    for ii = 1:36
        %Get x,y,z for the basepoints
        xyz = RATMAP.modelPointsBP(ii,:);
        %Get theta, phi for the whiskers
        th = RATMAP.modelThetaBP(ii);
        phi = RATMAP.modelPhiBP(ii);

        %Log data
        data(ii,:) = {rowNames(ii,:), xyz, [th,phi]};
    end
    
    %% Process data from one row
    row_data = data(find(rowNames == row),:); %TODO - do this the better way
    
    %flattened points (no z) in homogenous coordinates
    xyz_row = cell2mat(row_data(:,2));
    pts = transpose(xyz_row);
    pts(3,:) = 1; %flatten
    
    %flattened angles (just theta)
    ang_row = cell2mat(row_data(:,3));
    ang = transpose(ang_row(:,1))*(pi/180);
    
end
