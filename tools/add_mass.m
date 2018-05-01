function model = add_mass(model,m,u,index)

% This function adds mass to a 3LP model
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

% in this file we update main parameters used by 3LP
% index = 1 : r.hand =      [(0.0060 + 0.0065 + 0.0061)/3  (0.506 + 0.1802 + 0.3624)/3  (188 + 170)/2/1741];
% index = 2 : r.forearm =   [(0.0160 + 0.0161 + 0.0160)/3  (0.430 + 0.3896 + 0.4574)/3  (269 + 264)/2/1741];
% index = 3 : r.upperarm =  [(0.0280 + 0.0263 + 0.0270)/3  (0.436 + 0.5130 + 0.5772)/3  (282 + 275)/2/1741];
% index = 4 : r.foot =      [(0.0145 + 0.0147 + 0.0130)/3  (0.500 + 0.4485 + 0.4415)/3  (258 + 228)/2/1741 (60 + 97)/2/1741];
% index = 5 : r.shank =     [(0.0465 + 0.0435 + 0.0433)/3  (0.433 + 0.3705 + 0.4459)/3  (440 + 438)/2/1741];
% index = 6 : r.thigh =     [(0.1000 + 0.1027 + 0.1416)/3  (0.433 + 0.3719 + 0.4050)/3  (422 + 368)/2/1741];
% index = 7 : r.trunk =     [(0.4970 + 0.5070 + 0.4346)/3  (0.495 + 0.3803 + 0.5138)/3  (603 + 614)/2/1741];
% index = 8 : r.head =      [(0.0810 + 0.0728 + 0.0694)/3  (0.500 + 0.4642 + 0.4024)/3  (243 + 243)/2/1741];

M = model.M;
Dm = [2*m 2*m 2*m 2*m 2*m 2*m m m];
C = {'hand' 'forearm' 'upperarm' 'foot' 'shank' 'thigh' 'trunk' 'head'};
M_new = M + Dm(index);

for i=1:8
    f = model.(char(C(i)));
    g = f*0+1; 
    g(1:2) = 0;
    if i==index
        model.(char(C(i))) = f*diag(g) + [(f(1)*M+m)/M_new ...
                                          (f(1)*M*f(2)+m*u)/(f(1)*M+m) ... 
                                          zeros(1,length(f)-2)];
    else
        model.(char(C(i))) = f*diag(g) + [f(1)*M/M_new ...
                                          f(2) ... 
                                          zeros(1,length(f)-2)];
    end
end

model = model_geom(M_new, model.L, model); 
