function [x_best, Fopt, exitflag, output] = run_ga_driver( ...
    fitnessfcn, LB_int, UB_int, intcon, step_sizes)
%RUN_GA_DRIVER GA configuration and execution used in hrs_main.m.
%
% Inputs:
%   fitnessfcn  - Objective-function handle taking scaled search variables;
%                 define the physical-variable conversion as in hrs_main.m
%   LB_int      - Lower bounds in the scaled search space
%   UB_int      - Upper bounds in the scaled search space
%   intcon      - Indices of integer-constrained variables
%   step_sizes  - Engineering discretization intervals
%
% Outputs:
%   x_best      - Best solution in physical units
%   Fopt        - Minimum objective value
%   exitflag    - GA termination flag
%   output      - GA diagnostic information
%
% No random seed was set in hrs_main.m. This driver likewise uses the
% current MATLAB random-number stream and does not prescribe a seed.

nvars = numel(LB_int);

assert(numel(UB_int) == nvars, ...
    'The lower- and upper-bound vectors must have the same length.');

assert(numel(step_sizes) == nvars, ...
    'The step-size vector must match the number of decision variables.');

poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool;
end

pop_size = 500;

options = optimoptions('ga', ...
    'PopulationSize', pop_size, ...
    'EliteCount', round(pop_size * 0.05), ...
    'CrossoverFraction', 0.8, ...
    'MaxGenerations', 150, ...
    'MaxStallGenerations', 30, ...
    'FunctionTolerance', 1e-8, ...
    'Display', 'iter', ...
    'PlotFcn', {@gaplotbestf, @gaplotbestindiv}, ...
    'UseParallel', true);

[x_best_int, Fopt, exitflag, output] = ga( ...
    fitnessfcn, nvars, [], [], [], [], ...
    LB_int, UB_int, [], intcon, options);

x_best = x_best_int .* step_sizes;

end

