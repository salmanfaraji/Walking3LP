function options = options_3LP()

% This function creates 3LP simulation default options
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

options = struct();
options.resolution = 100; % time steps to simulate
options.ifplot = 0;
options.iftorques = 0;
options.ifforces = 0;
options.real_time = 1;
options.iflog = 0;
options.ifvideo = 0;
options.ifoverlay = 0;
options.if3lp = 1;
options.iftreadmill = 0;
options.videoname = 'test.avi';
options.view = '3d'; % 3d, back, side

options.vdes = [1 1];
options.dist_pattern = zeros(1,7);
options.dist_strength = [0 0 0 0];