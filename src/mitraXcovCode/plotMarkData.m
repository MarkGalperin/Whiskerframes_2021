

clear; clc;
  fnames = dir('D14*.mat');
% fnames = dir('D15*.mat');
% fnames = dir('D16*.mat');
winsize = 60; shiftwin = 1;

%  idx = 1570;  %%% for trial 14;
idx = 2500;  %%% for trial 14;
%  idx = 2500;  %%% for trial 15;
%idx = 2500;  %%% for trial 16;

for  qq = 1:length(fnames)
    figure(qq);
    fname = fnames(qq).name;
    load(fname)
    alls = TRIAL.traj;   %%% alls stands for all simulated
    r1 = alls(1:idx,1);
    subplot(11,1,1);plot(alls(1:idx,:));axis('tight');colorbar;
    r2 = alls(1:idx,2);
    theta = alls(1:idx,3);

    allw = TRIAL.ANG_bio;   %%% allw stands for all whiskers
    w1 = allw(1:idx,1);
    w2 = allw(1:idx,2);
    w3 = allw(1:idx,3);
    w4 = allw(1:idx,4);
    w5 = allw(1:idx,5);
    subplot(11,1,2); plot(allw(1:idx,:)); 
    prot = mean(allw(1:idx,:)'); ho;  plot(prot,'k');ln2;axis('tight');colorbar;
    spread = w5 - w1;  plot(spread,'m');ln2;colorbar; 

    subplot(11,1,3);
    [t,xt,x] = runningxcov(theta, r1, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;
    subplot(11,1,4);
    [t,xt,x] = runningxcov(theta, r2, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;
    subplot(11,1,5);
    [t,xt,x] = runningxcov(r1, r2, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

    subplot(11,1,6);
    [t,xt,x] = runningxcov(theta,prot, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

    subplot(11,1,7);
    [t,xt,x] = runningxcov(theta, spread, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

 
    subplot(11,1,8);
    [t,xt,x] = runningxcov(r1,prot, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

    subplot(11,1,9);
    [t,xt,x] = runningxcov(r1, spread, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

    subplot(11,1,10);
    [t,xt,x] = runningxcov(r2,prot, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

    subplot(11,1,11);
    [t,xt,x] = runningxcov(r2, spread, winsize, shiftwin);
    pcolor(t,xt,x);shading('flat');colorbar;

    c = redwhiteblue(-1,1); colormap(c);

    set(gcf,'Position',[1          41        1920         963]);
    tempstring = ['print -djpeg ' fname(1:end-4) '_win60' ];
    eval(tempstring);

end
