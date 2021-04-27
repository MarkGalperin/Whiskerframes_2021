function [base2,tip2,other] = preprocess_dlc_bestrot(base,tip)
    % *** TITLE OF THE THING ***
    % Takes Input1: sdfhjksdf
    %       Input2: kljfsdljds
    % 
    % Returns Output1: dslkfjsdlkj
    %         Output2: dfkhsdkjfhs
    %% intialize
    N = size(base,2); %num whiskers
    T = size(base,3); %num frames
    res = 1; %search resolution
    bestrot = ones(3,N,T);
    
    %% loop over each whisker
    for ii = 1 % 1:N
        %define region - BRING THIS INTO THE TIME LOOP?
        x_r = (base(1,ii,1)-100):res:(base(1,ii,1)+100);
        y_r = (base(2,ii,1)-100):res:(base(2,ii,1)+100);
        D = zeros(length(x_r),length(y_r));
        D_t = zeros(length(x_r),length(y_r));
        %% loop over each time step
        for t = 1:T 
            fprintf('whisker %d t = %d... \n',ii,t)
            a = base(1:2,ii,t); % a is the base point
            n = tip(1:2,ii,t) - a; % n is the direction vector between the pts
            %% iterate through region and find distances...
            for iii = 1:length(x_r)
                for jjj = 1:length(y_r)
                    x = x_r(iii); 
                    y = y_r(jjj);
                    
                    %calculate cross-product, distance
                    cp = cross([(a-[x;y]);0],[n;0]);
                    d = norm(cp)/norm(n);
                    
                    %log distance
                    D_t(iii,jjj) = d;
                end
            end
            %% add to totals
            D = D + D_t;
        end
        %% find best point
            [dmin,ind] = min(D,[],'all','linear');
            [xind,yind]=ind2sub(size(D),ind);
            bestrot(1:2,ii,t) = [x_r(xind);y_r(yind)];
    end
    %% export bestpoint as "other" struct for plotting
    other.bestrot = bestrot;
    
    %% return base and tip points
    base2 = base;
    tip2 = tip;
end

