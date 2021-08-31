%% BATCH TRIALS 
% Running through permutations of parameters
clear;
clc;

%% Including code
addpath('../src');
addpath('../src/deming');
addpath('../src/optimization');

%% Batch trial settings
biasalg = true;             %run bias algorithm, which performs two optimizations
RES = [0.01, 0.01, 0.002];  %Set Resolution (warning, this effects running time exponentially)

%% DEFINE PARAMETERS
%define a cell datatype with the three dynamic constraint modes
dynamics = {struct('R',10,'accel',10,'dtheta',pi/2,'ddtheta',10),...    %mode 1: no constraint
            struct('R',1,'accel',0.1,'dtheta',pi/2,'ddtheta',0.05),...  %mode 2: high vel constraint med accel constraint
            struct('R',1,'accel',0.5,'dtheta',pi/2,'ddtheta',0.01)};    %mode 3: high vel constraint tight accel constraint

%put all values to loop over in cell arrays (WARNING currently only works for current multiple-value arrays)
PARAMS = struct('s',{0.3,0.45,0.6,0.75,0.9},...
                'c',{0.1},...
                'errmode',{'squared'},...
                'res',{RES},...
                'lb',{[-1 -0.2500 -1.0472]},...
                'ub',{[0 1.2500 1.0472]},...
                'sb',{[0.2000 0.2000 1.0472]},...
                'bias',{'zeros'});
            
% Call generate_runs
C_TRIALS = generate_runs(dynamics,PARAMS);

%% GET DATA














