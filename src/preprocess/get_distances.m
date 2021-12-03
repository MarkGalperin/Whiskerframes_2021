function D = get_distances(A,B)
%GET_DISTANCES Given two arrays of measurements, return an array of all
%distances between combinations of those measurements.
%   Takes:
%   Returns:

    %initialize
    D = zeros(size(A,1),size(B,1));

    %loop over arrays
    for ii = 1:size(A,1)
        for jj = 1:size(B,1)
            a = A(ii,:);
            b = B(jj,:);
            
            %calculate distances
            D(ii,jj) = norm(b-a);
        end
    end

end

