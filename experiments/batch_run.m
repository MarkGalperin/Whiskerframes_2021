%% BATCH TRIALS 
% Running everything!!!
% Updated for v4 on Dec 6th
clear;
clc;

%% Including code
addpath('../src');
addpath('../src/deming');
addpath('../src/optimization');

%% Batch trial settings
biasalg = false;             %run bias algorithm, which performs two optimizations
RES = [0.01, 0.01, 0.001];  %Set Resolution 

%% DEFINE PARAMETERS
%define a cell datatype with the three dynamic constraint modes
    %3-dof trials
% dynamics = {struct('R',0.2,'accel',0.20,'dtheta',pi/6,'ddtheta',0.050),...
%             struct('R',0.2,'accel',0.15,'dtheta',pi/6,'ddtheta',0.030),...
%             struct('R',0.2,'accel',0.10,'dtheta',pi/6,'ddtheta',0.015),...
%             struct('R',0.2,'accel',0.06,'dtheta',pi/6,'ddtheta',0.008),...
%             struct('R',0.2,'accel',0.10,'dtheta',pi/6,'ddtheta',0.008),...
%             struct('R',0.2,'accel',0.20,'dtheta',pi/6,'ddtheta',0.008),...
%             struct('R',0.2,'accel',0.15,'dtheta',pi/6,'ddtheta',0.008),...
%             struct('R',0.2,'accel',0.15,'dtheta',pi/6,'ddtheta',0.015)}; % Oct15
% dynamics = {struct('R',0.2,'accel',0.10,'dtheta',pi/2,'ddtheta',0.10)};

    % 1-DOF trials
% dynamics = {struct('R',0.2,'accel',0.2,'dtheta',pi/10,'ddtheta',0.020),...   
%             struct('R',0.2,'accel',0.2,'dtheta',pi/10,'ddtheta',0.010),...      
%             struct('R',0.2,'accel',0.2,'dtheta',pi/10,'ddtheta',0.005),...      
%             struct('R',0.2,'accel',0.2,'dtheta',pi/30,'ddtheta',0.020),...
%             struct('R',0.2,'accel',0.2,'dtheta',pi/30,'ddtheta',0.010),...
%             struct('R',0.2,'accel',0.2,'dtheta',pi/30,'ddtheta',0.005),...
%             struct('R',0.2,'accel',0.2,'dtheta',pi/180,'ddtheta',0.020),...   
%             struct('R',0.2,'accel',0.2,'dtheta',pi/180,'ddtheta',0.010),...      
%             struct('R',0.2,'accel',0.2,'dtheta',pi/180,'ddtheta',0.005)}; 
% dynamics = {struct('R',0.2,'accel',0.2,'dtheta',pi/2,'ddtheta',0.015)};
dynamics = {struct('R',0.2,'accel',0.2,'dtheta',pi/2,'ddtheta',1),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/2,'ddtheta',0.05),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/2,'ddtheta',0.03),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/2,'ddtheta',0.02),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/2,'ddtheta',0.01),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/6,'ddtheta',1),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/6,'ddtheta',0.05),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/6,'ddtheta',0.03),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/6,'ddtheta',0.02),...
            struct('R',0.2,'accel',0.2,'dtheta',pi/6,'ddtheta',0.01),...
            struct('R',0.2,'accel',0.2,'dtheta',0.03,'ddtheta',1),...
            struct('R',0.2,'accel',0.2,'dtheta',0.03,'ddtheta',0.05),...
            struct('R',0.2,'accel',0.2,'dtheta',0.03,'ddtheta',0.03),...
            struct('R',0.2,'accel',0.2,'dtheta',0.03,'ddtheta',0.02),...
            struct('R',0.2,'accel',0.2,'dtheta',0.03,'ddtheta',0.01),...
            struct('R',0.2,'accel',0.2,'dtheta',0.02,'ddtheta',1),...
            struct('R',0.2,'accel',0.2,'dtheta',0.02,'ddtheta',0.05),...
            struct('R',0.2,'accel',0.2,'dtheta',0.02,'ddtheta',0.03),...
            struct('R',0.2,'accel',0.2,'dtheta',0.02,'ddtheta',0.02),...
            struct('R',0.2,'accel',0.2,'dtheta',0.02,'ddtheta',0.01),...
            struct('R',0.2,'accel',0.2,'dtheta',0.01,'ddtheta',1),...
            struct('R',0.2,'accel',0.2,'dtheta',0.01,'ddtheta',0.05),...
            struct('R',0.2,'accel',0.2,'dtheta',0.01,'ddtheta',0.03),...
            struct('R',0.2,'accel',0.2,'dtheta',0.01,'ddtheta',0.02),...
            struct('R',0.2,'accel',0.2,'dtheta',0.01,'ddtheta',0.01)}; %Dec 27


%put all values to loop over in cell arrays (WARNING currently only works for current multiple-value arrays)
PARAMS = struct('s',{0.6},...
                'c',{0.1},...
                'errmode',{'squared'},...
                'res',{RES},...
                'lb',{[-1 -0.2500 -pi/2]},...
                'ub',{[0 1.2500 pi/2]},...
                'sb',{[0.4000 0.4000 1.0472]},...
                'bias',{'zeros'});
            
% Call generate_runs
C_TRIALS = generate_runs(dynamics,PARAMS);
N_TRIALS = length(C_TRIALS);

%% GET DATA
% scan the filtered processed data directory
DIR = dir('../data/processed/filtered');
NAMES = {DIR.name};
filenames = {};
for ii = 1:length(NAMES)
    filestr = NAMES{ii};
    if length(filestr) > 4 && strcmp('.mat',filestr(end-3:end))
        filenames = [filenames;filestr];
    end
end

%NEW: in case that any files in data directory are missing, substitute
%appropriate cell values in filenames to NaN
if length(filenames) ~= 22
    datanums = zeros(1,length(filenames));
    for ii = 1:length(filenames)
        %assign numbers
        datanums(ii) = str2num(filenames{ii}(14:15));
    end
    newcell = cell(22,1);
    di = 0;
    for ii = 1:22
        if any(ii == datanums)
            di = di+1;
            cellstr = sprintf('filt_janelia_%d_(3_25_17)',datanums(di));
            newcell{ii} = cellstr;
        else
            newcell{ii} = nan;
        end
    end
    
    filenames = newcell;
end


%% Select which data to run and what ranges
% if 'all', run the entire set
% if 'skip', do not run
% otherwise, enter a range (like 1:427, etc.)
% SELECTED DATA (AS OF 9/1): 14, 15, 16, 18, 19, 22
ALLX = {'skip',...   (#01 - Aug '16, B row, 4 whiskers)
        'skip',...    (#02 - Aug '16, B row, 4 whiskers) 
        'skip',...   (#03 - Aug '16, B row, 4 whiskers)
        'skip',...   (#04 - Aug '16, B row, 4 whiskers)
        'skip',...   (#05 - Sep '16, B row, 3 whiskers)
        'skip',...   (#06 - Sep '16, B row, 3 whiskers)
        'skip',...   (#07 - Sep '16, B row, 3 whiskers)
        'skip',...    (#08 - Sep '16, B row, 3 whiskers) 
        'skip',...   (#09 - Sep '16, B row, 3 whiskers)
        'skip',...   (#10 - Sep '16, B row, 3 whiskers)
        'skip',...   (#11 - Mar '17, C row, 5 whiskers)
        'skip',...   (#12 - Mar '17, C row, 5 whiskers)
        'skip',...   (#13 - Mar '17, C row, 5 whiskers)
        'all',...   (#14 - Mar '17, C row, 5 whiskers) - use
        'all',...    (#15 - Mar '17, C row, 5 whiskers) - use
        'all',...   (#16 - Mar '17, C row, 5 whiskers) - use
        'skip',...   (#17 - Feb '18, C row, 5 whiskers)
        'skip',...   (#18 - Feb '18, C row, 5 whiskers) - use
        'skip',...    (#19 - Feb '18, C row, 5 whiskers) - use
        'skip',...   (#20 - Feb '18, C row, 5 whiskers)
        'skip',...   (#21 - Feb '18, C row, 5 whiskers)
        'skip',...   (#22 - Feb '18, C row, 5 whiskers) - use
        };
skips = strcmp(ALLX,'skip');

%% File setup
%batch directory! this is where everything will be stored
batchdir = '../output/trial_data/BATCH/'; 

    
%% LOOP!!!
nfiles = length(filenames);
files = 1:nfiles;
count = 0;
for file_i = files(~skips) %file_i is the index to loop over
    %count
    count = count+1;
    
    %output directory
    dirname = sprintf('BatchSet_%.2d',file_i);
    savedir = [batchdir,dirname];
    mkdir(savedir)
    
    for trial_i = 1:N_TRIALS %loop over constraint permutations
        %% load data
        %call load()
        loadstr = ['../data/processed/filtered/',filenames{file_i}];
        DATA_i = load(loadstr);

        %cut down the data to a manageble or target time range
        if strcmp(ALLX{file_i},'all')
            X = 1:size(DATA_i.angles,1); 
        else
            X = ALLX{file_i};
        end
        ANG_cut = DATA_i.angles(X,:);
        PTS_cut = DATA_i.points(:,:,X);

        %% get constraints struct C
        C = C_TRIALS(trial_i);
        
        %% omit whiskers based on trial number...
        %define dataset ranges
        dataset1 = 1:4;
        dataset2 = 5:10;
        dataset3 = 11:16;
        dataset4 = 17:22;
        
        % CURRENTLY THIS DOES NOTHING BUT I DONT WANT TO DELETE IT
        %apply omits to point data. Omits should be a 1D array.
        if any(file_i==dataset1)
            C.omit = []; %no omits
        elseif any(file_i==dataset2)
            C.omit = []; %no omits
        elseif any(file_i==dataset3)
            C.omit = []; %no omits - previously had omit
        elseif any(file_i==dataset4)
            C.omit = []; %no omits
        end
        
        %re-define data
        DATA.angles = ANG_cut;
        DATA.points = PTS_cut;

        %% MODE AND SETUP FOR BOTH OPTIMIZATIONS
        mode = 'line_1dof';     % 3 modes: 'line_3dof' , 'line_1dof', 'circular' (circular not yet implemented)
        animate = 0;            % generate animation?
        file = sprintf('D%.2d_C%.3d',file_i,trial_i); % file name
        
        %% Print and status log
        status = sprintf('~~~ RUNNING DATASET #%d (%d/%d) , CONSTRAINT SETTING %d/%d ~~~ \n',file_i,count,length(files(~skips)),trial_i,N_TRIALS);
        fprintf(status);
        %status log
        statdoc = fopen([batchdir,'slog.txt'],'a+');
        fprintf(statdoc,status);
        fclose(statdoc);
        
        %% Initialize trial struct and save location
        %initialize as dimensionless/empty, so TRIAL can be 1x1 or 2x1
        %depending on biasalg
        TRIAL = struct('traj',{},...
                        'error',{},...
                        'info',{},...
                        'mode',{},...
                        'constraints',{},...
                        's',{},...
                        'PTS_bio',{},...
                        'ANG_bio',{},...
                        'file',{},...
                        'overc',{},...
                        'abserrmean',{},...
                        'traj_w',{},...
                        'traj_m',{},...
                        'prot',{},...
                        'dataset_num',{},...
                        'constraint_num',{},...
                        'timer',{},...
                        'relax',{});
        file_trial = append('../output/trial_data/bias/one/',file);
        
        %% CONSTRAINT RELAXATION MODE?
        C.relax = 1;
        
        %% last-minute defaults
        C.ovrct = 3;
        %log dataset and constraint number...
        C.datasetnum = file_i;
        C.constraintnum = trial_i;
        
        %% RUN OPTIMIZATION #1
        fprintf('RUNNING OPTIMIZATION 1 \n');
        TRIAL(1) =  trajopt_v4(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s
        
        %% RUN OPTIMIZATION #2
        if biasalg 
            %calculate biases
            ypts = TRIAL(1).PTS_bio(2,:,1); 
            prot = traj2prot(TRIAL(1).traj,TRIAL(1).s,ypts); %prot is [T,N]
            error = prot2error(prot,TRIAL(1).ANG_bio,'sign','all');
            %rewrite bias
            C.bias = -mean(error);
            % Run Optimization
            fprintf('RUNNING OPTIMIZATION 2 \n');
            TRIAL(2) = trajopt(DATA,mode,file,animate,C); %TRIAL contains trajectory, error, mode, constraints, and s
        end
        
        %% Saving TRIAL
        saveto = [savedir,'/',file];
        save(saveto,'TRIAL');
        
        
    end %end constraint trial loop
end %end dataset loop

















