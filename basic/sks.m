function m = sks(x)

% This function calculates a skew-symmetric matrix
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

m(1,2) = -x(3);
m(1,3) = x(2);
m(2,3) = -x(1);
m(2,1) = x(3);
m(3,1) = -x(2);
m(3,2) = x(1);