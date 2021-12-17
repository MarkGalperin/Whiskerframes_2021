function [Errs,Prot,Dang] = newobj(S,Cstr,bio_pts,bio_ang)
% NEWOBJ New objective constraint based on candidate-set model
% 
% Takes:
%   S: candidate set of configurations 
%   Cstr: constraints structure (can't be called C due to a different vector I'm using here)
%   bio_pts: (1xN) vector of biological y-points 
%   bio_ang: (1xN) vector of biological output angles

    %% For all pts, calculate error
    % initialize
    N = size(bio_pts,2); %number of whiskers
    Nc = size(S,1); %number of candidate points in feasible set
    Errs = zeros(Nc,N);
    Prot = zeros(Nc,N);
    Dang = zeros(Nc,N);

    s = Cstr.s;
    % w vector
    w1 = s*sin(S(:,3));
    w2 = 1 - s*cos(S(:,3));
    
    %loop over whiskers
    for n = 1:N
        %get projected y-value of whisker point
        y = bio_pts(2,n); 
        
        %calculate protraction (this is P = atan(u2/u1). It's written this
        %way to save on memory and not define new variables)
        P = atan((w2*y - S(:,2))./(w1*y - S(:,1))) + Cstr.bias(n);
        
        %calculate error
        d_ang = P-bio_ang(n); 
        switch Cstr.errmode
            case 'abs'
                err = abs(d_ang);
            case 'squared'
                err = (d_ang).^2;
            case '4'
                err = (d_ang).^4;
        end
        %log into arrays
        Errs(:,n) = err;
        Prot(:,n) = P;
        Dang(:,n) = d_ang;
    end    
end

%% How this script used to look before memory stuff
%     %% For all pts, calculate error
%     % initialize
%     N = size(bio_pts,2); %number of whiskers
%     Nc = size(S,1); %number of candidate points in feasible set
%     Errs = zeros(Nc,N);
%     Prot = zeros(Nc,N);
%     Dang = zeros(Nc,N);
% 
%     s = Cstr.s;
%     % w vector
%     w1 = s*sin(S(:,3));
%     w2 = 1 - s*cos(S(:,3));
%     
%     %loop over whiskers
%     for n = 1:N
%         %get projected y-value of whisker point
%         y = bio_pts(2,n); 
%         
%         %calculate protraction (this is P = atan(u2/u1). It's written this
%         %way to save on memory and not define new variables)
%         P = atan((w2*y - S(:,2))./(w1*y - S(:,1))) + Cstr.bias(n);
%         
%         %calculate error
%         d_ang = P-bio_ang(n); 
%         switch Cstr.errmode
%             case 'abs'
%                 err = abs(d_ang);
%             case 'squared'
%                 err = (d_ang).^2;
%             case '4'
%                 err = (d_ang).^4;
%         end
%         %log into arrays
%         Errs(:,n) = err;
%         Prot(:,n) = P;
%         Dang(:,n) = d_ang;
%     end    

