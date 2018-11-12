function r = leg_ratios()

% This function produces 3lp-equivalent leg-only robot properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

a = 0.99*(0.0062+0.0160+0.0271+0.4795+0.0744)/2;

r.hand =      [0.0062*0.01, 0.3495, 0.1028];
r.forearm =   [0.0160*0.01, 0.4257, 0.1531];
r.upperarm =  [0.0271*0.01, 0.5087, 0.1600];

r.foot =      [0.0141*(1+a/(0.0444+0.1148)), 0.4633, 0.1470, 0.0451];
r.shank =     [0.0444*(1+a/(0.0141+0.1148)), 0.4165, 0.2522];
r.thigh =     [0.1148*(1+a/(0.0141+0.0444)), 0.4033, 0.2269];

r.trunk =     [0.4795*0.01, 0.4630, 0.0100];
r.head =      [0.0744*0.01, 0.4555, 0.0100];

r.pelvis = 0.06;
r.M = 70;
r.L = 0.8911 + 0.02;