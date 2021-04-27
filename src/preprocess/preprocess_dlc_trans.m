function [base2,tip2] = preprocess_dlc_trans(base,tip)
    % *** TITLE OF THE THING ***
    % Takes Input1: sdfhjksdf
    %       Input2: kljfsdljds
    % 
    % Returns Output1: dslkfjsdlkj
    %         Output2: dfkhsdkjfhs
    
    %% make a transform
    % flip about both axes
    T = size(base,3);
    R = [[-1;0;0],[0;-1;0],[0;0;1]];
    Rt = repmat(R,1,1,T);
    
    %% apply transform
    base2 = pagemtimes(Rt,base);
    tip2 = pagemtimes(Rt,tip);

    
end

