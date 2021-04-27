function [opt, fval, graph] = opt1dof(obj,bounds,res,con)
% *** STUPID 1-DOF OPTIMIZER ***
%   simple stupid fucking optimizer fucking stupid can you believe this
%   shit is so easy just loop through the damn numbers i dont care how long
%   it takes i gotta go get published like come on just become a stupid
%   monkey and crunch those numbers i am a dunce
%   
%   Takes:    obj: objective function of one variable
%          bounds: [upper bound , lower bound] for the variable
%             res: resolution of the search
%             con: constraint function defined as for fmincon
%
%   Returns: opt: optimal variable
%           fval: function evaluated at that variable

    %% get values to loop over
    X = bounds(1):res:bounds(2);
    if X(end) ~= bounds(2)
        X = [X,bounds(2)];
    end

    %% debug
    g = '123';

    %% loop
    %initialize big values for function
    func = ones(size(X))*Inf;

    %loop
    for ii = 1:length(X) 

        %flurp
        x = X(ii);

%         %check constraints
%         if any(con(x)>0)
%             fails = g(con(x)>0);
%             for jj = 1:length(fails)
% %                 fprintf('did not meet constraint %c at x = %f \n',fails(jj),x);
%             end
%             continue %go to next loop if constraint fails
%         end

        %evaluate function
        func(ii) = obj(x);
    end

    %% find the minimum
    [fval,ind] = min(func);
%     fprintf('ind is,%f \n',ind);
    opt = X(ind);
    debug = 'here';
    
    %% output stuff to graph (debug)
    graph.x = X;
    graph.y = func;
    
end

