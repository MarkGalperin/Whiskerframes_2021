%% Scrap script for tests
clear;
clc;

%% plotting out some filtered data
DATA_i = load('../data/processed/filtered/filt_janelia_15_(3_25_17).mat');

%% cut down the data to a manageble or target time range
X = 1:500; %X = 1:size(DATA_i.ANG,1)
ANG_cut = DATA_i.angles(X,:);
PTS_cut = DATA_i.points(:,:,X);
%get x and y for the first whisker
X = reshape(PTS_cut(1,1,:),[500,1]);
Y = reshape(PTS_cut(2,1,:),[500,1]);

plot(ANG_cut)

% subplot(1,3,1)
%     plot(ANG_cut(:,1));
% subplot(1,3,2)
%     plot(X);
% subplot(1,3,3)
%     plot(Y);


% %% making a fake messy curve
% X = 0:0.01:2;
% Y = (X-1).^3 - X + 2 + 0.1*rand(size(X));
% 
% %% making an agent follow Y...
% y0 = Y(1);
% for ii = 1:length(Y)
%     if ii == 1
%     elseif ii == 2
%     else
%         %make fake optimizing search
%         y_s = (ym-0.1):0.001:(y_s+0.1); %search over 100 values
%         %faulty error optimizer 
%         E = ones(size(y_s))*Inf; %initialize error
%         %loop
%         for jj = 1:length(y_s)
%             %get faulty error
%             E(jj) = y;
%         end
%     end
% end
% 
% 
% %% plot
% plot(X,Y,'-b');
% 

% %% NaN correction edge cases
% % define matrices
% a = randi([0,10],10,5);
% %define NaNs
% a(2,3) = NaN;
% a(6:end,4) = NaN;
% a(1:3,2) = NaN;
% a_inp = a;
% NaNs = isnan(a);
% %% interpolating to replace NaN values
% for n = 1:size(NaNs,2) %iterate over columns (whiskers)
%     %edge case 1: first row is NaN
%     t = 1;
%     if NaNs(1,n) 
%         while NaNs(t,n)
%             if NaNs(t+1,n)
%                 t = t+1; %advance
%             else
%                 endi = t+1;
%                 %set all values in column to first non-NaN value
%                 a_inp(1:endi,n) = a(endi,n);
%                 break
%             end
%         end
%     end
%     
%     %edge case 2: last row is NaN
%     if NaNs(end,n)
%         t = size(NaNs,1); %set that last thing
%         while NaNs(t,n)
%             if NaNs(t-1,n)
%                 t = t-1; %advance
%             else
%                 endi = t-1;
%                 %set all values in column to first non-NaN value
%                 a_inp(endi:end,n) = a(endi,n);
%                 break
%             end
%         end
%     end
% 
% 
% 
% end





% %% trying out table
% LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
% Age = [38;43;38;40;49];
% BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
% T = table(LastName,Age,BloodPressure);

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