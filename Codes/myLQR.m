function [K, Q] = myLQR(sys, u_d)
%COMPUTE_GAIN Summary of this function goes here
%   Detailed explanation goes here

%% Variable declaration
Q = (sys.C)'*sys.C;
R = 1;

% Cost matrices
% Q = [1 0 0 0;
%     0 1 0 0;
%     0 0 10 0;
%     0 0 0 100];
%R = .0001;
% K = lqr(sys.A,sys.B,Q,R)
% Q(1,1) = 5200;
% Q(3,3) = 400;

% Quite fast version (beafier motors)
Q(1,1) = 5400;
Q(3,3) = 800;

% Slow version (smooth for less performant motors:)
% Q(1,1) = 4000;
% Q(3,3) = 8000;

K = lqr(sys.A, sys.B, Q, R);



%% Script
% tuningSpace = 1:1000:5000;
% [rId, cId] = find(Q);
% 
% vecK = zeros(length(tuningSpace), 4);
% 
% bestQValues = zeros(length(tuningSpace), 2);
% 
% i = 1;
% for a = tuningSpace
%     Q(rId(1), cId(1)) = a;
%     bestQValues(i, 1) = a;
%     cst = i;
%     for b = tuningSpace
%         Q(rId(2), cId(2)) = b;
%         bestQValues(i, 1) = a;
%         bestQValues(i, 2) = b;
%         vecK(i,:) = lqr(sys.A,sys.B,Q,R);
%         step_response_controlled(sys, vecK(i,:));
%         i = i +1;
%     end
% end
% K = vecK(22,:);
% bestQValues = bestQValues(22, :);
% 
% Q(1,1) = 4000;
% Q(3,3) = 1000;
% 
% 
%% Simulation
% tspan = 0:.001:15;
% if(u_d==-1)
%     y_0 = [0; 0; 0; 0];
%     [t,y] = ode45(@(t,y)cartPendEqu(y,u_d, .01*randn,-K*(y-[4; 0; 0; 0])),tspan,y_0);
% elseif(u_d==1)
%     y_0 = [-3; 0; pi+.1; 0];
% %     [t,y] = ode45(@(t,y)cartpend(y,m,M,L,g,d,-K*(y-[1; 0; pi; 0])),tspan,y0);
%     [t,y] = ode45(@(t,y)cartPendEqu(y,u_d, .01*randn, -K*(y-[1; 0; pi; 0])),tspan,y_0);
% else 
% end
% 
% for k=1:100:length(t)
%     drawCartPend(y(k,:));
% end
% 
% [T,D] = eig(sys.A-sys.B*K);
% diag(real(D))
% T(:,1)

end

