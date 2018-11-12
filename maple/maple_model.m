% This function loads parameters from the model data structure
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

m1 = scenario.model.m1;
m2 = scenario.model.m2;
g  = scenario.model.g;
h1 = scenario.model.h1;
h2 = scenario.model.h2;
h3 = scenario.model.h3;
h4 = scenario.model.h4;
h5 = scenario.model.h5;
I2 = scenario.model.I2;
I3 = scenario.model.I3;
rg = scenario.model.rg;
pw = scenario.model.pw;
cos_theta = cos(scenario.model.theta);
cos_slope = cos(scenario.model.slope);

Tds = scenario.Tds;
Tss = scenario.Tss;
