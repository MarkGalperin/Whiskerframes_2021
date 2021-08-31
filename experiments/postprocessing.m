%% POST-PROCESSING DATA
% Here I'll try running trajectories generated by the optimization
% experiment and ry to smooth them (using filters, etc.) and then see how
% the error changes as a result!

clear;
clf;
clc;

%% Include files
addpath('../src')
addpath('../src/deming')
addpath('../src/preprocess');
addpath('../src/circle_fit')

%% Which post-processes are we running?
% true = perform this pre-process and write files. false = don't
run_animate = true;
run_filter = false;
RUN = [run_animate,...
       run_filter]; %add as needed
    
%% ANIMATE TRAJECTORIES
%
if RUN(1)
%     loadstr = '../output/trial_data/hjhjg_evenbias.mat';  
%     loadstr = '../output/trial_data/3dof_restest8.mat'; 
%     loadstr = '../output/trial_data/post_filtered/restest8_filt.mat'; 
%     loadstr = '../output/trial_data/bias/one/test1.mat'; 
    loadstr = '../output/trial_data/bias/two/test2.mat'; 
    
    TRIAL = load(loadstr);
    TRIAL.file = 'biastest_22';
    % Generate Animation
    complete = optimization_animate(TRIAL); %automatically saves to output/movies/optimization/
end

%% POST-FILTER TRAJECTORIES
if RUN(2)
    %get trial data
    loadstr = '../output/trial_data/3dof_restest6.mat'; 
    fileout = 'restest8_filt';
    TRIAL_0 = load(loadstr);
    PTS = TRIAL_0.PTS_bio;
    ANG = TRIAL_0.ANG_bio;
    ypts = PTS(2,:,1); %assuming these are constant (MSE data)
    
    % get trajectory info
    traj = TRIAL_0.traj; %[T,N]
    prot = traj2prot(traj,TRIAL_0.s,ypts); %prot is [T,N]
    
    %apply low-pass bwfilt to the trajectory
    sfreq = 500; %500 fps video
    freq = 50; %Hz
    traj_f = bwfilt(traj,sfreq,0,freq);
    
    %get new protractions
    prot_f = traj2prot(traj_f,TRIAL_0.s,ypts); %prot is [T,N]
    
    %calculate error
    error_f = prot2error(prot_f,ANG,'abs','sum');
    
    %re-package TRIAL as TRIAL_f
    TRIAL_f = TRIAL_0;
    TRIAL_f.traj = traj_f;
    TRIAL_f.error = error_f;
    
    %save TRIAL_f 
    file_trial = append('../output/trial_data/post_filtered/',fileout);
    save(file_trial,'-struct','TRIAL_f');

end







