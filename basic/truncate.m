function y = truncate(x,a)

% This function truncates a value to an upper or lower limit
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

y = x;
a = abs(a);
if x>a
    y = a;
elseif x<-a
    y = -a;
end
    