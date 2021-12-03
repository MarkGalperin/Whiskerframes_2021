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
% 1 = perform this pre-process and write files. 0 = don't
run_staticframes = 0;
run_deeplabcut = 0;
run_luciesdata = 0;
run_janelia = 0;
run_biofilter = 1;
RUN = [run_staticframes,...
        run_deeplabcut,...
        run_luciesdata,...
        run_janelia,...
        run_biofilter]; %add as needed

if sum(RUN) == 0
    fprintf('nothing selected to run \n')
end

%% NEW DATA PREPROCESS (O'Connor Lab + Janelia whisker tracker)
if RUN(4)
   %% Includes
    addpath('../src')
    addpath('../src/whisk')
    addpath('../src/preprocess');
    addpath('../src/deming');

    %% save to...
    path = '../data/processed/janelia';

    %% Generate paths
    % get files from table
    tbl = readtable('../data/janelia/info.csv','Delimiter',',');
    % iterate over every file name
    nfiles = size(tbl,1);
%     files = 1:4; % Aug 2016 (B row, 4 whiskers)
%     files = 5:10; % Sep 2016 (B row, 3 whiskers)
%     files = 11:16; % Mar 2017 (C row, 5 whiskers)
%     files = 11:16; % Mar 2017 (C row, 5 whiskers)
    files = 14; %DATASETS TO USE FOR PUBLICATION (17:nfiles will be used during review)
%         files = 15; %9/28, just doing one
%     files = 17:nfiles; % Feb 2018 (C row, 5 whiskers)
%     files = 1:10; %Just B row
%     files = 1:nfiles; %all files

    for ii = 14:16
        %get paths
        mpath = ['../data/janelia/',tbl.date{ii},'/measurements/',tbl.Filename{ii},'.measurements'];
        wpath = ['../data/janelia/',tbl.date{ii},'/whiskers/',tbl.Filename{ii},'.whiskers'];
        %display paths
        fprintf('File %d/%d. Data from the following paths: \n',ii,nfiles);
        fprintf('Measurements: %s \n',mpath);
        fprintf('Whiskers: %s \n',wpath);

        %save info
        savename = sprintf('/janelia_%.2d_(%s)',ii,tbl.date{ii}); %CHANGE MADE HERE IN POST
        savefile = append(path,savename);

        % measurements struct
        MSR = LoadMeasurements(mpath);
        
        %WSK struct
        wpath = ['../data/janelia/whiskers/',tbl.date{ii},'/',tbl.Filename{ii},'.mat'];
        WSK = load(wpath);

        %% STEP 1: Open janelia data, perform labeling, identify gaps
        % Perform pre-process step 1.
        % This will return ANG, PTS, and associated WID 
        [ANG,PTS,WID] = pp1_janelia(MSR);
        
        %omit last whisker?
        if tbl.omit_last(ii)
            ANG = ANG(:,1:end-1);
            PTS = PTS(:,1:end-1,:);
            WID = WID(:,1:end-1);
        end
        
        % animate tracking (debug)
        pp1anim = 0;
        if pp1anim
            %get video data
            vidpath = ['../data/janelia/videos/',tbl.date{ii},'/',tbl.Filename{ii},'.avi'];
            vid = VideoReader(vidpath);
            %animation setup
            Stp.PTS = PTS;
            Stp.ANG = ANG;
            Stp.WID = WID;
            Stp.whiskvid = {true,vid};
            Stp.labels = true;
            Stp.plotANG = [1,1];
            file = 'theta_tracking';
            animpath = ['../data/processed/janelia/animation/whiskers/',file];
            
            %run animation
            complete = animate_whiskers(Stp,WSK,animpath);
        end


%         fillnans = true;
%         omitlast = tbl.omit_last(ii);
%         if 11<=ii && ii<=16
%             extrasel = true; %identify one more whisker for March 2017 data
%         else
%             extrasel = false;
%         end
%         
%         %run preprocess step 1
%         [ANG,PTS,WID,LAB] = pp1_janelia(MSR,fillnans,omitlast,extrasel,ii);
%         %get size info
%         T = size(ANG,1);
%         N = size(ANG,2);
%         
%         %plot whisker angles
%         plotangles = true;
%         if plotangles
%             figure('Renderer', 'painters', 'Position', [10 10 1500 300])
%                 plot(1:T,ANG');
%                 xlabel('time')
%                 ylabel('whisker angle')
%                 titlestr = sprintf('Run #%d. N = %d',ii,N);
%                 title(titlestr);
%             %save plot 
%             saveas(gcf, savefile, 'png');
%         end

        %% STEP 2: reorient and draw offset angle
        [ANG2,PTS2] = pp2_janelia(PTS,ANG);
        %define offset angle
        off_angle = 20*(pi/180);
        other.off_angle = off_angle;

        %% Step 3: get static points
        T = size(ANG,1);
        N = size(ANG2,2);
        
        %Select mode for pp3 points...
        pp3modes = {'mousemap_proj','mousemap_dist','oconnor_dist'};
        pp3mode = pp3modes{3};
        switch pp3mode
            case 'mousemap_proj'
                %get projected mousemap pts
                includes = str2num(tbl.include{ii});
                row = tbl.row{ii};
                mousepoints = pp_mousemap2norm(row,includes,N);
                %assign static points
                PTS3 = repmat(mousepoints,1,1,T);
            case 'mousemap_dist'
                %mousemap points: HARD-CODED! These values are calculated
                %from the script /tests/mousedistances.m. This will only
                %work for N == 5.
                mousedist = [0    0.3105    0.5519    0.7860    1.0000];
                %assign static points
                static_PTS = [zeros(1,5);mousedist;ones(1,5)];
                PTS3 = repmat(static_PTS,1,1,T);
            case 'oconnor_dist'
                %distances
                o_dist = flip(mean(pts2distances(PTS),1)); %flipped for caudal -> rostral
                o_dnorm = o_dist/sum(o_dist);
                o_pos = zeros(1,length(o_dnorm)+1);
                for kk = 1:length(o_dnorm)
                    o_pos(kk+1) = o_pos(kk) + o_dnorm(kk);
                end
                %assign static points
                static_PTS = [zeros(1,5);o_pos;ones(1,5)];
                PTS3 = repmat(static_PTS,1,1,T);
        end

        %% Step 3 angle: rotated by -(offset + pi/2)
        ANG3 = ANG2 - (pi/2 + other.off_angle);
        ANG3 = flip(ANG3,2); %FLIP ORDER TO BE CAUDAL -> ROSTRAL

        %% save in struct
        S.msrpoints = PTS;
        S.msrangles = ANG;
        S.pp2points = PTS2;
        S.pp2angles = ANG2;
        S.points = PTS3;
        S.angles = ANG3; %FLIP to be in order caudal -> rostral
        S.wid = WID;
        S.msr = MSR;
        S.WSK = WSK;
        S.dataset_num = ii;
        
        %save
        save(savefile,'-struct','S');

        %% make animation?
        animate_janelia = 1;
        if animate_janelia
            %get video data
            vidpath = ['../data/janelia/videos/',tbl.date{ii},'/',tbl.Filename{ii},'.avi'];
            vid = VideoReader(vidpath);
            
            %animation settings
            S.whiskvid = {true,vid};
            S.labels = true;
            S.plotANG = [1,1];
            
            %figure
            figure('Renderer', 'painters', 'Position', [10 10 1100 300])
                complete = preprocess_janelia_animate(S,other,savename);
        end

    end
%     stop =  'here';
end

%% filtering biological data
if RUN(5)
    
    %% scan the processed data directory
    DIR = dir('../data/processed/janelia');
    NAMES = {DIR.name};
    filenames = {};
    for ii = 1:length(NAMES)
        filestr = NAMES{ii};
        if length(filestr) > 4 && strcmp('.mat',filestr(end-3:end))
            filenames = [filenames;filestr];
        end
    end
    
    %% LOOP
    for ii = 1:length(filenames)      
        %% get data
        file = ['../data/processed/janelia/',filenames{ii}];
        DATA = load(file);
        ANG = DATA.angles;
        PTS = DATA.points; %this doesn't need filtering because its constant
        
        %% perform filtering
        sfreq = 500; %500 fps video
        freq = 50; %Hz - frequency for mice
        ANG_f = bwfilt(ANG,sfreq,0,freq);
        
        %build output struct
        DATA_f.angles = ANG_f;
        DATA_f.points = PTS;
        DATA_f.msrpoints = DATA.msrpoints;
        DATA_f.msrangles = DATA.msrangles;
        DATA_f.pp2points = DATA.pp2points;
        DATA_f.pp2angles = DATA.pp2angles;
        DATA_f.angles_unf = DATA.angles;
        DATA_f.points_unf = DATA.points;
        DATA_f.wid = DATA.wid;
        DATA_f.msr = DATA.msr;
        DATA_f.dataset_num = DATA.dataset_num;
        
        savefile = ['../data/processed/filtered/filt_',filenames{ii}];
        save(savefile,'-struct','DATA_f');
        
        %plot filtered angles
        plotangles_f = 0;
        if plotangles_f
            figure('Renderer', 'painters', 'Position', [10 10 1500 300])
                plot(1:T,ANG_f');
                xlabel('time')
                ylabel('whisker angle')
                titlestr = sprintf('Run #%d. N = %d',ii,size(ANG_f,2));
                title(titlestr);
            %save plot 
            saveas(gcf, savefile, 'png');
        end
        
        %complete
        fprintf('Filtered %s \n',filenames{ii})
        
    end
    %complete
    fprintf('DONE FILTERING \n')
    

%end biofilter
end  
    
    
% %% STATIC FRAMES PRE-PROCESS
% % implement
% if RUN(1)
% end
    
% %% 	DEEPLABCUT PRE-PROCESS
% if RUN(2)
%     %% define output location and mode
%     path = '../data/processed';
%     mode = 'MSEset';
%     animate = true; %produce an animation of the stuff
%     other.blank = 0; %initialize "other" struct
%     
%     %% GET DATA
%     [base1,tip1] = get_deeplabcut('../data/deeplabcut/row_example.mat');
%     
%     %% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %%
%     %% evenly spaced points (by number of whiskers) NOT IMPLEMENTED
%     if strcmp(mode,'even')
%         [Ps,angles] = preprocess_dlc_even();
%         %save data
%         S.points = Ps;
%         S.angles = angles;
%         file = append(path,'/dlc_even.mat');
%         save(file,'-struct','S');
%     
%     %% points run through old get_searchframe function
%     elseif strcmp(mode,'gsf')
%         %run function
%         [YPTS,ANG] = preprocess_dlc_gsf(base,tip);
%         %save data
%         S.points = YPTS;
%         S.angles = ANG;
%         file = append(path,'/dlc_gsf.mat');
%         save(file,'-struct','S');
%         
%     %% points projected from best rotation points
%     elseif strcmp(mode,'bestrot')
%         % AS OF 4/1/21, DOES NOT PRODUCE ACCURATE BASEPOINTS
%         [base2,tip2,other] = preprocess_dlc_bestrot(base1,tip1);
%     
%     %% simple transformation
%     elseif strcmp(mode,'simple')
%         [base2,tip2] = preprocess_dlc_trans(base1,tip1);
%     
%     %% searchframe_kinematic ("new" get_searchframe)
%     % this function returns transformed base points and angles based on a
%     % best-fit line run through the original basepoints (deming
%     % regression). The angles and line information are packaged in the
%     % "other" struct included in the output, which is then interpreted by
%     % the animate function below.
%     elseif strcmp(mode,'sfk')
%         [base2,tip2,other] = searchframe_kinematic(base1,tip1);
%     
%     %% USING MOUSEMAP AND CONSTANT OFFSET ANGLE
%     % here, I'm using the static basepoints of mousemap as basepoint
%     % positions, then projecting them onto a best-fit line via deming
%     % regression. 
%     elseif strcmp(mode,'mousemap')
%         row = 'B';
%         side = 'R';
%         animal = 6;
% %         mousepoints = get_mousemap(row,animal,side,'flattenz');
% %         [base2,tip2,other] = searchframe_kinematic(base1,tip1);
% %         [base2,tip2,other] = preprocess_dlc_mousemap(base1,tip1,mousedata);
%     elseif strcmp(mode,'MSEset')
%         row = 'C';
%         mseset = fliplr(get_MSEset(row,'flattenz')); %flipped for proper order?
%         %normalize points 
%         dummy_angles = zeros(1,size(base1,2)+1); %OMITTING ONE WHISKER 
%         dummy_angles(1,5) = nan;                    %WHISKER 5 IS NAN
%         [mousepoints,~] = get_searchframe(mseset,dummy_angles,'deming','C',true);
%         %preprocess
%         [base2,tip2,other] = preprocess_dlc_mousemap(base1,tip1,mousepoints);
%         %3rd subplot
%         other.SP3 = true;
%         
%         %convert y points for saving
%         T = size(base2,3);
%         N = size(base2,2);
%         Ys = zeros(T,N);
%         for t =1:T
%             for n = 1:N
%                 Ys(t,n) = base2(2,n,t);
%             end
%         end
%         
%         %save data
%         S.points = base2;
%         S.angles = other.ang_mse;
%         file = append(path,'/dlc_MSE.mat');
%         save(file,'-struct','S');
%     end
%     
%     %% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %%
%     %% ANIMATE
%     if animate
%         filename = 'apr18test';
%         preprocess_dlc_animate(base1,tip1,base2,tip2,other,filename);
%     end
%     
% end
% 
% %% lucie's data pre-process
% if RUN(3)
%     dostuff;
% end








