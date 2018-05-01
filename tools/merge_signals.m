function log = merge_signals(log, int, X)

% This function increments a log structure with new time-samples
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

names = fieldnames(int);
for i=1:length(names)
    c = names{i};
    cc = names{i};
    if X(end)<0
        if strfind(cc,'2')>0
            cc = strrep(cc,'2','3');
        elseif strfind(cc,'3')>0
            cc = strrep(cc,'3','2');
        end
    end
    if isfield(log,cc)
        log.(cc) = [log.(cc); int.(c)];
    else
        log.(cc) = int.(c);
    end
end

