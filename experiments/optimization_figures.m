%% Making figures based on trials of the optimization runs!!
% IDEAS:
% - plot angle values. x axis t, y axis angles. plot for bio (violet) and
% mechanism
% - compare errors between...
%   - 3dof and 1dof
%   - constrained and unconstrained
%   - increase different constraints
% - plot normalized configuration over time
% - compare bounding boxes?
% - change s values
clear;
clf;
clc;

%% Include files
addpath('../src')
addpath('../src/figures');

%% Get (1) trial data TODO: make all
% loadstr = '../output/trial_data/Sep1test_thetalim1_stest2.mat'; 
% loadstr = '../output/trial_data/post_filtered/restest8_filt.mat'; 
% loadstr = '../output/trial_data/3dof_restest8.mat'; 
% loadstr = '../output/trial_data/hjhjg_evenbias.mat'; 
loadstr = '../output/trial_data/bias/two/Sept28_test2.mat'; 
% loadstr = '../output/trial_data/Sept24_reset_nocon3.mat'; 
% loadstr = '../output/trial_data/D19_C001.mat';

%get trial (and filter for different output formats)
TRIAL = load(loadstr);
if isfield(TRIAL,'TRIAL') 
    trialselect = 1; %1 or 2 to do regular or bias
    TRIAL = TRIAL.TRIAL(trialselect);
end

PTS = TRIAL.PTS_bio;
ANG = TRIAL.ANG_bio;
ypts = PTS(2,:,1); %assuming these are constant (MSE data)

%% Extracting info
%getting a trajectory, mechanical protractions
traj = TRIAL.traj; %[T,N]
prot = traj2prot(traj,TRIAL.s,ypts); %prot is [T,N]
if isfield(TRIAL,'info')
    info = TRIAL.info;
    info_prot = permute(info(1,:,:),[3 2 1]);
    info_bio = permute(info(2,:,:),[3 2 1]);
    info_derror = permute(info(3,:,:),[3 2 1]);
    error = permute(info(4,:,:),[3 2 1]);
else
    %calculate error (CURRENTLY THIS DOESNT WORK RIGHT)
    error = prot2error(prot,ANG,'abs','sum');
end

%% Multi-plot
multi = true;
if multi
    %% file setup
    multidir = '../output/figures/multi/';
    file = 'Sep28_test2';
    filepath = [multidir,file];
    %make directory
    mkdir(filepath)
    
    %% configuration plot
    %PLOT SETTINGS IN STRUCT S
    S.conf_r1r2 = {true,'-r','-m','-b'}; % r1,r2 configuration
    S.conf_p1p2 = {false,'-r','-m','-b'}; % w basis configuration
    S.conf_p1invp2 = {false,'-r','-m','-b'}; % w basis configuration with 1/p1
    S.conf_v1v2 = {false}; % trajectory velocity
    S.conf_a1a2 = {false}; % trajectory acceleration
    S.conf_biomeanp = {false,'-k'};% mean protraction (biological)
    S.conf_biospread = {false,'-g'};% mean protraction (biological)
    S.conf_bioallp = {false,[0.5,0.5,0.5]}; % ALL whisker protractions (biological)
        S.biomeans = true;
    S.conf_mecallp = {false,[0.5,0.5,0.5]}; % ALL whisker protractions (mechanical)
        S.mecmeans = true;
    S.conf_mecmeanp = {false,'-y'};% mean protraction (mechanical)
    S.conf_error = {false,'-k'}; %mean error
    %error normalized?
    S.normalized = 0;
    S.overc = {true,'-r'};
    
    %range
    X = 1:size(prot,1);
     
    % Generate plot
    conf_plots = plot_config(S,TRIAL,X,prot);
    % Save plot 
    conf_file = [file,'_conf'];
    conf_path = filepath;
    saveas(conf_plots, fullfile(conf_path, conf_file), 'png');
    clf;

    %% comparison plot
    %generate plot
    N = size(ANG,2);
    ploterror = true;
    if ~isfield(TRIAL,'overc')
        TRIAL.overc = NaN;
    end
    comp_plots = plot_whiskercomp(X,N,ANG,info_prot,error,TRIAL.overc);
    
    %save plot
    comp_file = [file,'_comp']; 
    comp_path = filepath; 
    saveas(comp_plots, fullfile(comp_path, comp_file), 'png');
    clf;

    %% error
    %generate plot
    err_plot = plot_error2(X,error,'-r');
    %save plot
    err_file = [file,'_err']; 
    err_path = filepath; 
    saveas(err_plot, fullfile(err_path, err_file), 'png');

end


%% Shaded comparison plot
comp = false;
if comp
    %generate plot
    N = 5;
    X = 1:427;
    comp_plots = plot_whiskercomp(X,N,ANG,prot);
    
    %save plot
    comp_path = '../output/figures/comparison';
    comp_file = 'newdataplot';  
    saveas(comp_plots, fullfile(comp_path, comp_file), 'png');
    
    %clear figure
    clf;
end

%% Configuration plots
conf = false;
if conf
    %clear figure
    clf;
    
    %PLOT SETTINGS IN STRUCT S
    S.conf_r1r2 = {true,'-r','-m','-b'}; % r1,r2 configuration
    S.conf_p1p2 = {false,'-r','-m','-b'}; % w basis configuration
    S.conf_p1invp2 = {false,'-r','-m','-b'}; % w basis configuration with 1/p1
    S.conf_v1v2 = {true}; % trajectory velocity
    S.conf_a1a2 = {true}; % trajectory acceleration
    S.conf_biomeanp = {false,'-k'};% mean protraction (biological)
    S.conf_mecmeanp = {false,'-y'};% mean protraction (mechanical)
    S.conf_error = {false,'-k'}; %mean error
    %error normalized?
    S.normalized = 0;
    
    %range
    X = 1:427; %max range is 1:size(prot,1)
     
    % Generate plot
    conf_plots = plot_config(S,TRIAL,X);
    % Save plot 
    conf_file = 'newdatatest';
    conf_path = '../output/figures/configuration';
    saveas(conf_plots, fullfile(conf_path, conf_file), 'png');
    
end

%% visualize filtering plot
filtvis = false;
if filtvis
    N = 1;
    figure('Renderer', 'painters', 'Position', [10 10 900 600])
        for w = 1:N
            %get bio curve
            X = 1:427; %1:size(prot,1);
            Y = transpose(ANG(X,w));

            %apply low-pass filter
            freq = [100,50,25,10];
            F = cell(1,length(freq));

            for ii = 1:length(freq)
                f = freq(ii);
                Y_f = bwfilt(Y,500,0,f);
                %log the value
                F{ii} = Y_f;
            end

            %plot
            subplot(N,1,w)
                hold on
                %plot regular signal
                plot(X,Y,'-k');

                %plot filtered signal
                for ii = 1:length(freq)
                    hold on
                    f = freq(ii);
                    plot(X,F{ii})
                end

                %subplot legend
                legend([{'raw'},arrayfun(@num2str, freq, 'UniformOutput', 0)]);

        end

        % format plot
        xlabel('time frame');
        filt_plots = gcf;

        % save plot
        path_filt = '../output/figures/filtvis';
        filt_file = 'filtvis_one';   
        saveas(filt_plots, fullfile(path_filt, filt_file), 'png');
end

%% normalized traj over t with error
tcomp = false;
if tcomp
    N = 3;
    traj = TRIAL.traj;
    err = TRIAL.error;

    %get curves
    X = 1:427; %1:size(prot,1);

    %plot
    tcomp_plot = plot_trajcomp(X,traj,err);

    % format plot
    tcomp_plots = gcf;

    % save plot
    path_tcomp = '../output/figures/trajcomp';
    tcomp_file = 'trajectory_comp';    
    saveas(tcomp_plots, fullfile(path_tcomp, tcomp_file), 'png');
end

%% theta trajectory limitations


%% error wrt change in parameters over t
splot = false;
if splot
    %selection values
    Rvals =[0.05,0.1,0.2,0.4,0.8];
    dthvals =[0.1571,0.3142,0.3927,0.5236,0.7854];
    svals = [0.3,0.45,0.6,0.75];
    R = Rvals(1);
    dth = dthvals(1);
    s = svals(4);

    % change in s
    error_s = plot_errors('s',TABLE,s,dth,R,path,[400,600]);
    path_err = '../output/figures/errorcomp';
    errs_file = 'error_wrt_s';
    saveas(error_s, fullfile(path_err, errs_file), 'png');
    clf;

    % change in R constraint
    error_R = plot_errors('R',TABLE,s,dth,R,path,[]);
    errs_file = 'error_wrt_R';
    saveas(error_R, fullfile(path_err, errs_file), 'png');
    clf;

    % change in dtheta constraint
    error_dth = plot_errors('dth',TABLE,s,dth,R,path,[400,550]);
    errs_file = 'error_wrt_dth';
    saveas(error_dth, fullfile(path_err, errs_file), 'png');
end



    
    
    
    
