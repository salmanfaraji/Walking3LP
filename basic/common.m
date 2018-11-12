function all = common(s1,s2)

% This function combines to structures together
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

if ischar(s1)
    s1 = load(s1);
    s1 = s1.log;
end

if ischar(s2)
    s2 = load(s2);
    s2 = s2.log;
end


all = [];
for i=1:size(s1,1)
    for j=1:size(s2,1)
        if isequal(s1(i,1),s2(j,1))
            all = [all; s1(i,1) s1(i,2:end) s2(j,2:end)];
        end
    end
end
[~,I] = sort(sum(all(:,2:end),2));
all = all(I,:);