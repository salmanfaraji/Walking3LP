function plot_maple(ax,scenario,t,options,X,geom,camera)

% This function plots 3LP
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.

% general control
hold(ax,'on');
grid(ax, 'on');
axis(ax,'equal');
if ~isfield(ax.UserData,'view_control')
    view(ax,3);
end

if ~isfield(ax.UserData,'GUI')
    ax.UserData.GUI = struct();
end

% disable all graphics object, later we enable when necessary
names = fieldnames(ax.UserData.GUI);
for i=1:length(names)
    n = names{i};
    ax.UserData.GUI.(n).Visible = 'off';
end

% slope, camera, treadmil view
slope = scenario.model.slope;
COS = cos(slope);
SIN = sin(slope);
ROT = [COS 0 SIN; 0 1 0; -SIN 0 COS];
rotated_camera = camera*ROT-[0 0 camera(3)]/abs(COS);
shift = @(x) (~options.iftreadmill) * x + ...
             ( options.iftreadmill) * (x - repmat(rotated_camera,size(x,1),1));
         
% parameters
l5 = scenario.model.metatarsal;
mg = scenario.model.M * scenario.model.g;

% swing/stance color
if t<=scenario.Tds
    swing = 'b--';
else
    swing = 'r--';
end

% plot floor
Xc = shift(X.com);
[Xg,Yg] = meshgrid((-1:0.25:1),(-1:0.25:1));
Xg = Xg + round(Xc(1)/cos(slope)*2)/2;
Yg = Yg + round(Xc(2)*2)/2;
Zg = Xg*sin(slope);
Xg = Xg*cos(slope);
handle = @(x,y,z,u,v,w) mesh(ax,x,y,z,'FaceAlpha',0);
overwrite('mesh',handle,[],Xg,Yg,Zg);

% plot 3LP
if options.if3lp
    vec = shift([X.X3 + [l5 0 0]*ROT; ...
                 X.X3; ...
                 X.x3; ...
                (X.x3+X.x2)/2; ...
                 X.X0; ...
                (X.x3+X.x2)/2; ...
                 X.x2]);
    handle = @(x,y,z,u,v,w) my_plot3(ax,[x y z],'--',2);
    overwrite('lp3_blue',handle,'b',vec(:,1),vec(:,2),vec(:,3));             
                  
    vec = shift([X.x2; ...
                 X.X2; ...
                 X.X2 + [l5 0 0]*ROT]);
    handle = @(x,y,z,u,v,w) my_plot3(ax,[x y z],'--',2);
    overwrite('lp3_red',handle,swing(1),vec(:,1),vec(:,2),vec(:,3));              
                  
    vec = shift([X.y1; X.y2; X.y3]);
    handle = @(x,y,z,u,v,w) my_plot3(ax,[x y z],'*',1);
    overwrite('lp3_dots',handle,'k',vec(:,1),vec(:,2),vec(:,3));   
end

% plot overlay
if options.ifoverlay
    vec = shift([geom.Ankle3; ...
                 geom.Heel3; ...
                 geom.Toe3; ...
                 geom.Ankle3; ...
                 geom.Knee3; ...
                 geom.Hip3; ...
                 geom.Pelvis; ...
                 geom.Pelvis+X.X0-X.X; ...
                 geom.Pelvis; ...
                 geom.Hip2]);
    handle = @(x,y,z,u,v,w) my_plot3(ax,[x y z],'-',2);
    overwrite('overlay_blue',handle,'b',vec(:,1),vec(:,2),vec(:,3));
    
    vec = shift([geom.Hip2; ...
                 geom.Knee2; ...
                 geom.Ankle2; ...
                 geom.Toe2; ...
                 geom.Heel2; ...
                 geom.Ankle2]);
    handle = @(x,y,z,u,v,w) my_plot3(ax,[x y z],'-',2);
    overwrite('overlay_red',handle,swing(1),vec(:,1),vec(:,2),vec(:,3));
end

if options.if3lp || options.ifoverlay
    % plot forces on the overlay if 3LP is not plotted
    torso = shift(X.X1);
    hip2 = shift(X.x2);
    hip3 = shift(X.x3);
    heel2 = shift(X.X2);
    heel3 = shift(X.X3);
    if ~options.if3lp
        torso = shift(geom.Pelvis+X.X1-X.X);
        hip2 = shift(geom.Hip2);
        hip3 = shift(geom.Hip3);
    end
    
    % plot drag force
    drag = [scenario.drag(1) 0 0]*ROT;
    vec = drag/mg*3;
    handle = @(x,y,z,u,v,w) quiver3(ax,x,y,z,u,v,w,'LineWidth',1.5,'MaxHeadSize',1);
    overwrite('drag',handle,'k',torso(1),torso(2), torso(3), vec(1),vec(2), vec(3));
    
    % plot perturbation force
    vec = (X.F1-drag)/mg*3;
    handle = @(x,y,z,u,v,w) quiver3(ax,x,y,z,u,v,w,'LineWidth',1.5,'MaxHeadSize',1);
    overwrite('pert',handle,'m',torso(1),torso(2), torso(3), vec(1),vec(2), vec(3));

    % contact forces
    if options.ifforces
        % the CoP goes to the toes, but we show it only up to metatarsal
        ratio = scenario.model.metatarsal/scenario.model.l_leg(3);
        
        shift2 = [ - X.T2(2)/X.F2(3) 0 0] * ratio * ROT;
        vec = [heel2+shift2; heel2+shift2+X.F2/mg];
        handle = @(x,y,z,u,v,w) my_plot3(ax,vec,'-',2);
        overwrite('force2',handle,'g',vec(:,1),vec(:,2),vec(:,3)); 
        
        shift3 = [ - X.T3(2)/X.F3(3) 0 0] * ratio * ROT;
        vec = [heel3+shift3; heel3+shift3+X.F3/mg];
        handle = @(x,y,z,u,v,w) my_plot3(ax,vec,'-',2);
        overwrite('force3',handle,'g',vec(:,1),vec(:,2),vec(:,3)); 
    end

    % hip torques
    if options.iftorques
        [x,y,z] = sphere(8);
        x = x(:,3:5);
        y = y(:,3:5);
        z = z(:,3:5);
        center = [hip3; hip2];
        torque = [X.t3; X.t2];
        colors = ['b'; 'g'; 'r'];
        for j=2%1:2
            for i = 2%2:3
                tau = torque(j,4-i);
                Xg = -x/mg*tau*(i~=3) + center(j,1);
                Yg = y/mg*tau*(i~=2) + center(j,2);
                Zg = z/mg*tau*(i~=1) + center(j,3);
                handle = @(x,y,z,u,v,w) surf(ax, Xg, Yg, Zg, ...
                     'EdgeColor',colors(i,:),'FaceColor',colors(i,:));
                overwrite(['disk' num2str(i) num2str(j)],handle,[],Xg,Yg,Zg);
            end
        end
    end
end

% determine camera location
if options.iftreadmill
    center = camera * ROT;
else
    center = X.X;
end
center = shift(center);
scale = scenario.model.h1;
xlim(ax,[-1   1]*scale*0.80+center(1));
ylim(ax,[-1   1]*scale*0.80+center(2));
zlim(ax,[-1.05 1.1]*scale*1.00+center(3) + [-0.80*scale*abs(tan(slope)) 0]);

% set labels
mid = round(center(1)*2)/2;
ax.XTick = linspace(mid-1,mid+1,5);
mid = round(center(2)*2)/2;
ax.YTick = linspace(mid-1,mid+1,5);
mid = round(center(3)*2)/2;
ax.ZTick = linspace(mid-1.5,mid+1,6);

% this funciton overwrites graphics data
function overwrite(str,handle,c,x,y,z,u,v,w)
    if nargin<=6
        u = []; v = []; w = [];
    end
    if ~isfield(ax.UserData.GUI, str) 
        ax.UserData.GUI.(str) = handle(x,y,z,u,v,w);
    elseif isfield(ax.UserData.GUI, str) && ishandle(ax.UserData.GUI.(str))
        ax.UserData.GUI.(str).XData = x;
        ax.UserData.GUI.(str).YData = y;
        ax.UserData.GUI.(str).ZData = z;
        if nargin>6
            ax.UserData.GUI.(str).UData = u;
            ax.UserData.GUI.(str).VData = v;
            ax.UserData.GUI.(str).WData = w;
        end 
    end
    
    if strcmp(ax.UserData.GUI.(str).Type, 'line') || ...
       strcmp(ax.UserData.GUI.(str).Type, 'quiver')
        ax.UserData.GUI.(str).Color = c;
    elseif strcmp(str, 'mesh')
        z = ax.UserData.GUI.(str).ZData;
        ax.UserData.GUI.(str).CData = (z - min(z(:)))*100;
    end
    ax.UserData.GUI.(str).Visible = 'on';
end

end