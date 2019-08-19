function [] = simCartPend(time, y_0, u_d, disturbance)

if exist('m_cart','var') == 0
    ImportRobotProperties;
end

% time = 10
%y0 = [0; 0; pi; .5];
% disturbance = .01*randn;
tspan = 0:.1:time; 
[t,y] = ode45(@(t,y)cartPendEqu(y,u_d, disturbance,0),tspan,y_0);

for k=1:length(t)
    drawCartPend(y(k,:));
end
end

