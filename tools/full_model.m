function s = full_model(model, Tss, Tds)

% This function creates a 3LP model + gait parameters
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

s = struct();
s.model = model;
s.dim = 25;
s.Tss = Tss;
s.Tds = Tds;
s.Tstep = Tss+Tds;
s.DS = get_maple_DS(s);
s.SS = get_maple_SS(s);
s.step_width = [];
s.cop_length = model.l_leg(3);
s.clearance = 0.05;

s.HSS = @(now,T) real(    (s.SS.Ur1+s.SS.Vr1*now) ...
                        + (s.SS.Ur2+s.SS.Vr2*now) * exp(s.SS.w(1) * T) ...
                        + (s.SS.Ur3+s.SS.Vr3*now) * exp(s.SS.w(2) * T) ...
                        + (s.SS.Ur4+s.SS.Vr4*now) * exp(s.SS.w(3) * T) ...
                        + (s.SS.Ur5+s.SS.Vr5*now) * exp(s.SS.w(4) * T) ...
                        + (s.SS.Ur6+s.SS.Vr6*now) * T);
s.HDS = @(now,T) real(    (s.DS.Ur1+s.DS.Vr1*now) ...
                        + (s.DS.Ur2+s.DS.Vr2*now) * exp(s.DS.w(1) * T) ...
                        + (s.DS.Ur3+s.DS.Vr3*now) * exp(s.DS.w(2) * T) ...
                        + (s.DS.Ur4+s.DS.Vr4*now) * exp(s.DS.w(3) * T) ...
                        + (s.DS.Ur5+s.DS.Vr5*now) * exp(s.DS.w(4) * T) ...
                        + (s.DS.Ur6+s.DS.Vr6*now) * T);

if Tds~=0
    s.H = @(time,dt) ((time+dt>Tds)     * s.HSS(max(time-Tds,0),dt+min(time-Tds,0)) + ...
                      (time+dt<=s.Tds)  * eye(s.dim)) * ...
                     ((time<Tds)        * s.HDS(time,min(dt,s.Tds-time)) + ...
                      (time>=s.Tds)     * eye(s.dim));
else
    s.H = @(time,dt) s.HSS(time,dt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transition matrix
s.T = zeros(s.dim,s.dim);
s.T(1,9) = 1;
s.T(2,10) = 1;
s.T(3,3) = 1;
s.T(4,4) = 1;
s.T(5,5) = 1;
s.T(6,6) = 1;
s.T(7,7) = 1;
s.T(8,8) = 1;
s.T(9,1) = 1;
s.T(10,2) = 1;
s.T(11,11) = 1;
s.T(12,12) = -1;
s.T(13,13) = 1;
s.T(14,14) = -1;
s.T(15,15) = 1;
s.T(16,16) = -1;
s.T(17,17) = 1;
s.T(18,18) = -1;
s.T(19,19) = 1;
s.T(20,20) = 1;
s.T(21,21) = 1;
s.T(22,22) = 1;
s.T(23,23) = 1;
s.T(24,24) = 1;
s.T(25,25) = -1;

% symmetry extraction
s.M = zeros(8,s.dim);
s.M(1:2,1:2) = -eye(2);
s.M(1:2,3:4) = eye(2);
s.M(3:4,9:10) = -eye(2);
s.M(3:4,3:4) = eye(2);
s.M(5:6,5:6) = eye(2);
s.M(7:8,7:8) = eye(2);

% symmetry distribution
s.S = zeros(s.dim,8);
s.S(1:2,1:2) = -eye(2); %CoM-Sw
s.S(1:2,3:4) = eye(2); %CoM-St
s.S(3:4,3:4) = eye(2); %CoM-St
s.S(5:6,5:6) = eye(2); %dCoM
s.S(7:8,7:8) = eye(2); %dfoot

s.O = diag([1 -1 1 -1 0 0 1 -1]);
s.R = @(H) - s.O * s.M + s.M * s.T * H;

