function TRIALS = generate_runs_grid(PARAMS,CONSTANT)
% *** GENERATING MANY TRIALS ***
    % This function generates trials for batch experiments, varying
    % constraint and s values in a grid. This is different from
    % generate_runs, which takes a pre-determined list of constraint
    % values. Here the constraint values are entered with the params struct
    % and all combinations are considered. 
    %
    % Takes params: struct of values to loop over. Each value is a labeled
    % field. params should also contain a field 'CONSTANT' which contains a
    % struct of all other values that should be added to the trials.
    % 
    % returns TRIALS, a multidimensional struct of constraints to run over
    
    %% get struct info
    fnames = fieldnames(PARAMS);
    cnames = fieldnames(CONSTANT);
    Nf = length(fnames); %number of fields in total
    
    %% loop over struct to get field indices...
    fieldvals = cell(1,Nf);
    for fi = 1:Nf
        field = fnames{fi};
        fieldvals{fi} = PARAMS.(field);
    end
    
    %% build up all the index combinations sequentially using combvec
    comb = fieldvals{1}; %initialize combination
    for ii = 2:length(fieldvals)
        comb = combvec(comb,fieldvals{ii});
    end
    
    %% Finally, generate the constraint struct
    for c = 1:size(comb,2)
        for n = 1:size(comb,1)
            %set variable constraint value
            TRIALS(c).(fnames{n}) = comb(n,c);
        end
        %add in all constant values
        for ci = 1:length(cnames)
            const = cnames{ci};
            TRIALS(c).(const) = CONSTANT.(const);
        end
        
        %mandatory
        TRIALS(c).objinfo = true;
        TRIALS(c).thlim = true;
        
    end
    
    

%     for si = 1:length(s_vals) % iterate over s vals...
%         for dyni = 1:length(dynamics) 
%             %trial count
%             ct = ct+1;
%             
%             %Assign looping values to struct
%             TRIALS(ct).s = s_vals(si);
%             TRIALS(ct).R = dynamics{dyni}.R;
%             TRIALS(ct).accel = dynamics{dyni}.accel;
%             TRIALS(ct).dtheta = dynamics{dyni}.dtheta;
%             TRIALS(ct).ddtheta = dynamics{dyni}.ddtheta;
%             
%             %non-looping (as of 8/30) parameters
%             TRIALS(ct).res = params.res;
%             TRIALS(ct).c = params.c;
%             TRIALS(ct).errmode = params.errmode;
%             TRIALS(ct).lb = params.lb;
%             TRIALS(ct).ub = params.ub;
%             TRIALS(ct).sb = params.sb;
%             TRIALS(ct).sb = params.sb;
%             TRIALS(ct).bias = params.bias;
%             
%             %mandatory
%             TRIALS(ct).objinfo = true;
%             TRIALS(ct).thlim = true;
%             
% %             %print values
% %             fprintf('---TRIAL %d--- \n',ct);
% %             fprintf('s =  %f \n',s);
% %             fprintf('dynamic constraint %d \n',dyni);
% %             fprintf('R =  %f \n',R);
% %             fprintf('accel =  %f \n',accel);
% %             fprintf('dtheta =  %f \n',dtheta);
% %             fprintf('ddtheta =  %f \n',ddtheta);
%             
%         end
%     end
    


