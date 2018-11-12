function r = IP_ratios()

% This function produces 3lp-equivalent inverted pendulum properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

l = 0.5242 * 1/0.92;

r.hand =      [1e-3  0.3495  0.1028/l];
r.forearm =   [1e-3  0.4275  0.1531/l];
r.upperarm =  [1e-3  0.5087  0.1600/l];

r.foot =      [1e-3  0.4633  0.1470/l, 0.0451/l];
r.shank =     [1e-3  0.4165, 0.2522/l];
r.thigh =     [0.05  1e-1    0.2269/l];

r.trunk =     [0.9   1-1e-3, 0.0100/l];
r.head =      [1e-3  0.4555, 0.0100/l];

r.pelvis = 0.01;
r.M = 70;
r.L = 0.8911 + 0.02;
