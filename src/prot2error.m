function err = prot2error(prot,ANG,mode,returns)
%     *** get error from trajectory and bio pts ***
%     This function takes a trajectory and s to calculate the error over
%     the entire trajectory
%     
%     Takes prot: [TxN] array of whisker protractions (radians), generated
%                   using the function traj2prot 
%           mode: 'abs' or 'sqared' to calculate absolute value error or
%                   squared error
%           returns: 'all','sum',or 'avg' to return a (TxN) of individual
%                   errors, a (Tx1) array of mean errors with respect to
%                   the row, or a single number average of all mean error
%                   values.
%     Returns err: output with format specified by return


    %% calculate error
    switch mode
        case 'sign'
            ERR = prot-ANG;
        case 'abs'
            ERR = abs(prot-ANG);
        case 'squared'
            ERR = (prot-ANG).^2;
    end

    %% return
    switch returns
        case 'all'
            err = ERR;
        case 'sum'
            err = mean(ERR,2);
        case 'avg'
            err = mean(mean(ERR,2));
    end

end