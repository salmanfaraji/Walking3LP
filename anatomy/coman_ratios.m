function r = coman_ratios()

% This function produces 3lp-equivalent coman properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

m = 28.5;
l = 1;

r.hand =      [(0)/m, 0.3495, 0.1028];
r.forearm =   [(1.04)/m, 0.4257, 0.1531];
r.upperarm =  [(0.77+0.57+0.88)/m, 0.5087, 0.1600];

r.foot =      [(0.66+0.72)/m, 0.4633, 0.1470, 0.0451];
r.shank =     [(1.4)/m, 0.4165, 0.2522];
r.thigh =     [(0.89+1.02+1.7)/m, 0.4033, 0.2269];

r.trunk =     [(6.36+0.54+0.75)/m, 0.4630, 0.3495];
r.head =      [(0)/m, 0.4555, 0.1396];

r.pelvis = 0.0636;
r.M = m;
r.L = l;