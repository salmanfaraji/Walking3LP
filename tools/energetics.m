function cost = energetics(X,log,model,f,initial_mass)

% This function estimates the metabolic power of a given gait
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

slope = - model.slope;
COS = cos(slope);
SIN = sin(slope);
ROT = [COS 0 SIN; 0 1 0; -SIN 0 COS];
log.Ankle2 = log.Ankle2 * ROT;
log.Ankle3 = log.Ankle3 * ROT;

param.mid_stance_angle = 8.4;
param.grav_ratio = 1;
param.ethaf = @(f) -0.0929  +  0.3916*f   -0.0906*f.^2;
param.etha = @(f) 0.25;
apex = max(max(log.Ankle2(:,3)),max(log.Ankle3(:,3)));
bottom = min(min(log.Ankle2(:,3)),min(log.Ankle3(:,3)));
param.foot_lift_height = apex - bottom;
cost.Efficiency = param.ethaf(f);

% WARNING
param.foot_lift_height = 0.16;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cost model
pelvis = log.X - log.X3 * (X(end)<0) - log.X2 * (X(end)>0);
dpelvis = log.dX;
DX = norm(pelvis(1,:)-pelvis(end,:));

% 3LP internal costs
cost_sig = @(x) sum(diff(x).*(diff(x)>0));
Ksagital = log.K(:,1);
Klateral = log.K(:,2);
Epot = log.com(:,3) * model.M * model.g;
Edrag = - log.F1(:,1) .* log.com(:,1);
cost.E3lp = cost_sig(Ksagital+Edrag+Epot) + cost_sig(Klateral);

% Velocity redirection cost
x_pelvis = sqrt( pelvis(1,1)^2 +  pelvis(1,2)^2 );
dx_pelvis = sqrt( dpelvis(1,1)^2 + dpelvis(1,2)^2 );
dz_pelvis = dx_pelvis * x_pelvis / model.h1;
cost.Evr = 0.5 * model.M * dz_pelvis^2;

% ground clearance cost
cost.Egc = model.m2 * model.g * model.h2/model.h1 * ...
         (param.foot_lift_height * 2);
   
% weight support cost, VAS muscle
actual_length = (pelvis(:,1).^2+model.h1^2).^0.5;
init_length = actual_length(1);
profile = param.mid_stance_angle/180*pi + ...
          acos(min(actual_length/init_length,1))*2*0;
cosB = model.h1./actual_length;
wmax = 12*8/6;
thigh_length = model.l_leg(1);
g = @(v) (v>0).* (0.07+2.5*v) + (v<=0).* (0.07-0.08*v);
phi = @(prof) g( [diff(prof)./diff(log.time); 0]/wmax );
integ = @(prof) sum( thigh_length * model.M * model.g * (1-model.rg) * ...
                     cosB .* sin(prof/2) .* phi(prof) * wmax) * ...
                     mean(diff(log.time));
cost.Ews = integ(profile);

% final calculation
cost.Total = (cost.E3lp + cost.Evr + cost.Egc)/cost.Efficiency + cost.Ews;
cost.Total = real(cost.Total);
cost.CoT = cost.Total/DX/initial_mass/model.g; 