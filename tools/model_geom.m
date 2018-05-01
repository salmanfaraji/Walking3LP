function s = model_geom(M,L,s,theta,slope)

% This function creates a pure 3LP model with matrices
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

if nargin<5
    s.slope = 0;
else
    s.slope = slope;
end
if nargin<4
    s.theta = 0;
else
    s.theta = theta;
end

s.k = 0;
s.rg = 0;

s.L = L;
s.M = M;
s.g = 9.81;

s.m1 = M * (s.head(1)+s.trunk(1)+2*(s.hand(1)+s.forearm(1)+s.upperarm(1)));
s.m2 = M * (s.foot(1)+s.shank(1)+s.thigh(1));


s.h1 = L*(s.foot(4)+s.shank(3)+s.thigh(3));
s.h2 = L*(s.thigh(1) * (s.thigh(3)*s.thigh(2)) + ...
          s.shank(1) * (s.thigh(3)+s.shank(3)*s.shank(2)) + ...
          s.foot(1)  * (s.thigh(3)+s.shank(3)+s.foot(4)*s.foot(2)) )/ ...
         (s.thigh(1)+s.shank(1)+s.foot(1));% bug in foot
s.h3 = L*(s.trunk(1) *    (s.trunk(3)*(1-s.trunk(2))) + ...
          s.head(1) *     (s.trunk(3)+s.head(3)*(1-s.head(2))) + ...
       2* s.upperarm(1) * (s.trunk(3)-s.upperarm(3)*s.upperarm(2)) + ...
       2* s.forearm(1) *  (s.trunk(3)-s.upperarm(3)-s.forearm(3)*s.forearm(2)) + ...
       2* s.hand(1) *     (s.trunk(3)-s.upperarm(3)-s.forearm(3)-s.hand(3)*s.hand(2)) )/ ...
         (s.trunk(1)+s.head(1)+2*(s.upperarm(1)+s.forearm(1)+s.hand(1))); 
s.h4 = s.h3;
s.h5 = L*(s.trunk(3)+s.head(3));

s.m_leg = [s.thigh(1) s.shank(1) s.foot(1)]*M;
s.u_leg = [s.thigh(2) ...
           s.shank(2) *s.shank(3)/(s.shank(3)+s.foot(4)) ...
           s.foot(2)];
s.l_leg = [s.thigh(3) s.shank(3) s.foot(3) s.foot(4)]*L;
s.pw = s.pelvis * L;
s.metatarsal = s.l_leg(3) * 15/25;

% calculate inertia for the leg
m1 = s.thigh(1)*M;
m2 = s.shank(1)*M;
m3 = s.foot(1)*M;
l1 = s.thigh(3)*L;
l2 = s.shank(3)*L;
l3 = s.foot(4)*L;
u1 = s.thigh(2);
u2 = s.shank(2);
u3 = s.foot(2);
h1 = l1*u1;
h2 = l1+l2*u2;
h3 = l1+l2+l3*u3;
z = (m1*h1+m2*h2+m3*h3)/(m1+m2+m3);

% approximate by cylinders
s.I2 = 1/12*(m1*l1^2+m2*l2^2+m3*l3^2) + m1*(z-h1)^2 + m2*(z-h2)^2 + m3*(z-h3)^2;
s.I3 = s.I2;




