%% Scrap script for tests
clear;
clc;

%include stuff
addpath('../src/optimization');

%% %% FIRST STEP TO A BETTER (faster) BRUTE-FORCE OPTIMIZER %% %%
% %trying to index out points using contraint functions
% start w/ boundaries...
C.res = [0.01, 0.01, 0.005]; %search resolution for r1,r2,th
C.lb = [-0.5,-0.25,-pi/2]; %lower value bounds
C.ub = [0,1.25,pi/2]; %upper value bounds
C.sb = [1,1,pi/3]; %search box absolute dimensions
C.s = 0.3;
C.c = 0.1; %compatability tolerance
% define constraint
C.R = 0.5; %xy jump tolerance (NEW: this now only makes sense to be less than the search box, otherwise the searchbox defines the constraint)
C.accel = 0.1; %xy acceleration tolerance
C.dtheta = (pi/2); %theta jump tolerance
C.ddtheta = 0.1; %theta acceleration constraint
%define a configuration at a moment in time where you want to apply cuts to your search space...
% random slice I took from some dataset...
%    -0.3600    0.0900    0.3548
%    -0.3800    0.1100    0.2192
%    -0.3800    0.1300    0.1256
%    -0.3800    0.1300    0.0820
%    -0.3800    0.1300    0.0764
%    -0.3600    0.1100    0.1208
%    -0.3400    0.1100    0.1632
xmm = [-0.3800    0.1300    0.0764];
xm = [-0.3600    0.1100    0.1208];
traj_t = xm;

%define an r1,r2,theta array mesh?
r1_range = C.lb(1):C.res(1):C.ub(1);
r2_range = C.lb(2):C.res(2):C.ub(2);
th_range = C.lb(3):C.res(3):C.ub(3);

%make this into a MESH
[R1,R2,TH] = meshgrid(r1_range,r2_range,th_range);

%order mesh into a single axis (full set)...
S0 = [R1(:),R2(:),TH(:)]; %this step takes 0.1 seconds

%% apply 1st cut to the set...
%local bounds
r1_min = max([C.lb(1),traj_t(1)-C.sb(1)/2]);
r1_max = min([C.ub(1),traj_t(1)+C.sb(1)/2]);
r2_min = max([C.lb(2),traj_t(2)-C.sb(2)/2]);
r2_max = min([C.ub(2),traj_t(2)+C.sb(2)/2]);
th_min = max([C.lb(3),traj_t(3)-C.sb(3)/2]);
th_max = min([C.ub(3),traj_t(3)+C.sb(3)/2]);
%generate index
S0_i = (S0(:,1) > r1_min) & (S0(:,1) < r1_max) &...
       (S0(:,2) > r2_min) & (S0(:,2) < r2_max) &...
       (S0(:,3) > th_min) & (S0(:,3) < th_max);

S1 = S0(S0_i,:);

%% now apply constraint functions to set...
[g_arr,S1_i,val] = newconst(S1,xm,xmm,C);

%apply index
S2 = S1(S1_i,:);

%% New objective function!
[Errs,Prot,Dang] = newobj(S2,C,bio_pts,bio_ang);

% return mean error E
E = mean(Errs,2);

%% return info
if Cstruct.objinfo
    info = [Prot ; bio_ang ; Dang ; Errs];
else
    info = NaN(4,N);
end






% %trying tight_subplot
% [ha,pos] = tight_subplot(3,2,[.08 .03],[.1 .01],[.01 .01]);
%     for ii = 1:6
%         axes(ha(ii));
%         plot(randn(10,ii)); 
%     end
% set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')


% %% switch case
% thing = '3';
% 
% switch thing
%     case '1'
%         fprintf('1 \n');
%     case {'2','3'}
%         fprintf('23 \n');
% end


% %% plotting out some filtered data
% DATA_i = load('../data/processed/filtered/filt_janelia_15_(3_25_17).mat');
% 
% %% cut down the data to a manageble or target time range
% X = 1:500; %X = 1:size(DATA_i.ANG,1)
% ANG_cut = DATA_i.angles(X,:);
% PTS_cut = DATA_i.points(:,:,X);
% %get x and y for the first whisker
% X = reshape(PTS_cut(1,1,:),[500,1]);
% Y = reshape(PTS_cut(2,1,:),[500,1]);
% 
% plot(ANG_cut)

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