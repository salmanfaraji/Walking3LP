function X = solution(s,vdes,type)

% This function finds a numeric gait solution for 3LP
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

index = [1 5:6 9:10 19:25];
y = [-vdes*s.Tstep; ...
     0;0; ...
     0;0; ...
     s.drag; ...
     sin(s.model.theta); sin(s.model.slope); 1];

if type==1
    mg = (s.model.m1+2*s.model.m2) * s.model.g * (1-s.model.rg);
    tcop = - mg * (-s.cop_length/2 + abs(s.cop_length)/2);
    alpha = abs(s.cop_length)/s.model.l_leg(3);
    center = (s.model.metatarsal*(1-alpha)+s.model.l_leg(3)*alpha)/2;
    tcop = - mg * (-s.cop_length/2 + center);
    rtcop = - mg * s.cop_length;
    y = [y; tcop;0;rtcop;0];
    index = [index 13:14 17:18];
end

if type==2
    index = [index 8];
    y = [y; 0];
end

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


