function Fig = plot_errors(mode,T,s,dth,R,path,tspan)
% *** ERRORS COMPARISON PLOT ***
% Summary of this function goes here
%   Detailed explanation goes here
    
    %% timespan control
    %data length
    errvec = load([path,T(1,:).file_name{1},'.mat']).error;
    S = length(errvec);
    if isempty(tspan)
        t_ind = (1:S);
    else
        t_ind = tspan(1):tspan(2);
    end
    
    %% mode switches
    if strcmp(mode,'s')
        % select values
        select_s = round(T.dtheta,4) == dth & T.R == R;

        % index table
        s_table = T(select_s,:);
        s_files = s_table.file_name;
        
        %init
        label = {};
        
        hold on
        for ii = 1:length(s_files)
            %get relevant data
            file = s_files{ii};
            data = load([path,file,'.mat']);
            %make label
            label{ii} = sprintf('s = %f',data.s);
            %get error
            error = data.error(t_ind);
            t = t_ind;
            %plot the error
            plot(t,error)
        end
        hold off
        
    elseif strcmp(mode,'dth')
        % select values
        select_dth = T.s == s & T.R == R;

        % index table
        dth_table = T(select_dth,:);
        dth_files = dth_table.file_name;
        
        %init
        label = {};
        
        hold on
        for ii = 1:length(dth_files)
            %get relevant data
            file = dth_files{ii};
            data = load([path,file,'.mat']);
            %make label
            label{ii} = sprintf('dtheta = %f',data.constraints.dtheta);
            %get error
            error = data.error(t_ind);
            t = t_ind;
            %plot the error
            plot(t,error)
        end
        hold off
    elseif strcmp(mode,'R')
        % select values
        select_R = round(T.dtheta,4) == dth & T.s == s;

        % index table
        R_table = T(select_R,:);
        R_files = R_table.file_name;
        
        %init
        label = {};
        
        hold on
        for ii = 1:length(R_files)
            %get relevant data
            file = R_files{ii};
            data = load([path,file,'.mat']);
            %make label
            label{ii} = sprintf('s = %f',data.constraints.R);
            %get error
            error = data.error(t_ind);
            t = t_ind;
            %plot the error
            plot(t,error)
        end
    end
    hold off


    
    %% format plot
    legend(label);
    hold off
    
    %% return figure
    Fig = gcf;
end
