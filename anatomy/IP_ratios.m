function r = IP_ratios()

% This function produces 3lp-equivalent inverted pendulum properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

r.hand =      [1e-3  0.3495  0.1028];
r.forearm =   [1e-3  0.4275  0.1531];
r.upperarm =  [1e-3  0.5087  0.1600];
r.foot =      [1e-3  0.4633  0.1470, 0.0451];
r.shank =     [1e-3  0.4165, 0.2522];
r.thigh =     [0.05  1e-1    0.2269];
r.trunk =     [0.9   1-1e-3, 0.3495];
r.head =      [1e-3  0.4555, 0.1396];
r.pelvis = 0.0636;
