%% "Running" correlation coefficient 
% In this experiment, I am performing a "running correlation" to see how
% well mechanical signals line up with biological signals in a sliding
% window across the full time set. The idea is that this sliding value (the
% correlation coefficient) serves as a measure of a hypothetical control
% strategy. Whe are looking for when (and for which signals) that control
% strategy changes.

clear;
clc;
clf;

%% includes
addpath('../src')

%% Get trial data
% loadstr = '../output/trial_data/Oct7_Mar17.mat';
batch_dir = '../output/trial_data/BATCH_Dec21_filt/';
loadstr = [batch_dir,'BatchSet_16/D16_C003.mat'];

%get trial (and filter for different output formats)
TRIAL = load(loadstr);
if isfield(TRIAL,'TRIAL') 
    trialselect = 1; %1 or 2 to do regular or bias
    TRIAL = TRIAL.TRIAL(trialselect);
end

%% setup
%running xcov setup
sW = 200; %Sample radius

%% Unpack trajectory and bio whiskers
%get bio whiskers
biowhisk = TRIAL.ANG_bio;

%get trajectory and w-basis trajectory
traj = TRIAL.traj;
traj_w = coordchange(traj,TRIAL.s,'rp');
p1inv = -1./traj_w(:,1);
T = size(traj,1);

%initialize table for output
out_tbl = array2table(zeros(0,9));
out_tbl.Properties.VariableNames = {'signal','w1','w2','w3','w4','w5','spread','mean','variance'};

%define mechanistic signals
% msignals = {{'r1',traj(:,1)},...
%            {'r2',traj(:,2)},...
%            {'th',traj(:,3)}}; %r1,r2,th      
% msignals = {{'p1',traj_w(:,1)},...
%            {'p2',traj_w(:,2)},...
%            {'th',traj(:,3)}}; %p1,p2,th  
% msignals = {{'pI',p1inv},...
%            {'p2',traj_w(:,2)},...
%            {'th',traj(:,3)}}; %pI, p2,th
       
% msignals = {{'r1',traj(:,1)},...
%            {'r2',traj(:,2)},...
%            {'p1',traj_w(:,1)},...
%            {'p2',traj_w(:,2)},...
%            {'pI',p1inv},...
%            {'th',traj(:,3)}}; %all

%define biological signals
bsignals = {'mean','spread'};
bmean = mean(biowhisk,2);
bsprd = biowhisk(:,end)-biowhisk(:,1);


%% Calculate xcov coefficient over time for all signal combos
for msig_i = 1:length(msignals)
    %get mechanism signal
    msig = msignals{msig_i}{2};
    
    %initialize coefficient log
    coeff_log = zeros(2,T); %first row for mean, second row for spread

    %go through time
    for t = 1:T
        %define range
        X1 = max(1,t-sW);
        X2 = min(T,t+sW);
        X = X1:X2;

        %get coeficients and log
        w_coeff_m = corrcoef(bmean(X),msig(X));
        w_coeff_s = corrcoef(bsprd(X),msig(X));
        m_coeff = w_coeff_m(1,2);
        s_coeff = w_coeff_s(1,2);
        coeff_log(:,t) = [m_coeff;s_coeff];
    end

    %log coefficient value in struct...
    field_name_m = [msignals{msig_i}{1},'_x',bsignals{1}];
    field_name_s = [msignals{msig_i}{1},'_x',bsignals{2}];
    M.(field_name_m) = coeff_log(1,:);
    S.(field_name_s) = coeff_log(2,:);
    
end

%% plotting
%plot setup
Xp = 1:T; %plot range
ha = tight_subplot(3,1,[.05 .03],[.05 .1],[.1 .1]); %axes setup

%first, plot out all the angle data
axes(ha(1));
    hold on
    plot(Xp,bmean(Xp)) %plot mean whisker 
    plot(Xp,bsprd(Xp)) %plot spread
    
    legend('mean','spread')
    hold off

%next, plot all values in mean struct
axes(ha(2));
    fields = fieldnames(M);
    hold on
    for fi = 1:length(fields)
        %get field
        field = fields{fi};

        %plot the thing
        absplot = false;
        if absplot
            plot(Xp,abs(M.(field)(Xp)),'LineWidth',3);
            ylim([0,1]);
        else
            plot(Xp,M.(field)(Xp),'LineWidth',3);
            ylim([-1,1]);
        end
        

    end
    %label the plot signals
    legend(fields,'Location','southoutside','Orientation','horizontal');

    %plot vertical lines at window cutoffs
    if ismember(sW,Xp)
        xline(sW,'-r');
    end
    if ismember(T-sW,Xp)
        xline(T-sW,'-r');
    end

    %plot x-axis
    yline(0,'Color','#808080')
    
    hold off

% all values in spread struct
axes(ha(3));
    fields = fieldnames(S);
    hold on
    for fi = 1:length(fields)
        %get field
        field = fields{fi};

        %plot the thing
        absplot = false;
        if absplot
            plot(Xp,abs(S.(field)(Xp)),'LineWidth',3);
            ylim([0,1]);
        else
            plot(Xp,S.(field)(Xp),'LineWidth',3);
            ylim([-1,1]);
        end

    end
    %label the plot signals
    legend(fields,'Location','southoutside','Orientation','horizontal');

    %plot vertical lines at window cutoffs
    if ismember(sW,Xp)
        xline(sW,'-r');
    end
    if ismember(T-sW,Xp)
        xline(T-sW,'-r');
    end

    %plot x-axis
    yline(0,'Color','#808080')
    
    hold off
       
       
       
       