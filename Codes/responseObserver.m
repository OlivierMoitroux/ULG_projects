function [Ace, Bce, Cce, Dce] = responseObserver( sys, L, K, kr )
%RESPONSEOBSERVER Summary of this function goes here
%   Detailed explanation goes here
A = sys.A;
B = sys.B;
C = sys.C;
Cc = [C];
D = sys.D;
Ace = [(A-B*K) (B*K);
       zeros(size(A)) (A-L*C)];
Bce = [B*kr;
       zeros(size(B))];
Cce = [Cc zeros(size(Cc))];
Dce = [0;0];

states = {'x' 'x_dot' 'phi' 'phi_dot' 'e1' 'e2' 'e3' 'e4'};
inputs = {'u'};
outputs = {'x'; 'phi'};

sys_est_cl = ss(Ace,Bce,Cce,Dce,'statename',states,'inputname',inputs,'outputname',outputs);

%%
figure('name', 'Steady input of 0.2 for 5 seconds on ctrl system with observer and precompensator');
t = 0:0.01:5;
u = 0.2*ones(size(t));
[y,t,x]=lsim(sys_est_cl,u,t);
% [AX,H1,H2] = plotyy(t,y(:,1),t,y(:,2),'plot');
% set(get(AX(1),'Ylabel'),'String','cart position (m)')
% set(get(AX(2),'Ylabel'),'String','pendulum angle (radians)')
[AX,~, ~] = plotyy(t,y(:,2), t,y(:,1),'plot');
set(get(AX(2),'Ylabel'),'String','cart position (m)')
set(get(AX(1),'Ylabel'),'String','pendulum angle (radians)')

title('Step Response with Observer-Based State-Feedback Control')

%%
figure('name', 'Evolution of state variables with observer');
% plot(t, y(:,2), '--', t, x, '--');
% legend('y','x', 'xdot', 'psi', 'psi dot');
plot(t, y(:,2),t, x(:,4),t, x(:, 1), '--', t, x(:,2), '--', t, x(:,3));
legend('psi', 'psi dot', 'x', 'xdot', 'test');
xlabel('Time (s)')
ylabel('States')
title('Time response of controlled system to constant input with observer')


end

