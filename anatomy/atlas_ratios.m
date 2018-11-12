function r = atlas_ratios()

% This function produces 3lp-equivalent atlas properties
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

m = 90.62;
l = 1.66;

r.hand =      [(2.263)/m,                    0.5, 0.1860/l];
r.forearm =   [(2.148+0.981)/m,              0.1398/0.2460, 0.2460/l];
r.upperarm =  [(2.369+2.707+1.881)/m,        0.1921/0.3810, 0.3810/l];

r.foot =      [(1.634)/m,                    0.027/0.174, 0.1740/l, 0.077/l];
r.shank =     [(4.367+0.1)/m,                0.187/(0.187+0.235), (0.187+0.235)/l];
r.thigh =     [(0.5166+0.69+7.34)/m,         0.4956, (0.21+0.164+0.0187+0.031)/l];

r.trunk =     [(14.2529+1.92+0.55+18.484)/m, 0.467, (0.075+0.015+0.03+0.019+0.211+0.078)/l];
r.head =      [(1.4199)/m,                   0.2460/0.3093, 0.3093/l];

r.pelvis = 0.089/l;
r.M = m;
r.L = l;

