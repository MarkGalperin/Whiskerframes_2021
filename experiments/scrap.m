%% Scrap script for tests
clear;
clc;

%% trying out table
LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
Age = [38;43;38;40;49];
BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
T = table(LastName,Age,BloodPressure);

% %% unpacking mousemap
% path = '../data/MSE_cubic_all.mat';
% mousedata = importdata(path);
% num = mousedata.AnimalNum;
% row = mousedata.Row;
% sides = mousedata.Side;
% points = cell2mat(mousedata.BPPoints);
% 
% %% get relevant points
% animal = 1;
% side = 1;%right side
% rowselect = 2;
% 
% %define index and call
% index = (sides==side & num==animal & row==rowselect);
% select = points(index,:);




% %% getting homogenous coordinate vectors in matrices over time
%idea: i can perform homogenous transforms on groups of points, expressed
%as columns of a matrix. 3xn matrix, where n is the number of points. How
%might i have time-trajectories for these points? Let's try letting the
%THIRD indexed dimension be time, and perform a tranform on it.

% %define a simple matrix of points in homogenous coords
% P = [[1;0;1],[1;1;1],[1;2;1],[1;3;1]];
% R = [[0;1;0],[-1;0;0],[0;0;1]]; %90 degree rotation
% P2 = R*P;
% 
% %define a T-timeframe 3D vector
% T = 30; 
% Pt = repmat(P,1,1,T);
% Rt = repmat(R,1,1,T);
% Pt2 = pagemtimes(Rt,Pt); % oh turns out its this function

% %% unpacking data
% path = '../data/deeplabcut/row_example.mat';
% DATA = importdata(path);
% 
% %get field names and values...
% fields = fieldnames(DATA);
% vals = struct2cell(DATA);
% 
% %initialize output
% base = [];
% tip = [];
% 
% for i = 1:length(vals)
%     if strcmp(fields{i}(end-3:end),'base')
%         base = horzcat(base,vals{i});
%     elseif strcmp(fields{i}(end-2:end),'tip')
%         tip = horzcat(tip,vals{i});
%     end
% end