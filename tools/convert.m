function [outGeom, outInfo] = convert(int,s,time)

% This function converts 3LP states to human-like postures
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% model parameter
model = s.model;
l = model.h1;           % overal leg length
l1 = model.l_leg(1);    % thigh
l2 = model.l_leg(2);    % shank
l5 = model.metatarsal;  % foot length
l4 = model.l_leg(4);    % ankle height
l3 = sqrt(l5^2+l4^2);   % ankle to metatarsal
lmod = l1+l2;           % thigh + shank
phi = model.slope;      % slope angle (rad)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transitions
coeff3 = @(t1,t3) [t1^3 t1^2 t1 1; ...
                   t3^3 t3^2 t3 1; ...
                   3*t1^2 2*t1 1 0; ...
                   3*t3^2 2*t3 1 0];          
t1 = s.Tds;
t3 = s.Tds + s.Tss;
abc = coeff3(t1,t3)\[-s.Tds;0;-1;-1];
alpha_t = [time^3 time^2 time^1 1]*abc;
alpha_t = (time<=s.Tds) * (-time) + (time>s.Tds)*alpha_t;

if time < s.Tds
    t1 = 0;
    t3 = s.Tds;
    abc = coeff3(t1,t3)\[0;-s.Tds*2;-1;-2];   
    beta_t = [time^3 time^2 time^1 1]*abc;
else
    t1 = s.Tds;
    t3 = s.Tds+s.Tss;
    abc = coeff3(t1,t3)\[-s.Tds*2;0;-2;-1];
    beta_t = [time^3 time^2 time^1 1]*abc;
end

t1 = s.Tds;
t3 = s.Tds + s.Tss;
abc = coeff3(t1,t3)\[0;1;0;0];
gamma_t = [time^3 time^2 time^1 1]*abc;
gamma_t = (time>=t1) * gamma_t;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% core trajectories
P2 = int.X2;
P3 = int.X3;
X = int.X;
WW = int.x2 - int.X;
dX = int.dX;
q = P2(1:2)-int.x2(1:2);
p = P3(1:2)-int.x3(1:2);
dp = -dX(1:2);
distance = l5/2 * truncate((p(1)-q(1))/l,1);
qcop = [ distance+l5/2 0];
pcop = [-distance+l5/2 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pelvis height

% fixed strategy
zpfixed = height_fixed(p(1)+alpha_t*dp(1), p(2)+alpha_t*dp(2), pcop(1)) + l4;
zqfixed = height_fixed(q(1)+alpha_t*dp(1), q(2)+alpha_t*dp(2), qcop(1)) + l4;
zfixed = (1-gamma_t) * zpfixed + gamma_t * zqfixed;

% adaptive strategy
zmax = lmod + l4;
zpadapt = height_adaptive(p(1)+alpha_t*dp(1), p(2)+alpha_t*dp(2), pcop(1)-l5/2) + l4;
zqadapt = height_adaptive(q(1)+alpha_t*dp(1), q(2)+alpha_t*dp(2), qcop(1)-l5/2) + l4;
zadapt = real(zmax - smoothmax(zmax-zpadapt,zmax-zqadapt,0));

% re-orientation
zpelvis = zadapt;
delta = - l*cos(phi) + zpelvis;
zpelvis = max(l*0.5, zpelvis);
outGeom.Pelvis = [X(1)+delta*sin(phi) X(2) zpelvis];
outGeom.Hip2       = outGeom.Pelvis + WW;
outGeom.Hip3       = outGeom.Pelvis - WW; 
outGeom.Shoulder   = outGeom.Pelvis + (int.X1 - int.X) * model.trunk(3)/(model.trunk(3)+model.head(3)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% leg trajectories

up = p + alpha_t*dp + pcop;
uq = q + beta_t *dp + qcop;

alp =  sin( max(0,(time-s.Tds)/s.Tss) * pi);
lift = alp * s.clearance * l;
outGeom.Toe2 = P2 + [l5 0 0] + [0 0 lift];
outGeom.Toe3 = P3 + [l5 0 0];  

[outGeom.Heel2, outGeom.Knee2, outGeom.Toe2, outGeom.Ankle2] = ...
    ik(outGeom.Hip2, outGeom.Toe2, uq, min(l5/3*alp, lift));
[outGeom.Heel3, outGeom.Knee3, outGeom.Toe3, outGeom.Ankle3] = ...
    ik(outGeom.Hip3, outGeom.Toe3, up, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extra logging
outInfo.zq = q;
outInfo.zp = p;
outInfo.zdp = dp;
outInfo.zqcop = qcop;
outInfo.zpcop = pcop;
outInfo.zzqfixed = zqfixed;
outInfo.zzpfixed = zpfixed;
outInfo.zzfixed = zfixed;
outInfo.zzqadapt = zqadapt;
outInfo.zzpadapt = zpadapt;
outInfo.zzadapt = zadapt;
outInfo.zalpha = alpha_t;
outInfo.zbeta = beta_t;
outInfo.zgamma = gamma_t;

function Z = smoothmax(P,Q,a)
    
    if Q>=a*P && P>=a*Q
        A = (1-a)^2-2*a^2;
        B = a*(P+Q);
        C = -(P^2+Q^2);
        Z = (- B + sqrt(B^2-A*C))/A;
    elseif Q<a*P && P<a*Q
        A = (1-a)^2-2*a^2;
        B = -a*(P+Q);
        C = -(P^2+Q^2);
        Z = P + Q + (- B + sqrt(B^2-A*C))/A;
    elseif Q<a*P && P>=a*Q
        Z = P;
    elseif Q>=a*P && P<a*Q
        Z = Q;
    end
    
end

function [Heel,Knee,Toe,Ankle] = ik (Hip,Toe,shift,lift)

    % convert to x-z plane
    origin = Toe;
    Toe = Toe - origin;
    Hip = Hip - origin;
    ang = -atan2(Hip(2),Hip(3));
    ROT = [1 0 0; 0 cos(ang) -sin(ang); 0 sin(ang) cos(ang)];
    Hip = Hip*ROT;
    
    max_knee_toe = sqrt(l2^2+l3^2-2*l2*l3*cos(170/180*pi));
    min_knee_toe = sqrt(l2^2+l3^2-2*l2*l3*cos(30/180*pi));
    max_hip_toe = l1 + max_knee_toe;
    if norm(Toe-Hip)>max_hip_toe
        Toe = Hip + (Toe-Hip)/norm(Toe-Hip)*max_hip_toe;
    end
   
    % set the knee to the ground target and find the ankle
    target = [Hip(1)+shift(1) 0 0];
    Knee = Hip + (target-Hip)/norm(target-Hip)*l1;

    if norm(Knee-Toe)>max_knee_toe
        % find a reduced hip-toe vector with the length of thigh
        % check of the knee point is in front of it
        hip2 = Toe - Hip;
        hip2 = hip2 / norm(hip2) * l2; 
        if Knee(1) - Hip(1) < hip2(1)
            Knee = triangle(Toe, Hip, max_knee_toe, l1, 0);
        else
            Knee = triangle(Toe, Hip, max_knee_toe, l1, 1);
        end
    end
    if norm(Knee-Toe)<min_knee_toe
        Knee = triangle(Toe, Hip, min_knee_toe, l1, 1);
    end
    Ankle = triangle(Toe, Knee, l3, l2, 0);

    
    % find a reduced hip-ankle vector with the length of shank
    % check of the knee point is in front of it
    hip2 = Ankle - Hip;
    hip2 = hip2 / norm(hip2) * l2;        
    if Knee(1) - Hip(1) < hip2(1)
        Ankle = triangle(Toe, Hip, l3, l1+l2, 0);
        Knee = Hip + (Ankle-Hip)/(l1+l2)*l1;
    end

    % check penetration
    if Ankle(3)-Toe(3)-l4< -lift% && Ankle(1)<=Toe(1)
        z = -lift+l4;
        x = -sqrt(l3^2 - z^2);
        Ankle = [x 0 z]+Toe;
        Knee = triangle(Ankle, Hip, l2, l1, 1);
    end
    
    % create the heel point
    zetta = atan(l4/l5);
    R = [cos(zetta) 0 -sin(zetta); 0 1 0; sin(zetta) 0 cos(zetta)];
    toeheel = (Ankle - Toe) * R';
    Heel = Toe + toeheel;
    
    % back to the original frame
    Knee = Knee * ROT' + origin;
    Ankle = Ankle * ROT' + origin;
    Heel = Heel * ROT' + origin;
    Toe = Toe * ROT' + origin;
    
end

function R = triangle(P,Q,lp,lq,front)
    
    % assume P @ (0,0,0)
    % R = [x,0,z], k = Q - P
    % x^2 + z^2 = lp^2
    % (x-k(1))^2 + (z-k(3))^2 = lq^2 - k(2)^2
    % -2*x*k(1) -2*z*k(3) = lq^2 - k(1)^2 - k(2)^2 - k(3)^2 - lp^2 = A
    % z = (-2*x*k(1) - A)/2/k(3) = ax + b
    % (a^2+1)x^2 + 2abx + b^2 = lp^2
    k = Q - P;
    A = lq^2 - k(1)^2 - k(2)^2 - k(3)^2 - lp^2;
    a = -k(1)/k(3);
    b = -A/2/k(3);
    a1 = a^2+1;
    a2 = 2*a*b;
    a3 = b^2 - lp^2;
    if front
        x = (-a2 + sqrt(a2^2-4*a1*a3))/2/a1;
    else
        x = (-a2 - sqrt(a2^2-4*a1*a3))/2/a1;
    end
    x = real(x);
    z = a*x+b;
    R = [x 0 z] + P;
    
end

function z = height_fixed(x0,y0,cop)
    z = (lmod^2*cos(phi)^2 - y0^2 - (x0+cop+lmod*sin(phi))^2)^0.5;
    z = real(z);
end

function z = height_adaptive(x0,y0,cop)
    % this function interesects a line with an ellipse
    x0 = -x0;
    z0 = lmod * cos(phi);
    
    % line description: (x-x0) = tg(phi) * (z-z0) -> x = az + b
    a = tan(phi); 
    b = -a*z0 + x0;
    
    % cop as a funciton of leg distance
    t1 = -1;
    t2 = 0;
    t3 = 1;
    mat = ...
        [t1^3 t1^2 t1^1 1; ...
         t2^3 t2^2 t2^1 1; ...
         t3^3 t3^2 t3^1 1; ...
         3*t1^2 2*t1^1 1 0; ...
         ];
    curve = @(th,cons) [th.^3 th.^2 th.^1 th.^0]*(mat\cons);
    
    % ellipse description: ((x-center)/Xscale)^2 + (y/Yscale)^2 + (z/Zscale)^2 = 1   
    cop_curve = @(th,s) s*curve(th/s,[-0.2; 0; 1; 0]);
    Xscale    = lmod + cop_curve(cop,l5/2)*2;
    Zscale    = lmod + cop_curve(cop,l5/2);
    Yscale    = lmod;
    center    = cop_curve(cop,l5/2)*2;
    
    % intersection
    % ((az+b-center)/Xscale)^2 + (y/Yscale)^2 + (z/Zscale)^2 = 1;
    % Az^2 + Bz + C = 0;
    b = b - center;
    A = (a./Xscale).^2 + (1./Zscale).^2;
    B = (2*a.*b)./(Xscale.^2);
    C = (b./Xscale).^2 + (y0./Yscale).^2 - 1;
    z = real(0.5 * (- B + (B.^2 - 4.*A.*C).^0.5) ./ A);

end

end