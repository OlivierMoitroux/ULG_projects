function [] = response_plot(sys, figName, fullPlot, timeImpulse)
%STEP_RESPONSE_TEST Summary of this function goes here
%   Detailed explanation goes here

if fullPlot == 1
    %% lsim (constant input at 0.2)
    figure('name', strcat(figName, 'lsim contant input at 0.2 for 5 seconds'));
    t = 0:0.01:5;
    r =0.2*ones(size(t)); % disturbance applied on F
    plot(t,r)
    [y,t,x]=lsim(sys,r,t);

    [AX,~,~] = plotyy(t,y(:,2), t,y(:,1),'plot');
    set(get(AX(2),'Ylabel'),'String','cart position (m)')
    set(get(AX(1),'Ylabel'),'String','pendulum angle (radians)')
    xlabel('Time (s)')
    title('Time response of controlled system to constant input')
    
    %% Plot all the states
    figure('name', strcat(figName, 'lsim contant input at 0.2 for 5 seconds with states'));
    % plot(t, y(:,2), '--', t, x, '--');
    % legend('y','x', 'xdot', 'psi', 'psi dot');
    plot(t, y(:,2),t, x(:,4),t, x(:, 1), '--', t, x(:,2), '--');
    legend('psi', 'psi dot', 'x', 'xdot');
    xlabel('Time (s)')
    ylabel('States')
    title('Time response of controlled system to constant input')
    
    %% Square oscillation response
    figure('name', strcat(figName, 'square wave impulse'));
    sysTf = tf(sys);
    [r,t] = gensig('square',2*timeImpulse,10,0.01); % 4.4
    r = r/5;
    lsim(sysTf,r,t);
    

else   
    %% lsim (constant input at 0.2)
    figure('name', strcat(figName, 'lsim contant input at 0.2 for 5 seconds'));
    t = 0:0.01:5;
    r =0.2*ones(size(t)); % disturbance applied on F
    plot(t,r)
    [y,t,x]=lsim(sys,r,t);

    plot(t,y(:,2));
    ylabel('Pendulum angle (radians)')
    xlabel('Time (s)')
    title('Time response of controlled system to constant input')

end


%% Step and impulse response
figure('name', strcat(figName, 'step and impulse'));
subplot(2,1,1)
step(sys)
subplot(2,1,2)
impulse(sys)

%figure('name', 'export');
%tmp = tf(sys);
%impulse(tmp(2), [0:0.001:3])




end

