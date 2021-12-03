%% ADDING STUFF IN POST TO RESULT .MAT FILES
% This is a last-minute script fixing some of the useful info that should
% have been assigned in the batch optimizations, but I'm just adding them
% in post to avoid re-running.
clear;
clc;
clf;


%% add to path
addpath('../src');
addpath('../src/figures');
addpath('../src/optimization');

%% Which overwrites are we running?
% true = perform this overwrite, false = don't
do_filename     = 1;
do_coordchanges = 1;
do_prot         = 1;
do_datasetnum   = 1;

DO =  [do_filename,...
       do_coordchanges,...
       do_prot,...
       do_datasetnum]; %add as needed

%% LOAD DATA
% choose batch directory
batch_dir = '../output/trial_data/BATCH_oct12to16/'; %make sure to end with "/"
SETS = batch_load(batch_dir);


%% LOOP OVER DATA TO LOG RESULTS AND MAKE FIGURES
for set_i = 1:length(SETS)
    
    %new: get dataset number and files
    dset = SETS{set_i}(1).TRIAL.file(2:3); %get the dataset number as a strin
    dir_names = {dir([batch_dir,'BatchSet_',dset]).name};
    dir_names = {dir_names{3:end}};
    
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
            

            %% overwrite name to what was written manually in directory
            if DO(1)
                %new: change filename in case it was changed manually in directory
                dir_name = dir_names{trial_i}(1:end-4);
                trial_name = trial.TRIAL(opt).file;
                if ~strcmp(dir_name,trial_name)
                    %change trial file name to what's in dir_names
                    trial.TRIAL(opt).file = dir_name;
                    fprintf('changed "%s" to "%s" \n',trial_name,dir_name);
                end
            end
        
            %% Calculate and save coordinate changes
            if DO(2)
                %calculate p1 p2
                traj_w = coordchange(trial.TRIAL(opt).traj,trial.TRIAL(opt).s,'rp');
                trial.TRIAL(opt).traj_w = traj_w;

                %calculate m1 m2
                traj_m = coordchange(trial.TRIAL(opt).traj,trial.TRIAL(opt).s,'rm');
                trial.TRIAL(opt).traj_m = traj_m;
            end 
            
            %% Calculate out the mechanical protractions
            if DO(3)
                %get protraction and save
                prot = permute(trial.TRIAL(opt).info(1,:,:),[3 2 1]);
                trial.TRIAL(opt).prot = prot;
                
            end
            
            %% Dataset number
            if DO(4)
                %get dataset number and save
                dset = str2num(trial.TRIAL(opt).file(2:3));
                trial.TRIAL(opt).dataset_num = dset;
                  
            end
            
%%%%%%%%%%%%%%%%%%%%%%%% LOOP THRU RUNS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        end %end loop through optimization numbers
        
        %% OVERWRITE OPTIMIZATION
        
        % get save directory
        dset = trial.TRIAL(1).file(2:3);
        savedir = [batch_dir,'BatchSet_',dset,'/overwrites/'];
        mkdir(savedir);
        
        %get file name
        file = trial.TRIAL.file;
        
        %save
        saveto = [savedir,file];
        TRIAL = trial;
        save(saveto,'TRIAL');
        
    end %end loop through runs
   
      
end %end loop through sets





