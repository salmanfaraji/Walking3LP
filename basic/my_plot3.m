function h = my_plot3(ax,X,c,linewidth)

% This function plots a matrix in 3D
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

if nargin<3
    linewidth = 1;
end
h = plot3(ax,X(:,1), X(:,2), X(:,3), c, 'LineWidth', linewidth);