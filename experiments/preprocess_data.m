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
run_janelia = 1;
run_biofilter = 1;
RUN = [run_staticframes,...
        run_deeplabcut,...
        run_luciesdata,...
        run_janelia,...
        run_biofilter]; %add as needed

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
    files = 11:16; % Mar 2017 (C row, 5 whiskers)
%         files = 15; %9/28, just doing one
%     files = 17:nfiles; % Feb 2018 (C row, 5 whiskers)
%     files = 1:10; %Just B row
%     files = 1:nfiles; %all files

    for ii = files
        %get paths
        mpath = ['../data/janelia/',tbl.date{ii},'/measurements/',tbl.Filename{ii},'.measurements'];        
        %display paths
        fprintf('File %d/%d. Data from the following path: \n',ii,nfiles);
        fprintf('Measurements: %s \n',mpath);

        %save info
        savename = sprintf('/janelia_%.2d_(%s)',ii,tbl.date{ii}); %CHANGE MADE HERE IN POST
        savefile = append(path,savename);

        % measurements struct
        MSR = LoadMeasurements(mpath);

        %% STEP 1: get data, interpolate gaps, exclude extras
        fillnans = true;
        omitlast = tbl.omit_last(ii);
        extrasel = true;
        [ANG,PTS] = pp1_janelia(MSR,fillnans,omitlast,extrasel);

        %plot whisker angles
        T = size(ANG,1);
        N = size(ANG,2);
        plotangles = true;
        if plotangles
            figure('Renderer', 'painters', 'Position', [10 10 1500 300])
                plot(1:T,ANG');
                xlabel('time')
                ylabel('whisker angle')
                titlestr = sprintf('Run #%d. N = %d',ii,N);
                title(titlestr);
            %save plot 
            saveas(gcf, savefile, 'png');
        end

        %% STEP 2: reorient and draw offset angle
        [ANG2,PTS2] = pp2_janelia(PTS,ANG);
        %define offset angle
        off_angle = 20*(pi/180);
        other.off_angle = off_angle;


        %% Step 3: get normalized (projected) mousemap points
        N = size(ANG2,2);
        includes = str2num(tbl.include{ii});
        row = tbl.row{ii};
        mousepoints = pp_mousemap2norm(row,includes,N);
        PTS3 = repmat(mousepoints,1,1,T);

        %step 3 angle: rotated by -(offset + pi/2)
        ANG3 = ANG2 - (pi/2 + other.off_angle);
        ANG3 = flip(ANG3,2); %FLIP ORDER TO BE CAUDAL -> ROSTRAL

        %% save in struct
        S.msrpoints = PTS;
        S.msrangles = ANG;
        S.pp2points = PTS2;
        S.pp2angles = ANG2;
        S.points = PTS3;
        S.angles = ANG3; %FLIP to be in order caudal -> rostral
        save(savefile,'-struct','S');

        %% make animation?
        animate_janelia = true;
        if animate_janelia
            figure('Renderer', 'painters', 'Position', [10 10 1000 300])
                complete = preprocess_janelia_animate(S,other,savename);
        end

    end
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
        
        %record and save
        DATA_f.angles = ANG_f;
        DATA_f.points = PTS;
        savefile = ['../data/processed/filtered/filt_',filenames{ii}];
        save(savefile,'-struct','DATA_f');
        
        %complete
        fprintf('Filtered %s \n',filenames{ii})
        
    end
    %complete
    fprintf('DONE FILTERING')
    

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








