function dy = cartPendEqu(y, u_d, disturbance, u)

% /!\ y is a stupid notation of matlab that should not be confused with 
% the output: it is in fact the state x for us /!\
if exist('m_cart','var') == 0
    ImportRobotProperties;
end

den = I*(m_cart+m_pend)+m_cart*m_pend*l_cm^2;    

A_22 = -(I+m_pend*l_cm^2)*b/den;
A_23 = (m_pend^2*g*l_cm^2)/den;
A_42 = -u_d*(m_pend*l_cm*b)/den;
A_43 = u_d*m_pend*g*l_cm*(m_cart+m_pend)/den;

B_2 = (I+m_pend*l_cm^2)/den;
B_4 = u_d*m_pend*l_cm/den;



dy(1,1) = y(2);
dy(2,1) = A_22*y(2) + A_23*y(3)+ B_2*u;
dy(3,1) = y(4);
dy(4,1) = A_42*y(2) + A_43*y(3) + B_4*u + disturbance;

% d dans bootcamp = dissipation

% tspan = 0:.1:10;
% y0 = [0; 0; pi; .5];
% [t,y] = ode45(@(t,y)cartpend(y,m,M,L,g,d,0),tspan,y0);
% 
% for k=1:length(t)
%     drawcartpend_bw(y(k,:),m,M,L);
% end