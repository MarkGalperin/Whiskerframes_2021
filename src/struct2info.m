function info_log = struct2info(Tstruct)
% *** TRAJ2PROT ***
% Trajectory to protraction: takes trajectory data and returns
% protraction (output) of the whisker frames system.
%
% Takes Tsruct: trial struct with all relevant stuff in it
% 
% Returns info: [4xNxT] array of low-level information. Each "page" for
% time = 1:T has the following items by row:
%     protraction angles
%     biological angles
%     delta_angle = protraction - biological
%     error: errmode operation performed on delta_angle (absm squared, etc.)

    %% unpack Tstruct
    traj = Tstruct.traj;
    ANG = Tstruct.ANG_bio;
    PTS = Tstruct.PTS_bio;
    mode = Tstruct.mode;
    C = Tstruct.constraints;
    s = Tstruct.s;
    T = size(ANG,1);
    N = size(ANG,2);
    
    %% construct info just like in trajopt
    info_log = zeros(4,N,T);
    for t = 1:T
        
        % GET BIO DATA
        bio_pts = PTS(:,:,t); %
        bio_ang = ANG(t,:);
        
        
        switch mode
            case 'line_3dof' %3DOF OPTIMIZER
                
                %% Get configuration at time t
                x = traj(t,:);
                
                %% get info!
                %define function handles
                objective = @(x) optimization_obj_line(x,s,bio_pts,bio_ang,C);
                
                %get info and log it
                [~,info] = objective(x);
                info_log(:,:,t) = info;
%             case 'line_1dof' %1DOF OPTIMIZER
%                 thisis = 'not_implemented';
        end
    end
    

end