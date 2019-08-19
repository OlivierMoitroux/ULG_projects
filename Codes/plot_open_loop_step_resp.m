function [] = plot_open_loop_step_resp(sysTf)
%PLOTOPENLOOPSTEPRESPONSE Summary of this function goes here
%   Detailed explanation goes here
figure('name', 'Open lopp step response (lsim F = 1 for 10 seconds)')
t = 0:0.05:10;
u = ones(size(t));
[y,t] = lsim(sysTf,u,t);
plot(t,y)
title('Open-Loop Step Response')
axis([0 3 0 50])
legend('x','phi')
xlabel('Time (s)')
ylabel('Amplitude')

end

