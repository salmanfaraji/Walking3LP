function [disc_feedback, cont_feedback, empty_feedback, data] = ...
         time_projection(A,B,Qx,Qr,Ch)

% This function contains basic implementation of time-projeciton
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

% conversion to Y=SX space, which separates constraints
P = size(Ch,1);
N = size(A,2);
M = size(B,2);
Cp = null([zeros(N-P, N); Ch])';
S = [Cp; Ch];
Qy = inv(S)' * Qx * inv(S);
Ry = Qr;
Ny = zeros(size(A,2),size(B,2));
Ay = S * A * pinv(S);
By = S * B;

% decompose matrices to blocks which takes last P components for constraint
[iQvv, ~   , ~   , ~   ] = extract_corner(Qy,P);
[iRvv, iRvw, iRwv, iRww] = extract_corner(Ry,P);
[iAvv, ~   , iAwv, ~   ] = extract_corner(Ay,P);
[iBvv, iBvw, iBwv, iBww] = extract_corner(By,P);

% U = [V; W] and Y = [Y_v; Y_w] where W and Y_w = 0 have size P
% the last P components of U is: W = iG * Y_v + iH * V
iG = - pinv(iBww) * iAwv;
iH = - pinv(iBww) * iBwv;

% then W is removed from the equaitons and cost matrices
if P>0
    Qy = iQvv + iG' * iRww * iG;
    Ry = iRvv + iH' * iRww * iH + iRvw * iH + iH' * iRwv;
    Ny = iG' * iRww * iH + iG' * iRww' * iH' + iG' * iRvw' +  iG' * iRwv;
    Ay = iAvv + iBvw * iG;
    By = iBvv + iBvw * iH;
end

% this LQR is now for the system of Y_v and V
[data.K,~,data.E] = dlqr(Ay,By,Qy,Ry,Ny);
K = data.K;

% discrete LQR controller
disc_feedback = @(X,X0,AH,BH) disc(X,X0,AH,BH);
function U = disc(X,X0,AH,BH)
    [G, H, ~, ~] = remove_cons(AH, BH);
    V = - K * Cp * X0;
    W = [];
    if P>0
        W = G*S*X + H*V;
    end
    U = [V; W];
end

% time projecting controller
cont_feedback = @(X,X0,AH,BH) cont(X,AH,BH);
function U = cont(X,AH,BH)
    [G, H, AH, BH] = remove_cons(AH, BH);
    Yend = AH * S * X;
    V = -K * pinv(Ay - (By - BH) * K) * Yend(1:(N-P));
    W = [];
    if P>0
        W = G*S*X + H*V;
    end
    U =  [V; W];
end

% empty controller
empty_feedback = @(X,X0,AH,BH) empty(X,AH,BH);
function U = empty(X,AH,BH)
    [G, H, ~, ~] = remove_cons(AH, BH);
    V = zeros(M-P,1);
    W = [];
    if P>0
        W = G*S*X + H*V;
    end
    U = [V; W];
end

function [G, H, AH, BH] = remove_cons(AH, BH)
    AH = S*AH*pinv(S);
    BH = S*BH;
    [Avv, Avw, Awv, Aww] = extract_corner(AH,P);
    [Bvv, Bvw, Bwv, Bww] = extract_corner(BH,P);
    G = - pinv(Bww) * [Awv Aww];
    H = - pinv(Bww) * Bwv;
    if P>0
        AH = [Avv Avw] + Bvw * G;
        BH = Bvv + Bvw * H;
    end
end

function [Xvv, Xvw, Xwv, Xww] = extract_corner(X,P)
    if(P>0)
        M = size(X,2);
        N = size(X,1);
        Xvv = X( 1:(N-P) , 1:(M-P));
        Xww = X((N-P+1):N, (M-P+1):M);
        Xvw = X( 1:(N-P) , (M-P+1):M);
        Xwv = X((N-P+1):N, 1:(M-P));
    else
        Xvv = X;
        Xvw = [];
        Xwv = [];
        Xww = [];
    end
end

end