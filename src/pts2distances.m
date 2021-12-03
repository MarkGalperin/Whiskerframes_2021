function distances = pts2distances(pts)
%% getting relative distances from the points in video data 
% Takes... 
%   pts: [3xNxT] array containing N column vectors of [x,y,1], for T
%   timesteps
%
% Returns...
%   distances: averaged respective distances between adjacent whiskers

    %% loop over the array
    T = size(pts,3);
    N = size(pts,2);
    distances_log = zeros(T,N-1);
    for t = 1:T
        %get pixel values
        pix = pts(:,:,t);
        
        %get differences
        dpix = diff(pix(1:2,:),1,2);
        
        %get distances at time t
        dist = vecnorm(dpix,2,1);
        
        %log distances
        distances(t,:) = dist;
    end
end

