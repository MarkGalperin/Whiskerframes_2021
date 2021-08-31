function [opt, fval] = opt3dof(obj,lb,ub,res,con)
% *** 3-DOF OPTIMIZER ***
%   Brute-force optimizer for the 3-DOF case. x is (1x3)
%   
%   Takes:    obj: objective function of one variable
%              lb: lower bound for x
%              ub: upper bound for x
%             res: resolution of the search (same dim as x)
%             con: constraint function defined same as for fmincon
%
%   Returns: opt: optimal variable
%           fval: function evaluated at that variable

    %% get values to loop over
    X = lb(1):res(1):ub(1);
    Y = lb(2):res(2):ub(2);
    Z = lb(3):res(3):ub(3);
    
    %check that the end is the max value
    if X(end) ~= ub(1)
        X = [X,ub(1)];
    end
    if Y(end) ~= ub(2)
        Y = [Y,ub(2)];
    end
    if Z(end) ~= ub(3)
        Z = [Z,ub(3)];
    end

    %% error check string
    g = '123456';

    %% loop
    %initialize big values for function
    func = ones(length(X),length(Y),length(Z))*Inf;

    %loop
    for ii = 1:length(X) 
        for jj = 1:length(Y)
            for kk = 1:length(Z) %lowest-level for loop
                %flurp
                x = [X(ii),Y(jj),Z(kk)];

                %check constraints
                if any(con(x)>0)
%                     fails = g(con(x)>0);
%                     for jj = 1:length(fails)
%                         fprintf('did not meet constraint %c at x = %f \n',fails(jj),x);
%                     end
                    func(ii,jj,kk) = Inf;
                else
                    %evaluate function
                    [E,~] = obj(x);
                    func(ii,jj,kk) = E;
                end
            end
        end
    end

    %% check for no minimum and return NaN
    if all(isinf(func))
        fprintf('OVER-CONSTRAINED \n')
        %send NaN to function to signal to stay at same position
        fval = NaN; %
        opt = NaN; %
    else
        %% find the minimum and its location
        [fval,loc] = min(func(:));
        [mi,mj,mk] = ind2sub(size(func),loc);
        opt = [X(mi),Y(mj),Z(mk)];
    end

end

