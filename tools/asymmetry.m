function asym = asymmetry(X, model)

% This function calculates the asymmetry of a given gait
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

back = [X(1:2)' 0]; 
middle = [X(3:4)' model.h1];
front = [X(9:10)' 0];
asym = atan2(middle(1)-back(1) ,middle(3)-back(3)) ...
     - atan2(front(1)-middle(1),middle(3)-front(3)) ...
     + 2*model.slope;