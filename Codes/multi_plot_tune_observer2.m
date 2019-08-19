function [L] = multi_plot_tune_observer2(sys, K, kr, sysCart)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

A = sys.A;
B = sys.B;
C = sys.C;
Cc = [C];
D = sys.D;
Bce = [B*kr; B];%, zeros(size(B))
Cce = [Cc zeros(size(Cc))];
Dce = [0;0];
states = {'x_true' 'x_dot_true' 'phi_true' 'phi_dot_true' 'x_est' 'x_dot_est' 'psi_est' 'psi_dot_est'};
inputs = {'u'};
outputs = {'x'; 'phi'};

zeta = [0.25, 0.5, 0.75, 1];
% zeta = 75 et omega = 62.7 bonne pratique
omega_o = [45, 100, 450];
figure('name', 'Tweaking observer');
t = 0:0.01:5;
r =0.2*ones(size(t));

% start with x_est and psi_test different from the true states
x0 = [0, 0, 0, 0, .01, 0, .01, 0]; 

%% test on zeta
for i = 1:4
    s1 = -zeta(i) *omega_o(1) + omega_o(1) *sqrt(1-zeta(i)^2);
    s2 = -zeta(i) *omega_o(1) - omega_o(1) *sqrt(1-zeta(i)^2);
    s3 = real(s1)*2;
    s4 = s3+0.01;
    Poles = [s1, s2, s3, s4];
    L = place(A',C',Poles)';
    
    Ace = [A zeros(size(A));
       (L*C) (A-L*C)];
    sysCl_est = ss(Ace,Bce,Cce,Dce,'statename',states,'inputname',inputs,'outputname',outputs);
    
    [y_est,t,x_est]=lsim(sysCl_est,r,t, x0);
    plot(t, x_est(:,7)); %t, y_est(:,2) ,t, x(:,3) | y(:,2)
    hold on;
    
    
end
[y_true,t,x_true] = lsim(sysCart, r, t);
plot(t, x_true(:,3));
% [y_true,t,x_true] = lsim(sysCl_est, r, t);
% plot(t, x_true(:,3));
legend('\zeta = 0.25', '\zeta = 0.5', '\zeta = 0.75', '\zeta = 1', 'x_{true}');
xlabel('Time (s)')
ylabel('States')
title('Time response of controlled system to constant input with observer')

%% test on omega
% TODO
% Useless, the above don't even work ...

end

