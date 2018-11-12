function varargout = Walking3LP(varargin)
% Walking3LP MATLAB code for Walking3LP.fig
%      Walking3LP, by itself, creates a new Walking3LP or raises the existing
%      singleton*.
%
%      H = Walking3LP returns the handle to a new Walking3LP or the handle to
%      the existing singleton*.
%
%      Walking3LP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Walking3LP.M with the given input arguments.
%
%      Walking3LP('Property','Value',...) creates a new Walking3LP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Walking3LP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Walking3LP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 22-Oct-2018 18:13:18
%
% Author:         Salman Faraji
% Date:           November 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.pdf file for more details.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KNOWN ISSUES
% reduced gravity leans forward, bacause CoP moves, it shoudn't
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Walking3LP_OpeningFcn, ...
                   'gui_OutputFcn',  @Walking3LP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Outputs from this function are returned to the command line.
function varargout = Walking3LP_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
    GUI_path = fileparts(mfilename('fullpath'));
    GUI_path = [GUI_path '/'];
    addpath(GUI_path);
    initialize(GUI_path);

% --- Executes just before Walking3LP is made visible.
function Walking3LP_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.timer = timer(...
        'ExecutionMode', 'fixedRate', ...
        'Period', 0.01, ... 
        'TimerFcn', {@update_display,hObject});
    for i=2:18
        edit = ['edit' num2str(i)];
        slider = ['slider' num2str(i)];
        handles.(edit).String = num2str(handles.(slider).Value);
        handles.(edit).Min = 0;
        handles.(edit).Max = 0;
    end
    list = {'torso','thigh','shank','foot'};
    for i=1:length(list)
        handles.([list{i} '_mass']).Min = 0;
        handles.([list{i} '_mass']).Max = 0;
        handles.([list{i} '_ratio']).Min = 0;
        handles.([list{i} '_ratio']).Max = 0;
    end
    handles.axes1.UserData.ifvideo = 0;
    handles.axes1.Visible = 'off';
    handles.version.String = 'Version 2.0';
    handles.directory.String = ['Current Directory: ' pwd];
    view(handles.axes1,3);
    global if_started;
    if_started = 0;
    guidata(hObject, handles);
    force_update(handles);
    guidata(hObject, handles);
    handles.torso_mass.Min = 0;
    handles.torso_mass.Max = 0;
    handles.axes3.Visible = 0;

function force_update(handles)
    quiver(handles.axes2,1.2,-0.9,0,1.6,'b','LineWidth',1.5,'MaxHeadSize',0.5);
    hold(handles.axes2,'on');
    quiver(handles.axes2,0,0, ...
           handles.slider11.Value/10,handles.slider10.Value/10, ...
           'm','LineWidth',1.5,'MaxHeadSize',1);
    x = linspace(-1, 1, 100);
    for d = [0.33 0.66 1]
        plot(handles.axes2, x*d,(1-x.^2).^0.5*d,'k');
        plot(handles.axes2, x*d,-(1-x.^2).^0.5*d,'k');
    end
    list = {handles.axes2, handles.axes4};
    for i=1:length(list)
        hold(list{i},'off');
%         xlim(list{i},[-1 1.6]);
%         ylim(list{i},[-1 1]);
        list{i}.XTick = [];
        list{i}.YTick = [];
        list{i}.XColor = 'none';
        list{i}.YColor = 'none';
        list{i}.Box = 'off';
        list{i}.Color = [0.9400 0.9400 0.9400];
    end
    
function str_out = increment_str(str_in, suffix)
    list = dir('*');
    n = -1;
    for i=1:length(dir)
        if ~(list(i).isdir) & strfind(list(i).name, suffix) & ...
             strfind(list(i).name, str_in) 
            i1 = strfind(list(i).name,'(');
            i2 = strfind(list(i).name,')');
            if ~isempty(i1) & ~isempty(i2)
                str = list(i).name((i1(end)+1):(i2(end)-1));
                n = max(n,str2num(str));
            else
                n = max(n,0); 
            end
        end
    end
    if n==-1
        str_out = [str_in '.' suffix];
    else
        str_out = [str_in ' (' num2str(n+1) ')' '.' suffix];
    end
  
function [speed,message] = adjustment(speed,s)
    
    s.cop_length = 0;
    [cop1, cop2] = cop_design(s);
    s.gait = s.create_gait(s, cop1, cop2);
    Y = s.gait(speed);
    y0 = [Y(1)-Y(9) Y(9)-Y(3) Y(3)-Y(1)];
    dx0 = speed;
    lim  = [1 0.7 0.7] * s.model.h1;
    if any(abs(y0)>lim)
        Y = s.gait(10);
        y1 = [Y(1)-Y(9) Y(9)-Y(3) Y(3)-Y(1)];
        dx1 = 10;
        % y0 = a*dx0 + b
        % y1 = a*dx1 + b
        a = (y1-y0)./(dx1-dx0);
        % -lim < a*(dx0+dx2) + b < lim
        % we should solve a linear program here
        dx2_list = sort([(-lim-y0)./a (lim-y0)./a]);
        [~,i] = min(abs(dx2_list(3:4)));
        dx2 = dx2_list(2+i);
        speed = (speed + dx2) * 0.99;
        message = 'Warning: Speed Adjusted';
    else
        message = [];
    end
    
function [X0,message] = safety(X0,Y,s)
    
    XC = X0;
    fb = s.cont.cont_feedback(Y, XC, XC, eye(25), s.cont.H0, s);
    XC(s.cont.input) = XC(s.cont.input) + fb; 
    Y0 = s.cont.H0 * XC;
    y0 = [Y0(1)-Y0(9) Y0(9)-Y0(3) Y0(3)-Y0(1)];
    lim  = [1 0.7 0.7] * s.model.h1;
    dx0 = XC(7); 
    if any(abs(y0)>lim)
        XC = X0;
        XC(7) = 10;
        fb = s.cont.cont_feedback(Y, XC, XC, eye(25), s.cont.H0, s);
        XC(s.cont.input) = XC(s.cont.input) + fb; 
        Y0 = s.cont.H0 * XC;
        y1 = [Y0(1)-Y0(9) Y0(9)-Y0(3) Y0(3)-Y0(1)];
        dx1 = XC(7);
        % y0 = a*dx0 + b
        % y1 = a*dx1 + b
        a = (y1-y0)./(dx1-dx0);
        % -lim < a*(dx0+dx2) + b < lim
        % we should solve a linear program here
        dx2_list = sort([(-lim-y0)./a (lim-y0)./a]);
        [~,i] = min(abs(dx2_list(3:4)));
        dx2 = dx2_list(2+i);
        X0(7) = dx0 + dx2;
        message = 'Warning: Too Fast Transition';
    else
        message = [];
    end
    
function [cop1, cop2] = cop_design(s)
    alpha = abs(s.cop_length)/s.model.l_leg(3);
    center = (s.model.metatarsal*(1-alpha)+s.model.l_leg(3)*alpha)/2;
    cop1 = -s.cop_length/2 + center;
    cop2 = s.cop_length;
    
function update_gains(gain, ax)
    if isempty(ax.Children)
        plot(ax, linspace(0,1,size(gain,1)), gain, 'LineWidth', 2);
        grid(ax,'on');
        legend(ax,{'Foot',  'Pelvis', 'dFoot', 'dPelvis'},'FontSize',7)
    else
        for i=1:4
            ax.Children(5-i).XData = linspace(0,1,size(gain,1));
            ax.Children(5-i).YData = gain(:,i);
        end
    end
    
function model = addmass(model, handles)
    torso_mass = str2num(handles.torso_mass.String);
    thigh_mass = str2num(handles.thigh_mass.String);
    shank_mass = str2num(handles.shank_mass.String);
    foot_mass = str2num(handles.foot_mass.String);
    torso_ratio = str2num(handles.torso_ratio.String);
    thigh_ratio = str2num(handles.thigh_ratio.String);
    shank_ratio = str2num(handles.shank_ratio.String);
    foot_ratio = str2num(handles.foot_ratio.String);
    
    model = add_mass(model,torso_mass,torso_ratio/100,7);
    model = add_mass(model,thigh_mass,thigh_ratio/100,6);
    model = add_mass(model,shank_mass,shank_ratio/100,5);
    model = add_mass(model,foot_mass,foot_ratio/100,4);
    
    head = [0 1];
    pelvis = [0 0];
    rknee = [0.2 -0.5];
    rfoot = [0.3 -1];
    lknee = [-0.1 -0.5];
    lfoot = [-0.3 -1];
    
    ax = handles.axes4;
    
    points = [head; pelvis; rknee; rfoot; rknee; pelvis; lknee; lfoot];
    plot(ax,points(:,1),points(:,2));  
    
    hold(ax, 'on');
    cx = linspace(-1,1,10);
    cy = sqrt(1-cx.^2);
    cx = [cx cx(end:-1:1)];
    cy = [cy -cy];
    
    p = pelvis + (head-pelvis)*torso_ratio/100;
    m = torso_mass/model.M;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    
    p = pelvis + (rknee-pelvis)*thigh_ratio/100;
    m = thigh_mass/model.M;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    p = pelvis + (lknee-pelvis)*thigh_ratio/100;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    
    p = rknee + (rfoot-rknee)*shank_ratio/100;
    m = shank_mass/model.M;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    p = lknee + (lfoot-lknee)*shank_ratio/100;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    
    p = rfoot + (rfoot-rfoot)*foot_ratio/100;
    m = foot_mass/model.M;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    p = lfoot + (lfoot-lfoot)*foot_ratio/100;
    plot(ax, cx'*m + p(1), cy'*m + p(2), 'r', 'LineWidth', 2);
    

    axis(ax,'equal');
    ax.YTick = [];
    ax.XColor = 'none';
    ax.YColor = 'none';
    ax.Box = 'off';
    ax.Color = [0.9400 0.9400 0.9400];
    hold(ax, 'off');
    
function ratio = find_ratios(index)
    switch index
        case 1
            ratio = human_ratios();
        case 2
            ratio = atlas_ratios();
        case 3
            ratio = coman_ratios();
        case 4
            ratio = icub_ratios();
        case 5
            ratio = nao_ratios();
        case 6
            ratio = IP_ratios();
    end

function update_display(hObject,eventdata,hfigure)

    global X0 if_started push_apply camera;
    handles = guidata(hfigure);
    
    % gait options
    Mass        = handles.slider2.Value;    
    mg          = Mass * 9.81;
    Height      = handles.slider3.Value;
    speed       = handles.slider4.Value;
    Tstep       = handles.slider5.Value^(-1);
    Tds         = handles.slider6.Value/100;
    Clearance   = handles.slider7.Value/100;
    theta       = handles.slider13.Value/180 * pi;
    slope       = handles.slider14.Value/180 * pi;
    drag        = handles.slider15.Value/100 * mg;
    sw          = handles.slider16.Value/100;
    grav        = handles.slider17.Value/100;
    input_cost  = 10^handles.slider18.Value;
    
    % simulation options
    options                 = options_3LP();
    options.ifplot          = 1;
    options.iflog           = 1;
    options.dist_pattern    = [1 0 1 0 0 0 0];
    options.dist_strength   = 0;
    options.dist_pattern(2) = handles.slider8.Value/100;
    options.dist_pattern(3) = handles.slider9.Value/100;
    options.dist_pattern(4) = handles.slider10.Value/100 * mg;
    options.dist_pattern(5) = -handles.slider11.Value/100 * mg;
    options.real_time       = handles.slider12.Value/100;
    options.resolution      = round(30*Tstep/options.real_time);
    options.ax              = handles.axes1;
    options.ifforces        = handles.forces.Value;
    options.iftorques       = handles.forces.Value;
    options.ifoverlay       = handles.overlay.Value;
    options.if3lp           = handles.lp3.Value;
    options.iftreadmill     = handles.treadmill.Value;
    
    % camera orientation
    options.ax.UserData.view_control = 1;
       
    % 3LP model ##### WARNING: ATLAS ratios
    ratio = find_ratios(handles.anatomies.Value);
    model = model_geom(Mass, Height, ratio, theta+slope, slope);
    model = addmass(model, handles);
    model.rg = 1-grav;
    
    % 3LP gait
    s = create_model(model, Tstep*Tds, Tstep);
    s.step_width = s.model.pw * 2 * sw;
    s.clearance = Clearance;
    s.drag(1) = drag;
    
    % Adjust speed to ensure feasible motion
    speed = adjustment(speed,s);
    
    % 3LP gait
    s.cop_length = truncate(speed*Tstep/2, s.cop_length); 
    [cop1, cop2] = cop_design(s);    
    s.gait = s.create_gait(s, cop1, cop2);
    Y = s.gait(speed);
    handles.slider4.Value = speed;
    options.vdes = [1 speed];
    slider4_Callback(handles.slider4, eventdata, handles);
   
    % the first step
    if ~if_started
        if_started = 1;
        X0 = Y;
        int = vis_maple_DS(X0,s,0);
        camera = int.com;
    end
    
    % enables disturbance
    if push_apply
        options.dist_strength = 1;
        push_apply = 0;
    end
    
    % controller design
    Qx = diag([ones(4,1)/s.model.h1^2; ones(4,1)/sqrt(s.model.h1*9.81)^2]);
    Qr = diag([1 1 0 0]) / (Mass*9.81)^2 * input_cost;    
    s = create_controllers(s, Qx, Qr);
    s.feedback = s.cont.cont_feedback;
    
    
    % resetting inputs to nominal before control
    index = [11:18 19:22 23 24];
    X0(index) = Y(index);
    X0(12:2:18) = X0(end) * X0(12:2:18);
    
    % safety: prediction/correction of large step length
    [X0,handles.message1.String] = safety(X0,Y,s);
   
    % simulation of one 3LP step
    options.camera = camera;
    [log,events] = integration(s, X0, 1, options);
    if ~ishandle(options.ax)
        return;
    end
    X0 = events(:,end);
    camera = log.camera(end,:);  
    
    % time-projection gains
    update_gains(log.gain, handles.axes3);
   
   
    % gait information
    asym = asymmetry(X0, s);
    cost = energetics(X0, log, model, 1/Tstep, Mass);
    handles.metabolic.String = ...
        ['Metabolic Rate (kcal/min): ' num2str(cost.Total*14.33/1000,'%2.3f')];
    handles.cot.String = ...
        ['Cost of Transport (J/m/N): ' num2str(cost.CoT,'%2.3f')];
    handles.asymmetry.String = ...
        ['Triangular Asymmetry (deg): ' num2str(asym/pi*180,'%2.2f')];
    handles.leg_length.String = ...
        [num2str(model.h1,'%2.2f') ' m'];
    handles.com.String = ...
        [num2str(log.com(end,3),'%2.2f') ' m'];
    

        
    
% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    handles.edit2.String = num2str(hObject.Value,'%2.2f');
    guidata(hObject, handles);
function edit2_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = max(v,handles.slider2.Min);
    v = min(v,handles.slider2.Max);
    handles.slider2.Value = v;
    handles.edit2.String = num2str(v,'%2.2f');
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
    v = hObject.Value;
    handles.edit3.String = num2str(v,'%2.2f');
    handles.slider5.Min = 1 * sqrt(1.7/v);
    handles.slider5.Max = 3 * sqrt(1.7/v);
    edit5_Callback(handles.edit5, eventdata, handles);
    guidata(hObject, handles);
function edit3_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = max(v,handles.slider3.Min);
    v = min(v,handles.slider3.Max);
    handles.slider3.Value = v;
    handles.slider5.Min = 1 * sqrt(1.7/v);
    handles.slider5.Max = 3 * sqrt(1.7/v);
    edit5_Callback(handles.edit5, eventdata, handles);
    handles.edit3.String = num2str(v,'%2.2f');
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
    handles.edit4.String = num2str(hObject.Value,'%2.2f');
    guidata(hObject, handles);
function edit4_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = max(v,handles.slider4.Min);
    v = min(v,handles.slider4.Max);
    handles.slider4.Value = v;
    handles.edit4.String = num2str(v,'%2.2f');
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
    handles.edit5.String = num2str(hObject.Value,'%2.2f');
    guidata(hObject, handles);
function edit5_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = max(v,handles.slider5.Min);
    v = min(v,handles.slider5.Max);
    handles.slider5.Value = v;
    handles.edit5.String = num2str(v,'%2.2f');
    handles.text14.String = num2str(handles.slider5.Min,'%2.1f');
    handles.text15.String = num2str(handles.slider5.Max,'%2.1f');
    guidata(hObject, handles);


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit6.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit6_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider6.Min);
    v = min(v,handles.slider6.Max);
    handles.slider6.Value = v;
    handles.edit6.String = num2str(v);
    guidata(hObject, handles);


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit7.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit7_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider7.Min);
    v = min(v,handles.slider7.Max);
    handles.slider7.Value = v;
    handles.edit7.String = num2str(v);
    guidata(hObject, handles);


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit8.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit8_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider8.Min);
    v = min(v,handles.slider8.Max);
    handles.slider8.Value = v;
    handles.edit8.String = num2str(v);
    guidata(hObject, handles);


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit9.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit9_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider9.Min);
    v = min(v,handles.slider9.Max);
    handles.slider9.Value = v;
    handles.edit9.String = num2str(v);
    guidata(hObject, handles);


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit10.String = num2str(hObject.Value);
    guidata(hObject, handles);
    force_update(handles);
function edit10_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider10.Min);
    v = min(v,handles.slider10.Max);
    handles.slider10.Value = v;
    handles.edit10.String = num2str(v);
    guidata(hObject, handles);
    force_update(handles);

% --- Executes on slider movement.
function slider11_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit11.String = num2str(hObject.Value);
    guidata(hObject, handles);
    force_update(handles);
function edit11_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider11.Min);
    v = min(v,handles.slider11.Max);
    handles.slider11.Value = v;
    handles.edit11.String = num2str(v);
    guidata(hObject, handles);
    force_update(handles);


% --- Executes on slider movement.
function slider12_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit12.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit12_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider12.Min);
    v = min(v,handles.slider12.Max);
    handles.slider12.Value = v;
    handles.edit12.String = num2str(v);
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider13_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit13.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit13_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider13.Min);
    v = min(v,handles.slider13.Max);
    handles.slider13.Value = v;
    handles.edit13.String = num2str(v);
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider14_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit14.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit14_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider14.Min);
    v = min(v,handles.slider14.Max);
    handles.slider14.Value = v;
    handles.edit14.String = num2str(v);
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider15_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit15.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit15_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider15.Min);
    v = min(v,handles.slider15.Max);
    handles.slider15.Value = v;
    handles.edit15.String = num2str(v);
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider16_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit16.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit16_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider16.Min);
    v = min(v,handles.slider16.Max);
    handles.slider16.Value = v;
    handles.edit16.String = num2str(v);
    guidata(hObject, handles);
    
    % --- Executes on slider movement.
function slider17_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value);
    handles.edit17.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit17_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider17.Min);
    v = min(v,handles.slider17.Max);
    handles.slider17.Value = v;
    handles.edit17.String = num2str(v);
    guidata(hObject, handles);
    
    % --- Executes on slider movement.
function slider18_Callback(hObject, eventdata, handles)
    hObject.Value = round(hObject.Value*10)/10;
    handles.edit18.String = num2str(hObject.Value);
    guidata(hObject, handles);
function edit18_Callback(hObject, eventdata, handles)
    v = str2num(hObject.String);
    v = round(v);
    v = max(v,handles.slider18.Min);
    v = min(v,handles.slider18.Max);
    handles.slider18.Value = v;
    handles.edit18.String = num2str(v);
    guidata(hObject, handles);
    
    
function torso_mass_Callback(hObject, eventdata, handles)
    v = str2num(handles.torso_mass.String);
    v = max(v, handles.torso_mass.UserData(1));
    v = min(v, handles.torso_mass.UserData(2));
    handles.torso_mass.String = num2str(v);
    guidata(hObject, handles);
    
function thigh_mass_Callback(hObject, eventdata, handles)
    v = str2num(handles.thigh_mass.String);
    v = max(v, handles.thigh_mass.UserData(1));
    v = min(v, handles.thigh_mass.UserData(2));
    handles.thigh_mass.String = num2str(v);
    guidata(hObject, handles);
    
function shank_mass_Callback(hObject, eventdata, handles)
    v = str2num(handles.shank_mass.String);
    v = max(v, handles.shank_mass.UserData(1));
    v = min(v, handles.shank_mass.UserData(2));
    handles.shank_mass.String = num2str(v);
    guidata(hObject, handles);
    
function foot_mass_Callback(hObject, eventdata, handles)
    v = str2num(handles.foot_mass.String);
    v = max(v, handles.foot_mass.UserData(1));
    v = min(v, handles.foot_mass.UserData(2));
    handles.foot_mass.String = num2str(v);
    guidata(hObject, handles);
    
function torso_ratio_Callback(hObject, eventdata, handles)
    v = str2num(handles.torso_ratio.String);
    v = max(v, handles.torso_ratio.UserData(1));
    v = min(v, handles.torso_ratio.UserData(2));
    handles.torso_ratio.String = num2str(v);
    guidata(hObject, handles);
    
function thigh_ratio_Callback(hObject, eventdata, handles)
    v = str2num(handles.thigh_ratio.String);
    v = max(v, handles.thigh_ratio.UserData(1));
    v = min(v, handles.thigh_ratio.UserData(2));
    handles.thigh_ratio.String = num2str(v);
    guidata(hObject, handles);
    
function shank_ratio_Callback(hObject, eventdata, handles)
    v = str2num(handles.shank_ratio.String);
    v = max(v, handles.shank_ratio.UserData(1));
    v = min(v, handles.shank_ratio.UserData(2));
    handles.shank_ratio.String = num2str(v);
    guidata(hObject, handles);
    
function foot_ratio_Callback(hObject, eventdata, handles)
    v = str2num(handles.foot_ratio.String);
    v = max(v, handles.foot_ratio.UserData(1));
    v = min(v, handles.foot_ratio.UserData(2));
    handles.foot_ratio.String = num2str(v);
    guidata(hObject, handles);
    
    

% --- Executes on button press in threedview.
function threedview_Callback(hObject, eventdata, handles)
    handles.backview.Value = 0;
    handles.sideview.Value = 0;
    handles.topview.Value = 0;
    view(handles.axes1,3);
    guidata(hObject, handles);

% --- Executes on button press in backview.
function backview_Callback(hObject, eventdata, handles)
    handles.threedview.Value = 0;
    handles.sideview.Value = 0;
    handles.topview.Value = 0;
    view(handles.axes1,[-1 0 0]);
    guidata(hObject, handles);

% --- Executes on button press in sideview.
function sideview_Callback(hObject, eventdata, handles)
    handles.threedview.Value = 0;
    handles.backview.Value = 0;
    handles.topview.Value = 0;
    view(handles.axes1,[0 -1 0]);
    guidata(hObject, handles);

% --- Executes on button press in topview.
function topview_Callback(hObject, eventdata, handles)
    handles.threedview.Value = 0;
    handles.sideview.Value = 0;
    handles.backview.Value = 0;
    view(handles.axes1,-90, 90);
    guidata(hObject, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    if ~isempty(handles)
        if strcmp(get(handles.timer, 'Running'), 'on')
            stop(handles.timer);
        end
        delete(handles.timer);
    end
    delete(hObject);

% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
    if handles.record.Value == 1
        str = increment_str(handles.moviename.String, 'avi');
        handles.axes1.UserData.aviobj = VideoWriter(str);
        handles.axes1.UserData.aviobj.Quality = 90;
        handles.axes1.UserData.aviobj.open();
        handles.axes1.UserData.ifvideo = 1;
    else
        handles.axes1.UserData.ifvideo = 0;
        handles.axes1.UserData.aviobj.close();
        handles.axes1.UserData = rmfield(handles.axes1.UserData,'aviobj');
    end

% --- Executes on button press in takephoto.
function takephoto_Callback(hObject, eventdata, handles)
    print(handles.figure1,increment_str(handles.photoname.String, 'png'),'-dpng','-r300');

% --- Executes on button press in controllerlut.
function h = controllerlut_Callback(hObject, eventdata, handles)
    h = figure;
    copyobj(handles.axes3,h);
    ax = h.Children;
    ax.Visible = 1;
    ax.Units = 'normalized';
    ax.Position = [0.1300 0.1100 0.7750 0.8150];
    ylabel(ax,'\Delta Footstep / e');
    xlabel(ax,'Gait Cycle (%phase)');
    grid(ax,'on');
    legend(ax,{'e_1: Foot Position', ...
               'e_2: Pelvis Position', ...
               'e_3: Foot Velocity', ...
               'e_4: Pelvis Velocity'})
    title(ax,'Footstep - Adjustment Gains', ...
          'FontWeight','normal');
    

% --- Executes on button press in applypush.
function applypush_Callback(hObject, eventdata, handles)
    global push_apply;
    push_apply = 1;

% --- executes on mouse press in 5 pixel border or over text66.
function text66_ButtonDownFcn(hObject, eventdata, handles)
path = 'https://github.com/salmanfaraji/Walking3LP';
web(path);
    
% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
    figure1_CloseRequestFcn(hObject.Parent.Parent, eventdata, handles)

% --- Executes on button press in startstop.
function startstop_Callback(hObject, eventdata, handles)
    handles.axes1.Visible = 'on';
    if strfind(handles.startstop.String,'Start')
        handles.startstop.String = 'Stop Simulation';
    else
        handles.startstop.String = 'Start Simulation';
    end
    guidata(hObject, handles);
    if strcmp(get(handles.timer, 'Running'), 'on')
        stop(handles.timer); 
    else
        start(handles.timer);
    end


% --- Executes on button press in lut.
function lut_Callback(hObject, eventdata, handles)
    % hObject    handle to lut (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    h = controllerlut_Callback(hObject, eventdata, handles);
    g = h.Children(2); % lines
    f = h.Children(1); % legend
    t = g.Children(1).XData;
    for i=1:4
        G(i,:) = g.Children(5-i).YData;
        c(i,:) = g.Children(5-i).Color;
        s{i} = f.String{i};
    end
    hold(g,'on');
    f = @(x,t) x(1)*exp(-(t/x(2))) + x(3)*exp(-((1-t)/x(4)).^2);
    options = optimoptions('fmincon','Display','off');
    X0 = [1 -1 0 0];
    fitting = [];
    for i=1:4
        X = fmincon(@(x)norm(G(i,:)-f(x,t)), ...
                    [G(i,1) 0.5 X0(i) 0.5], ...
                    [],[],[],[], ...
                    [-20 0 -20 0],[20 1 20 1],[],options);
        plot(g,t,f(X,t),'--', 'Color', c(i,:), 'DisplayName', s{i} );
        fitting = [fitting; X];
    end

    fileID = fopen('LuT.cpp','w');
    fprintf(fileID, '// 0 <= time <= 1 : phase time \n');
    fprintf(fileID, ['// freq = ' num2str(handles.slider5.Value) ' & log10(gain) = ' num2str(handles.slider18.Value) ' \n\n']);
    fprintf(fileID, 'double g1[4] = { \n');
    for i=1:4
        fprintf(fileID,'    exp(-std::pow(time/%f,1.0)),\n',fitting(i,2));
    end
    fprintf(fileID, '};\n double g2[4] = { \n');
    for i=1:4
        fprintf(fileID,'    exp(-std::pow((1.0-time)/%f2 ,2.0)),\n',fitting(i,4));
    end
    fprintf(fileID, '};\n double K[4] = { \n');
    for i=1:4
        fprintf(fileID,['    %f * g1[' num2str(i-1) '] + %f * g2[' num2str(i-1) '],\n'],fitting(i,1),fitting(i,3));
    end
    fprintf(fileID, '};');
    fclose(fileID);
    handles.message1.String = 'Output Written To LuT.cpp';
    guidata(hObject, handles);


% --- Executes on selection change in anatomies.
function anatomies_Callback(hObject, eventdata, handles)
    ratio = find_ratios(handles.anatomies.Value);
    handles.edit2.String = num2str(ratio.M,'%2.2f');
    edit2_Callback(handles.edit2, eventdata, handles);
    handles.edit3.String = num2str(ratio.L,'%2.2f');
    edit3_Callback(handles.edit3, eventdata, handles);
    guidata(hObject, handles);
