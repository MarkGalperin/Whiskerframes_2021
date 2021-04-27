function [TRIALS,constraints] = generate_runs(s_vals,R_vals,dtheta_vals)
% *** GENERATING MANY TRIALS ***
    % This function takes the biological datasets and produces arrays of
    % points for inputting into the search experiment.
    %
    % Takes Input1: DJKFHDS
    %       Input2: SDFDS
    % 
    % Returns   DSFSDF
    %

    %% generating the trials map
    %building constraint structs in a "Map" container
    TRIALS = containers.Map('KeyType','char','ValueType','any');
    constraints = {};
    
    c = 0;
    for s = s_vals
        for R = R_vals
            for dth = dtheta_vals
                %make string
                c = c+1;
                constr = append('const',num2str(c,'%03d'));

                %append to constraints cell
                constraints{end+1} = constr;

                %make struct
                C.c = 0.1;
                C.R = R;
                C.dtheta = dth;
                C.s = s;

                %add to map
                TRIALS(constr) = C;
            end
        end
    end
end

