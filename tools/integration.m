function [log,events] = integration(s,X0,Nsteps,options)

% This function integrates 3LP equations 
% Author:         Salman Faraji
% Date:           March 2018
% Available from: https://biorob.epfl.ch/research/humanoid/walkman
% © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% BIOROB Laboratory, 2018
% Walking3LP must be referenced when used in a published work 
% See the LICENSE.txt file for more details.

% filming
if(options.ifvideo) 
    aviobj = VideoWriter(options.videoname);
    aviobj.open();
end

% camera location
if ~isfield(options,'camera')
    int = vis_maple_DS(X0,s,0);
    options.camera = int.com;
end

% slope rotation matrix
slope = s.model.slope;
COS = cos(slope);
SIN = sin(slope);
ROT = [COS 0 SIN; 0 1 0; -SIN 0 COS];

% integration
dt = s.Tstep/options.resolution;
X = X0;
log = [];
events = zeros(s.dim,Nsteps);
for tot_steps=1:Nsteps

    if ~isempty(options.vdes(options.vdes(:,1)==tot_steps,1))
        Y = s.gait(options.vdes(options.vdes(:,1)==tot_steps,2));
    end
    X0 = X;
    for index=1:options.resolution
        
        time = (index-1)*dt;
        total_time = (tot_steps-1)*s.Tstep + time;
        trans = s.H(time,dt);
        remaining = s.H(time,s.Tstep-time);
        past = s.H(0,time);
              
        % rest input dimensions in X
        X(11:18) = Y(11:18);
        X(12:2:18) = X(end) * X(12:2:18);
        X(19:22) = Y(19:22);

        % control
        error = s.cont.error(Y, X, past);
        fb = s.feedback(Y, X, X0, past, remaining, s);
        X(s.cont.input) = X(s.cont.input) + fb;

        % additional disturbance
        i = find(options.dist_pattern(:,1)==tot_steps, 1);
        if ~isempty(i)
            if time>=min(options.dist_pattern(i,2),options.dist_pattern(i,3))*s.Tstep && ...
               time<=max(options.dist_pattern(i,2),options.dist_pattern(i,3))*s.Tstep
                X(19:22) = X(19:22) + diag(options.dist_strength) * options.dist_pattern(i,4:7)';
            end
        end
        
        % additional costly calculations fir display/logging
        ifshow = mod(index,round((1/30)/dt * options.real_time))==0 && options.ifplot;
        if ifshow || options.iflog

            % 3lp state
            if time <= s.Tds
                int = vis_maple_DS(X,s,time);
            else
                int = vis_maple_SS(X,s,time-s.Tds);
            end
            int.dX3 = [0 0 0];
            int.ddX3 = [0 0 0];
            int.t3 = int.t3 * diag([1 -1 1]);
            int.t2 = int.t2 * diag([1 -1 1]);
            
            % overlay state
            [geom,info] = convert(int,s,time);
            
            % camera update
            options.camera = options.camera + [options.vdes(1,2)*dt 0 0] + ...
                (int.com-options.camera)*diag([dt*5 dt*1 dt*2]);
            
            f = fieldnames(int);
            for i=1:length(f)
                int.(char(f(i))) = int.(char(f(i))) * ROT;
            end
            int.K = int.K * pinv(ROT);
            f = fieldnames(geom);
            for i=1:length(f)
                geom.(char(f(i))) = geom.(char(f(i))) * ROT;
            end
                        
            % additional info
            int.time = total_time;
            int.error = error';
            int.feedback = fb';
            int.camera = options.camera;
            
            % calculate control gains
            for i=1:4
                XX = past * Y;
                XX(i*2-1) = XX(i*2-1) + 1;
                fbb = s.feedback(Y, XX, X0, past, remaining, s);
                XX(s.cont.input) = XX(s.cont.input) + fbb;
                XXend = remaining * XX;
                gain(1,i) = (XXend(1)-XXend(3)) - (Y(1)-Y(3));
            end
            int.gain = gain;
        end
        
        % display
        if ifshow
            if isfield(options,'ax')
                ax = options.ax;
                if ~ishandle(ax)
                    events = [];
                    log = [];
                    return;
                end
            else
                ax = gca;
            end
            plot_maple(ax, s, index*dt, options, int, geom, options.camera); 
            drawnow;
            if(options.ifvideo)
                writeVideo(aviobj,getframe(gcf)); 
            end
            if ishandle(ax)
                if ax.UserData.ifvideo==1
                    pic = getframe(gcf);
                end
                if isfield(ax.UserData, 'aviobj') && ax.UserData.ifvideo==1
                    writeVideo(ax.UserData.aviobj,pic);
                end
            end
        end

        % logging
        if options.iflog
            log = merge_signals(log, int, X);
            log = merge_signals(log, geom, X);
            log = merge_signals(log, info, X);
        end
        if(index==1)
            events(:,tot_steps) = X;
        end
    
        % real state evolution with additional disturbance
        X = trans * X;
    end    
    reset_index = [5:6 11:18 19:22];
    X(reset_index) = X0(reset_index);
    X = s.T*X;
end

events = [events X];
if(options.ifvideo) 
    aviobj.close(); 
end