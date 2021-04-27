%% PREPROCESSING BIOLOGICAL DATA
% this script should be run before [the others], to process and visualize
% datasets, saving data that's friendly for the other scripts/functions
clear;
clc;

%% Include files
addpath('../src')
addpath('../src/deming')
addpath('../src/preprocess');
addpath('../src/circle_fit')

%% Which datasets are we pre-processing?
% true = perform this pre-process and write files. false = don't
run_staticframes = false;
run_deeplabcut = true;
run_luciesdata = false;
RUN = [run_staticframes,...
        run_deeplabcut,...
        run_luciesdata]; %add as needed
%% STATIC FRAMES PRE-PROCESS
% implement
if RUN(1)
end
    
%% 	DEEPLABCUT PRE-PROCESS
if RUN(2)
    %% define output location and mode
    path = '../data/processed';
    mode = 'MSEset';
    animate = true; %produce an animation of the stuff
    other.blank = 0; %initialize "other" struct
    
    %% GET DATA
    [base1,tip1] = get_deeplabcut('../data/deeplabcut/row_example.mat');
    
    %% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %%
    %% evenly spaced points (by number of whiskers) NOT IMPLEMENTED
    if strcmp(mode,'even')
        [Ps,angles] = preprocess_dlc_even();
        %save data
        S.points = Ps;
        S.angles = angles;
        file = append(path,'/dlc_even.mat');
        save(file,'-struct','S');
    
    %% points run through old get_searchframe function
    elseif strcmp(mode,'gsf')
        %run function
        [YPTS,ANG] = preprocess_dlc_gsf(base,tip);
        %save data
        S.points = YPTS;
        S.angles = ANG;
        file = append(path,'/dlc_gsf.mat');
        save(file,'-struct','S');
        
    %% points projected from best rotation points
    elseif strcmp(mode,'bestrot')
        % AS OF 4/1/21, DOES NOT PRODUCE ACCURATE BASEPOINTS
        [base2,tip2,other] = preprocess_dlc_bestrot(base1,tip1);
    
    %% simple transformation
    elseif strcmp(mode,'simple')
        [base2,tip2] = preprocess_dlc_trans(base1,tip1);
    
    %% searchframe_kinematic ("new" get_searchframe)
    % this function returns transformed base points and angles based on a
    % best-fit line run through the original basepoints (deming
    % regression). The angles and line information are packaged in the
    % "other" struct included in the output, which is then interpreted by
    % the animate function below.
    elseif strcmp(mode,'sfk')
        [base2,tip2,other] = searchframe_kinematic(base1,tip1);
    
    %% USING MOUSEMAP AND CONSTANT OFFSET ANGLE
    % here, I'm using the static basepoints of mousemap as basepoint
    % positions, then projecting them onto a best-fit line via deming
    % regression. 
    elseif strcmp(mode,'mousemap')
        row = 'B';
        side = 'R';
        animal = 6;
%         mousepoints = get_mousemap(row,animal,side,'flattenz');
%         [base2,tip2,other] = searchframe_kinematic(base1,tip1);
%         [base2,tip2,other] = preprocess_dlc_mousemap(base1,tip1,mousedata);
    elseif strcmp(mode,'MSEset')
        row = 'C';
        mseset = fliplr(get_MSEset(row,'flattenz')); %flipped for proper order?
        %normalize points 
        dummy_angles = zeros(1,size(base1,2)+1); %OMITTING ONE WHISKER 
        dummy_angles(1,5) = nan;                    %WHISKER 5 IS NAN
        [mousepoints,~] = get_searchframe(mseset,dummy_angles,'deming','C',true);
        %preprocess
        [base2,tip2,other] = preprocess_dlc_mousemap(base1,tip1,mousepoints);
        %3rd subplot
        other.SP3 = true;
        
        %convert y points for saving
        T = size(base2,3);
        N = size(base2,2);
        Ys = zeros(T,N);
        for t =1:T
            for n = 1:N
                Ys(t,n) = base2(2,n,t);
            end
        end
        
        %save data
        S.points = base2;
        S.angles = other.ang_mse;
        file = append(path,'/dlc_MSE.mat');
        save(file,'-struct','S');
    end
    
    %% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %%
    %% ANIMATE
    if animate
        filename = 'apr18test';
        preprocess_dlc_animate(base1,tip1,base2,tip2,other,filename);
    end
    
end

%% lucie's data pre-process
if RUN(3)
    dostuff;
end