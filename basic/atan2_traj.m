function [phi, dphi] = atan2_traj(x,y,dx,dy)

% This function is used to calculate an angle and its derivative
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

phi = atan2(y, x);
dphi = -y./(x.^2+y.^2).*dx + x./(x.^2+y.^2).*dy;