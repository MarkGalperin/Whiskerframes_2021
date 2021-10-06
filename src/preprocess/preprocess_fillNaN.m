function [ANG_inp,X_inp,Y_inp] = preprocess_fillNaN(ANG,X,Y)
% *** Data Preprocess (HELPER) - Fill NaN values ***
% Fills gaps in tracking data (labeled as NaN) with interpolated values.
% Used inside pp1_janelia(). 
%
% Takes ANG: [TxN] array of angle value with respect to whisker
%         X: [TxN] array of pixel X value with respect to whisker
%         Y: [TxN] array of pixel X value with respect to whisker
% 
% Returns ANG_inp, X_inp, Y_inp: input data with NaN gaps filled.

%initialize interpolated arrays and check for NaN locations (should be the same for ang, x, and y)
ANG_inp = ANG;
X_inp = X;
Y_inp = Y;
NaNs = isnan(ANG);

for n = 1:size(NaNs,2) %iterate over columns (whiskers)
    %edge case 1: first row is NaN
    t = 1;
    if NaNs(1,n) 
        while NaNs(t,n)
            if NaNs(t+1,n)
                t = t+1; %advance
            else
                endi = t+1;
                %set all values in column to first non-NaN value
                ANG_inp(1:endi,n) = ANG(endi,n);
                X_inp(1:endi,n) = X(endi,n);
                Y_inp(1:endi,n) = Y(endi,n);

                break
            end
        end
    end

    %edge case 2: last row is NaN
    if NaNs(end,n)
        t = size(NaNs,1); %set that last thing
        while NaNs(t,n)
            if NaNs(t-1,n)
                t = t-1; %advance back
            else
                endi = t-1;
                %set all values in column to first non-NaN value
                ANG_inp(endi:end,n) = ANG(endi,n);
                X_inp(endi:end,n) = X(endi,n);
                Y_inp(endi:end,n) = Y(endi,n);                                              
                break
            end
        end
    end

    %debug: what are the NaNs right here at this point?
    what = {ANG_inp,X_inp,Y_inp};
    whatnan = {isnan(ANG_inp),isnan(X_inp),isnan(Y_inp)};

    %begin search - assuming no NaN in first or last rows now
    t = 2;
    while t<size(NaNs,1)
        if NaNs(t,n) && ~NaNs(t-1,n)
            starti = t-1; %mark the value before the first NaN 
            while NaNs(t,n) && t<size(NaNs,1)
                if NaNs(t+1,n)
                    t = t+1; %advance
                else
                    endi = t+1; %mark the value after the last NaN
                    %calculate interpolated values
                    ang_fill = linspace(ANG(starti,n),ANG(endi,n),1+(endi-starti));
                    x_fill = linspace(X(starti,n),X(endi,n),1+(endi-starti));
                    y_fill = linspace(Y(starti,n),Y(endi,n),1+(endi-starti));
                    %fill in the values
                    ANG_inp(starti:endi,n) = ang_fill;
                    X_inp(starti:endi,n) = x_fill;
                    Y_inp(starti:endi,n) = y_fill;

                    if isnan(ANG(starti,n))
                        fprintf('STARTI IS NAN');
                    elseif isnan(ANG(endi,n))
                        fprintf('ENDI IS NAN');
                    end
                    %advance
                    t = t+1;
                    break
                end
            end
        else
            t = t+1; %advance
        end
    end
end

%check remaining NaN
if any(isnan(ANG_inp(:)))
    fprintf('(!!!!) NaN remaining in ANG \n');
end
if any(isnan(X_inp(:)))
    fprintf('(!!!!) NaN remaining in X \n');
end
if any(isnan(Y_inp(:)))
    fprintf('(!!!!) NaN remaining in Y \n');
end

end



