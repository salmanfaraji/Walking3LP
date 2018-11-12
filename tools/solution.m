function X = solution(s,vdes,cop1,cop2)

% This function finds a numeric gait solution for 3LP
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% � All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

index = [1 5:6 9:10 19:25];
y = [-vdes*s.Tstep; ...
     0;0; ...
     0;0; ...
     s.drag; ...
     sin(s.model.theta); sin(s.model.slope); 1];

if nargin<3
    cop1 = 0;
    cop2 = s.cop_length;
end

mg = (s.model.m1+2*s.model.m2) * s.model.g * (1-s.model.rg);

tcop = - mg * cop1;
rtcop = - mg * (cop2-cop1);
y = [y; tcop;0;rtcop;0];
index = [index 13:14 17:18];

if ~isempty(s.step_width)
    index = [index 2];
    y = [y; s.step_width]; 
end

k = feval(s.R,s.H(0,s.Tstep));
rhs = zeros(size(k,1),1); 
X = rhs;
rhs = rhs - k(:,index) * y; 
k(:,index) = [];
x = k\rhs;

X(index) = y;
new_index = 1:25;
new_index(index) = 0;
new_index = find(new_index);
X(new_index) = x;


