function normalized = normalize(arr1D)
    % *** MAP ARRAY TO [0,1] ***
    % Takes arr1D: one-dimensional array of any length
    % 
    % Returns normalized: linear mapping of input to range [0,1]
    
    %% get max and min values
    amax = max(arr1D);
    amin = min(arr1D);
    range = amax - amin;
    
    %% shift and scale array to map between 0 and 1
    shifted = arr1D - amin;
    normalized = shifted/range;
    
end

