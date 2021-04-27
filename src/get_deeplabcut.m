function [base,tip] = get_deeplabcut(path)
% *** GET POINTS FROM DEEPLABCUT DATA ***
    % This function returns the points and angles 
    %
    % Takes path: filepath to deeplabcut data
    % 
    % Returns   base: x,y points for base points
    %           tip: x,y points for tip points
    %
    %% unpacking data
    path = '../data/deeplabcut/row_example.mat';
    DATA = importdata(path);

    %get field names and values...
    fields = fieldnames(DATA);
    vals = struct2cell(DATA);

    %initialize output
    base = ones(3,5,length(vals{1}.x)); %EDIT TO WORK FOR ANY DATASET
    tip =  ones(3,5,length(vals{1}.x));
    b_i = 1;
    t_i = 1;

    %NOTE: I FLIPPED THE SIGN FOR Y. THIS IS VIDEO DATA, SO Y COMES FROM
    %THE TOP. THIS FIXES A LOT.
    for ii = 1:length(vals)
        if strcmp(fields{ii}(end-3:end),'base')
            %format x and y as homogenous column vectors
            base(1,b_i,:) = vals{ii}.x;
            base(2,b_i,:) = -vals{ii}.y;
            b_i = b_i+1;
        elseif strcmp(fields{ii}(end-2:end),'tip')
            %format x and y as homogenous column vectors
            tip(1,t_i,:) = vals{ii}.x;
            tip(2,t_i,:) = -vals{ii}.y; 
            t_i = t_i+1;
        end
    end
end

