function r = nao_ratios()

% This function produces 3lp-equivalent nao properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

m = 5.3;
l = 0.57;

r.hand =      [0.01/m, 0.5, 0.001/l];
r.forearm =   [0.26/m, 0.51, 0.15/l];
r.upperarm =  [0.22/m, 0.4, 0.1/l];

r.foot =      [0.17/m, 0.6, 0.1/l, 0.05/l];
r.shank =     [0.43/m, 0.62, 0.105/l];
r.thigh =     [0.53/m, 0.4, 0.1/l];

r.trunk =     [1.37/m, 0.67, 0.184/l];
r.head =      [0.68/m, 0.54, 0.13/l];

r.pelvis = 0.05/l;
r.M = m;
r.L = l;