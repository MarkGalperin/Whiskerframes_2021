function [base2,tip2,other] = searchframe_kinematic(base1,tip1)
    % *** TITLE OF THE THING ***
    % Takes Input1: sdfhjksdf
    %       Input2: kljfsdljds
    % 
    % Returns Output1: dslkfjsdlkj
    %         Output2: dfkhsdkjfhs
    
    %% initialize
    T = size(base1,3);
    N = size(base1,2);
    G = zeros(3,3,T);
    other.B = zeros(2,T);
    P = zeros(size(base1));
    
    %% calculate best fit and transformations for each timeframe
    %do deming regression for all timeframes
    fprintf('performing searchframe calcs... \n');
    for t = 1:T
        fprintf('%d/%d \n',t,T);
        %perform regression
        x = transpose(base1(1,:,t));
        y = transpose(base1(2,:,t));
        other.B(:,t) = deming(y,x);
        
        %project points onto the line
        for n = 1:N   
            %calculate projection
            pt = [base1(1,n)-other.B(1);base1(2,n)];
            u = [other.B(2);1];
            pt_proj = (dot(pt,u)/dot(u,u))*u;
            pt_proj(1) = pt_proj(1)+ other.B(1);
            %store points...
            P(1:2,n,t) = pt_proj;
        end
        
        %bottom projected basepoint for use as new origin
        xb = P(:,N,t);
        
        %scaling distance, the distance between projected basepoints 1 and N
        d_vec = P(:,N,t) - P(:,1,t);
        d = norm(d_vec);
        
        %generate transform 
        slope_ang = atan(other.B(2)) - pi;
        Scale = [1/d 0 0 ; 0 1/d 0 ; 0 0 1];
        Translate = get_SE2(slope_ang,0)*get_SE2(0,-xb);
        G(:,:,t) = Scale*Translate;
        
    end
    fprintf('finished \n');
    
    %% apply transform
    base2 = pagemtimes(G,base1);
    tip2 = pagemtimes(G,tip1);
    
    %% get angles
    ang = zeros(T,N);
    for t = 1:T
        for n = 1:N %for each whisker
            u = tip2(:,n,t) - base2(:,n,t);
            ang(t,n) = atan2(u(2),u(1));
        end
    end
    %slip angle into "other"
    other.ang = ang;
    
    %% slip other stuff into "other"
    other.P = P;
    
end

