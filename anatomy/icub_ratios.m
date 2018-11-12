function r = icub_ratios()

% This function produces 3lp-equivalent icub properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

m = 27.6;
l = 1.05;

r.hand =      [0.213/m, 0.5, 0.1/l];
r.forearm =   [0.52/m, 0.47, 0.133/l];
r.upperarm =  [1.32/m, 0.49, 0.1523/l];

r.foot =      [0.6/m, 0.1667, 0.13/l, 0.06/l];
r.shank =     [2.28/m, 0.76, 0.21/l];
r.thigh =     [3.455/m, 0.45, 0.22/l];

r.trunk =     [9.53/m, 0.59, 0.2953/l];
r.head =      [1.34/m, 0.77, 0.2247/l];

r.pelvis = 0.068/l;
r.M = m;
r.L = l;