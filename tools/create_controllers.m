function s = create_controllers(s, Qx, Qr)

% This function creates DLQR and time-projeciton controllers for walking
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

s.cont = struct();
s.cont.input = [11 12 15 16];
s.cont.Ch = zeros(2,8);
s.cont.Ch(1:2,5:6) = eye(2);
s.cont.H0 = s.H(0,s.Tstep);
s.cont.Q = Qx;
s.cont.R = Qr;

s.cont.A = s.M * s.T * s.cont.H0 * s.S;
s.cont.B = s.M * s.T * s.cont.H0(:, s.cont.input);

s.cont.YY = @(X,Y) (1+X(end))/2*Y + (1-X(end))/2*s.T*s.cont.H0*Y;
s.cont.error = @(Y,X,Ht) s.M * X - s.M * Ht * s.cont.YY(X,Y);
s.cont.error_disc = @(Y,X) s.M * X - s.M * s.cont.YY(X,Y);

[disc_feedback, cont_feedback, empty_feedback, s.control_data] = ...
    time_projection(s.cont.A,s.cont.B,s.cont.Q,s.cont.R,s.cont.Ch);

s.cont.disc_feedback = @(Y,X,X0,Ht,HTt,s) ...
    disc_feedback(s.M * X - s.M * Ht * s.cont.YY(X,Y), ...
                  s.M * X0 - s.M * s.cont.YY(X0,Y), ...
                  s.M * s.T * HTt * s.S, ...
                  s.M * s.T * HTt(:, s.cont.input));

s.cont.cont_feedback = @(Y,X,X0,Ht,HTt,s) ...
    cont_feedback(s.M * X - s.M * Ht * s.cont.YY(X,Y), ...
                  s.M * X0 - s.M * s.cont.YY(X0,Y), ...
                  s.M * s.T * HTt * s.S, ...
                  s.M * s.T * HTt(:, s.cont.input));

s.cont.empty_feedback = @(Y,X,X0,Ht,HTt,s) ...
    empty_feedback(s.M * X - s.M * Ht * s.cont.YY(X,Y), ...
                  s.M * X0 - s.M * s.cont.YY(X0,Y), ...
                  s.M * s.T * HTt * s.S, ...
                  s.M * s.T * HTt(:, s.cont.input));
              
s.feedback = s.cont.disc_feedback;