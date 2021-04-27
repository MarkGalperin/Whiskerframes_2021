function SE2 = get_SE2(R_th,p)
% Takes R_th: Either a single-valued angle (theta) or a rotation matrix in
% SE(2)
%        p: planar translation vector where p(1) = x, p(2) = y
% Returns SE2: a 3x3 matrix
%
% This is my function I'm using to generate homogenous transform matrices
% and clean up a lot of my code. "SE(2)" refers to a 3x3 matrix in the
% special euclidean group, which encode the rotation and translation of
% coordinate frames, operating on homogenous coordinates in R^3. 

%% Read the input
%construct the R (2x2) matrix from single-valued R_th = theta
if size(R_th) == [1,1]
    R = [[cos(R_th);sin(R_th)],[-sin(R_th);cos(R_th)],[0;0]];
end
%from 2x2 R_th = R...
if size(R_th) == [2,2]
    R = R_th;
end

%if p = "0"
if p == 0
    p = [0 0 1];
end

SE2 = [[R(1,1);R(2,1);0],[R(1,2);R(2,2);0],[p(1);p(2);1]];