%% UNPACKING, EDITING, AND TABULATING RESULTS FROM BATCH TRIALS
% should generate a folder of csv files with results
clear;
clc;
clf;


%% add to path
addpath('../src');
addpath('../src/figures');
addpath('../src/optimization');

%% Which analyses are we running?
% true = perform this analysis, false = don't
run_writeresults = 1;
run_makefigures = 1;
run_correlations = 0;
run_trackoc = 0;

RUN = [run_writeresults,...
       run_makefigures,...
       run_correlations,...
       run_trackoc]; %add as needed

%% LOAD DATA
% choose batch directory
batch_dir = '../output/trial_data/BATCH/'; %make sure to end with "/"
SETS = batch_load(batch_dir);

%% MAKE RESULTS DIRECTORY
results_dir = [batch_dir,'results/'];
mkdir(results_dir);

%% MAKE FIGURES DIRECTORY
figures_dir = [batch_dir,'figures/'];
mkdir(figures_dir);

%initialize overconstraint analysis array and big trajectory collection
traj_oc = {[],[],[]};
traj_all = {[],[],[]};

%% LOOP OVER DATA TO LOG RESULTS AND MAKE FIGURES
for set_i = 1:length(SETS)
    
    %new: get dataset number and files
    dset = SETS{set_i}(1).TRIAL.file(2:3); %get the dataset number as a strin
    dir_names = {dir([batch_dir,'BatchSet_',dset]).name};
    dir_names = {dir_names{3:end}};
    
    %initialize table
    set_tbl = array2table(zeros(0,14));
    set_tbl.Properties.VariableNames = {'Trial','O1_Error','O2_Error','s','dx','ddx','dth','ddth','overc_cnt','c','errmode','res_1','res_2','res_3'};
    
    
    %get set and loop over trials
    set = SETS{set_i};
    for trial_i = 1:length(set)
        trial = set(trial_i);
        
        %determine whether this is a single optimization or double (bias
        %algorithm) optimization
        if length(trial) == 1
            Nopt = 1;
        else
            Nopt = length(trial);
        end
        
        %ITERATE OVER OPTIMIZATIONS
        for opt = 1:Nopt
            
%%%%%%%%%%%%%%%%%%%%%%%% LOOP THRU RUNS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            
            %new: change filename in case it was changed manually in directory
            dir_name = dir_names{trial_i}(1:end-4);
            trial_name = trial.TRIAL(opt).file;
            if ~strcmp(dir_name,trial_name)
                %change trial file name to what's in dir_names
                trial.TRIAL(opt).file = dir_name;
                fprintf('changed "%s" to "%s" \n',trial_name,dir_name);
            end
        
            %construct table row as struct
            newrow = struct('Trial',trial_i,...
                            'O1_Error',mean(trial.TRIAL(1).abserrmean),...
                            'O2_Error',mean(trial.TRIAL(opt).abserrmean),... 
                            's',trial.TRIAL(1).s,...
                            'dx',trial.TRIAL(1).constraints.R,...
                            'ddx',trial.TRIAL(1).constraints.accel,...
                            'dth',trial.TRIAL(1).constraints.dtheta,...
                            'ddth',trial.TRIAL(1).constraints.ddtheta,...
                            'overc_cnt',sum(trial.TRIAL(opt).overc),...
                            'c',trial.TRIAL(1).constraints.c,...
                            'errmode',trial.TRIAL(1).constraints.errmode,...
                            'res_1',trial.TRIAL(1).constraints.res(1),...
                            'res_2',trial.TRIAL(1).constraints.res(2),...
                            'res_3',trial.TRIAL(1).constraints.res(3));
            %append row
            set_tbl = [set_tbl;struct2table(newrow)];

            %debug
%             if trial_i == 2
%                 debug = 'here';
%             end
            
            if RUN(2)
                %% MAKE FIGURES FOR OPTIMIZATIONS
                file = '500_r1r2'; %figure batch directory name
                
                %file setup
                filepath = [figures_dir,file,'/',trial.TRIAL(opt).file(2:3),'/',sprintf('OPT%d',opt)];
                %make directory
                mkdir(filepath)

                %open trial and get stuff
                if isfield(trial,'TRIAL') 
                    TRIAL = trial.TRIAL(opt);
                end
                PTS = TRIAL.PTS_bio;
                ANG = TRIAL.ANG_bio;
                ypts = PTS(2,:,1); %assuming these are constant (MSE data)
                traj = TRIAL.traj; %[T,N]
                prot = traj2prot(traj,TRIAL.s,ypts); %prot is [T,N]
                info = TRIAL.info;
                info_prot = permute(info(1,:,:),[3 2 1]);
                info_bio = permute(info(2,:,:),[3 2 1]);
                info_derror = permute(info(3,:,:),[3 2 1]);
                error = permute(info(4,:,:),[3 2 1]);


                %configuration plot
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
                %show overconstraint events
                S.overc = {true,'-r'};

                %range
                X = 1:500; %1:size(prot,1);

                %Generate plot
                conf_plots = plot_config(S,TRIAL,X);
                %Save plot 
                conf_file = [file,'_',TRIAL.file,'_conf'];
                conf_path = filepath;
                saveas(conf_plots, fullfile(conf_path, conf_file), 'png');
                clf;

                % comparison plot
                %generate plot
                N = size(ANG,2);
                ploterror = true;
                comp_plots = plot_whiskercomp(TRIAL,X);

                %save plot
                comp_file = [file,'_',TRIAL.file,'_comp']; 
                comp_path = filepath; 
                saveas(comp_plots, fullfile(comp_path, comp_file), 'png');
                clf;     
            
            end %end figures


            %% Correlations
            if RUN(3)

            end %end run correlations
            
            %% Analyze overconstraint events (over all runs)
            if RUN(4)
                %find locations of overconstraint 
                oc_locs = logical(trial.TRIAL(opt).overc);
                %add to big list of trajectory values at overconstraint...
                traj_oc{set_i} = [traj_oc{set_i};trial.TRIAL(opt).traj(oc_locs,:)];
                
                %also build a massive list of trajectories from each run...
                traj_all{set_i} = [traj_all{set_i};trial.TRIAL(opt).traj];
                
%                 debug = here;
            end %end add field values
            
%%%%%%%%%%%%%%%%%%%%%%%% LOOP THRU RUNS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        end %end loop through optimization numbers
    end %end loop through sets
    
    if RUN(1)
        %% save trial as csv
        %csv filename and save        
        csvfile = [batch_dir,'results/',set(1).TRIAL(1).file(2:3),'.csv'];
        writetable(set_tbl,csvfile,'Delimiter',',')
    end
      
end

%% plotting
plot_oc = true;
if RUN(4) && plot_oc
    for ii = 1:length(traj_oc)
        %plot the stuff
        figure(ii)
        	hold on
            plot3(traj_all{ii}(:,1),traj_all{ii}(:,2),traj_all{ii}(:,3),'-k')
            plot3(traj_oc{ii}(:,1),traj_oc{ii}(:,2),traj_oc{ii}(:,3),'o','MarkerFaceColor','green');
    end
end

%% say ur done
fprintf('done \n');


