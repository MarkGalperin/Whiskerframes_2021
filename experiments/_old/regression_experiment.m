%% REGRESSION EXPERIMENT
% This experiment aims to use linear regression to infer correlations
% between biological whisker movement and configuration variables.
clear;
clc;

%% Include files
addpath('../src')
addpath('../src/deming')
addpath('../src/preprocess');

%% Get trial
loadstr = '../output/trial_data/bias/two/test2.mat'; 
TRIAL = load(loadstr);

%% calculate things
%get w-basis trajectory
traj_w = coordchange(TRIAL.traj,TRIAL.s,'rp');
%invert and normalize p1
traj_w(:,1) = -1./traj_w(:,1);
traj_w(:,1) = (traj_w(:,1)-min(traj_w(:,1)))/(max(traj_w(:,1))-min(traj_w(:,1)));

%calculate statistics on bio whiskers
bio_angs = TRIAL.ANG_bio;
N = size(bio_angs,2);
T = size(bio_angs,1);
meansub = 1; %subtract out means?
if meansub
    biowhisk = TRIAL.ANG_bio - repmat(mean(TRIAL.ANG_bio),[size(TRIAL.ANG_bio,1),1]);
    bio_means = mean(biowhisk,2);
else
    bio_means = mean(bio_angs,2); %mean biological angles, [Tx1]
end
bio_var = sum((bio_angs-bio_means).^2,2)/(N-1); %variance, [Tx1]

%% Perform regression
%set up data
X = [ones(T,1),bio_means,bio_var];
y = traj_w(:,1);
%RSS Linear regression closed-form solution
weights = inv(X'*X)*X'*y;

%% 3D plot
pt3d = 1;
if pt3d
    hold on
    for ii = 1:T
        
    end
    hold off
end

%% time plot
tplot = 0;
if tplot
    xplot = 1:T;
    hold on
        plot(xplot,traj_w(:,1))
        plot(xplot,bio_means)
        plot(xplot,bio_var)
        plot(xplot,sqrt(bio_var))
        plot(biowhisk,'-k')
        legend('-1/p1','mean','var','stdv','bio')
    hold off
end


