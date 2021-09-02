function TRIALS = generate_runs(dynamics,params)
% *** GENERATING MANY TRIALS ***
    % This function generates trials for batch experiments
    %
    % Takes Input1: dynamics: a 
    %       Input2: SDFDS
    % 
    % Returns TRIALS, a multidimensional struct of 
    %  
    
    %unpack values
    s_vals = [params.s];
    
    %% loop over parameters...
    ct = 0;
    for si = 1:length(s_vals) % iterate over s vals...
        for dyni = 1:length(dynamics) 
            %trial count
            ct = ct+1;
            
            %Assign looping values to struct
            TRIALS(ct).s = s_vals(si);
            TRIALS(ct).R = dynamics{dyni}.R;
            TRIALS(ct).accel = dynamics{dyni}.accel;
            TRIALS(ct).dtheta = dynamics{dyni}.dtheta;
            TRIALS(ct).ddtheta = dynamics{dyni}.ddtheta;
            
            %non-looping (as of 8/30) parameters
            TRIALS(ct).res = params.res;
            TRIALS(ct).c = params.c;
            TRIALS(ct).errmode = params.errmode;
            TRIALS(ct).lb = params.lb;
            TRIALS(ct).ub = params.ub;
            TRIALS(ct).sb = params.sb;
            TRIALS(ct).sb = params.sb;
            TRIALS(ct).bias = params.bias;
            
            %mandatory
            TRIALS(ct).objinfo = true;
            TRIALS(ct).thlim = true;
            
%             %print values
%             fprintf('---TRIAL %d--- \n',ct);
%             fprintf('s =  %f \n',s);
%             fprintf('dynamic constraint %d \n',dyni);
%             fprintf('R =  %f \n',R);
%             fprintf('accel =  %f \n',accel);
%             fprintf('dtheta =  %f \n',dtheta);
%             fprintf('ddtheta =  %f \n',ddtheta);
            
        end
    end
    


