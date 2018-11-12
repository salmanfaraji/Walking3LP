function asym = asymmetry(X, scenario)

% This function calculates the asymmetry of a given gait
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

X = scenario.H(0, scenario.Tds/2) * X;

foot_length = scenario.model.l_leg(3);
out = vis_maple_DS(X,scenario,0);
back = out.X2 + [foot_length/2 0 0];
middle = out.X;
front = out.X3 + [foot_length/2 0 0];
asym = atan2(back(1) -middle(1), middle(3)-back(3) ) ...
     + atan2(front(1)-middle(1), middle(3)-front(3));