function TRIALS = batch_load(batch_dir)
% *** LOAD BATCH TRIALS ***
%   Opens up batch results from batch trials
%   
%   Takes:   batch_dir: path to the batch file
%
%   Returns: TRIALS: cell array of structs with all the trial data

    %% scan directory
    BATCHDIR = dir(batch_dir);
    BATCHNAMES = {BATCHDIR.name};
    trialnames = {};
    for ii = 1:length(BATCHNAMES)
        filestr = BATCHNAMES{ii};
        if length(filestr) > 8 && strcmp('BatchSet_',filestr(1:9))
            trialnames = [trialnames;filestr];
        end
    end

    %% Write Trial info to Tables
    %initialize cell array
    TRIALS = {};
    %loop
    for ii = 1:length(trialnames)
        %trial path
        trialname = trialnames{ii};
        trial_dir = [batch_dir,trialname,'/'];
        %scan trial directory
        TRIALDIR = dir(trial_dir);
        run_names = {TRIALDIR.name};
        runs = {}; %cell list of stuff
        for jj = 1:length(run_names)
            file = run_names{jj};
            if length(file) > 4 && strcmp('.mat',file(end-3:end))
                runs = [runs;file];
            end
        end
        %now loop over runs
        for jj = 1:length(runs)
            run = runs{jj};
            %load data
            run_path = [trial_dir,run];
            run_load = load(run_path);
            %save to big struct
            RUNS(jj) = run_load;
        end
        % build cell array
        TRIALS = [TRIALS,RUNS];
    end


end