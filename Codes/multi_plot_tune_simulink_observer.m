
%% Setting parameters

%x0 = [.01, 0, 0, 0, 0, 0, 0, 0];
simin_disturbance = 0;
simin_r =0.2*ones(size(t)); % disturbance applied on F
simin_delay = 0.001;

%% Tuning parameters
zeta = [0.25, 0.5, 0.75, 1];
% zeta = 75 et omega = 62.7 bonne pratique
omega_o = [45, 100, 450];

figure('name', 'Tweaking zeta observer');

%% test on zeta
for i = 1:4
    s1 = -zeta(i) *omega_o(1) + omega_o(1) *sqrt(1-zeta(i)^2);
    s2 = -zeta(i) *omega_o(1) - omega_o(1) *sqrt(1-zeta(i)^2);
    s3 = real(s1)*2;
    s4 = s3+0.01;
    Poles = [s1, s2, s3, s4];
    L_tuning = place(A',C',Poles)';
    
%     simout = sim('observer_tuning','StartTime','0','StopTime','10','FixedStep','0.0001');
    sim('observer_tuning');
    plot(simout_x_hat.Time, simout_x_hat.data(:,3), '--');
    hold on;
end
plot(simout_x_true.Time, simout_x_true.data(:,3));
legend('\zeta_o = 0.25', '\zeta_o = 0.5', '\zeta_o = 0.75', '\zeta_o = 1', 'true angle');
xlabel('Time (s)')
ylabel('States')
title('Time response of controlled system to constant input with observer')

%% Test on omega
figure('name', 'Tweaking omega observer');
for i = 1:3
    s1 = -zeta(2) *omega_o(i) + omega_o(i) *sqrt(1-zeta(2)^2);
    s2 = -zeta(2) *omega_o(i) - omega_o(i) *sqrt(1-zeta(2)^2);
    s3 = real(s1)*2;
    s4 = s3+0.01;
    Poles = [s1, s2, s3, s4];
    L_tuning = place(A',C',Poles)';
    
%     simout = sim('observer_tuning','StartTime','0','StopTime','10','FixedStep','0.0001');
    sim('observer_tuning');
    plot(simout_x_hat.Time, simout_x_hat.data(:,3), '--');
    hold on;
end
plot(simout_x_true.Time, simout_x_true.data(:,3));
legend('\omega_o = 45', '\omega_o = 50', '\omega_o = 450','true angle');
xlabel('Time (s)')
ylabel('States')
title('Time response of controlled system to constant input with observer')

% set(gcf, 'renderer', 'opengl')