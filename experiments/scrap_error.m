%% GETTING NON-ERRONIOUS ERROR
clc;
clear;

%% get trial
loadstr = '../output/trial_data/error_test.mat'; 
TRIAL = load(loadstr);

%% export stuff from the trial
PTS = TRIAL.PTS_bio;
ANG = TRIAL.ANG_bio;
ypts = PTS(2,:,1); %assuming these are constant (MSE data)
traj = TRIAL.traj; %[T,N]
info = TRIAL.info;

%% reformat info
info_prot = permute(info(1,:,:),[3 2 1]);
info_bio = permute(info(2,:,:),[3 2 1]);
info_derror = permute(info(3,:,:),[3 2 1]);
info_error = permute(info(4,:,:),[3 2 1]);