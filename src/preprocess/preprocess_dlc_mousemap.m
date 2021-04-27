function [base2,tip2,other] = preprocess_dlc_mousemap(base1,tip1,mousepoints)
    % *** TITLE OF THE THING ***
    % Takes Input1: mousedata points
    % 
    % Returns base2: dslkfjsdlkj
    %         tip2: dfkhsdkjfhs
    %% Get info from inputs
    T = size(base1,3);
    N = size(base1,2);
    
    %% Output: repeated mousemap points (static)
    %REVERSE ORDER OF POINTS TO WORK W/ DEEPLABCUT ORDERING
    mouse_rev = mousepoints; % actually i switched it back 4/21/21
    base2 = repmat(mouse_rev,1,1,T);
    
    %% Output: atan2 angles from deeplabcut offset by a constant
    %constant offset angle 
    other.off = 20*(pi/180); %[rad]
    
    %init
    angles = zeros(T,N);
    tip2 = ones(3,N,T);
    m = 0.25; %vector length
    
    %loop over time and whiskers
    for t = 1:T
        for n = 1:N
            %get difference vector
            v = tip1(1:2,n,t)-base1(1:2,n,t);
            %atan2 angle
            a = atan2(v(2),v(1)) - pi/2 - other.off;
            %calculate tip2
            tip2(1:2,n,t) = [base2(1,n,t) + m*cos(a);base2(2,n,t) + m*sin(a)];
            %save the angle
            angles(t,n) = a;
            
        end
    end
    
    
    
    %% Save other
    other.ang_mse = angles;
    
end

