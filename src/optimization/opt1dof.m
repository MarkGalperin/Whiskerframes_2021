function [opt, fval, graph] = opt1dof(obj,bounds,res,con)
% *** 1-DOF OPTIMIZER ***
%   Brute-force optimizer for the 1-DOF case
%   
%   Takes:    obj: objective function of one variable
%          bounds: [upper bound , lower bound] for the variable
%             res: resolution of the search
%             con: constraint function defined same as for fmincon
%
%   Returns: opt: optimal variable
%           fval: function evaluated at that variable

    %% get values to loop over
    X = bounds(1):res:bounds(2);
    if X(end) ~= bounds(2)
        X = [X,bounds(2)];
    end

    %% loop
    %initialize big values for function
    func = ones(size(X))*Inf;

    %loop
    for ii = 1:length(X) 

        %flurp
        x = X(ii);

        %check constraints
        if any(con(x)>0)
            %fails constraint test
            func(ii) = Inf;
        else
            %evaluate function
            [E,~] = obj(x);
            func(ii) = E;
        end
    end

    %% check for no minimum
    if all(isinf(func))
        %display overconstraint
        fprintf('OVER-CONSTRAINED \n');
        %send NaN to function to signal stay at the same position
        fval = NaN;
        opt = NaN;
    else
        %find the minimum and its location
        [fval,ind] = min(func);
        opt = X(ind);
    end
    
    debug = 'here';
    
    %% output stuff to graph (debug)
    graph.x = X;
    graph.y = func;
    
end

