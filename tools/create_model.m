function s = create_model(model, Tds, Tstep)

% This function creates a 3LP model + walking gait solution
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

subindex = @(A,r,c) A(r,c);
if nargin < 3
    s = full_model(model, 1.2-Tds, Tds);
    handle = @(t) min(svd(subindex(feval(s.R,s.H(0,t)),[1 3 5 7],[1 3 7])));
    [Tstep,~] = fminsearch(handle,0.9, optimset('TolFun',1e-12));
end
s = full_model(model, Tstep-Tds, Tds);
s.drag = zeros(4,1);

s.create_gait = @(sce,type) create_gait(sce,type);
function sol = create_gait(sce,type)
    sol = @(vdes) solution(sce, vdes, type);
end

end