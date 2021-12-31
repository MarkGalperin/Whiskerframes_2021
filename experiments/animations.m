%% ANIMATIONS SCRIPT!
% this is the new place I'm calling my animations from.
clear;
clf;
clc;

%% Include files
addpath('../src')
addpath('../src/animation')

%% Which animations are we running?
% true = perform this pre-process and write files. false = don't
anm_frames = 0;
anm_whiskers = 0;
anm_preprocess = 0;

ANM = [anm_frames,...
       anm_whiskers,...
       anm_preprocess]; %add as needed
   
%% animate frames
if ANM(1)
    %     loadstr = '../output/trial_data/Oct7_Mar17.mat';  
    loadstr = '../output/trial_data/V4_1dof.mat'; 
%     loadstr = '../output/trial_data/post_filtered/V4_mtest_postfilt.mat'; 
%     loadstr = '../output/trial_data/bias/one/test1.mat'; 
%     loadstr = '../output/trial_data/bias/two/Sept28_test2.mat'; 
%     loadstr = '../output/trial_data/BATCH_Oct19/BatchSet_15/D15_C001.mat';    
%     loadstr = '../output/trial_data/BATCH_1dof_Nov27/BatchSet_15/D15_C007.mat';
%     loadstr = '../output/trial_data/BATCH_3dof_Dec4/BatchSet_16/D16_C008.mat';
%     loadstr = '../output/trial_data/Sept24_reset_nocon3.mat';

    TRIAL = load(loadstr);
    TRIAL.file = 'V4_1dof';
    % Generate Animation
    complete = optimization_animate(TRIAL); %automatically saves to output/movies/optimization/
end

%% animate frames + whiskers
if ANM(2)
    %load data
    loadstr = '../output/trial_data/V4_1dof.mat'; 
    TRIAL = load(loadstr);
    
    % Generate Animation
    TRIAL.file = 'V4_1dof';
    complete = animate_whiskers(TRIAL); %automatically saves to output/movies/optimization/
    
end

%% animate



