%% Declarations of variables (in brackets are the units if they 

ImportRobotProperties;

%% Full state space

% Pendulum linearization choice
% {up, down} = {1, -1}
up_down = 1;
u_d = up_down;

den = I*(m_cart+m_pend)+m_cart*m_pend*l_cm^2;    
                            % common denominator in A and B matrices

% /!\ Signs are different compared to control bootcamp !
A = [0      1              0           0;
     0 -(I+m_pend*l_cm^2)*b/den  (m_pend^2*g*l_cm^2)/den   0;
     0      0              0           1;
     0 -u_d*(m_pend*l_cm*b)/den       u_d*m_pend*g*l_cm*(m_cart+m_pend)/den  0];
 A_full = A;

B = [     0;
     (I+m_pend*l_cm^2)/den;
          0;
        u_d*m_pend*l_cm/den];
B_full = B;

C = [1 0 0 0;
     0 0 1 0];
 % C = [1 0 0 0] is enough

D = zeros(size(C,1), size(B,2));

states = {'x' 'x_dot' 'phi' 'phi_dot'};
inputs = {'F'};
outputs = {'x'; 'phi'};

disp('Full state space representation:')
sys = ss(A,B,C,D, 'statename', states, 'inputname', inputs, ...
    'outputname', outputs) % state space

%% Reduced state space representation
A_red = A(2:end, 2:end);
B_red = B(2:end);
%C = [1 0 0]; % measure x dot -> det(gram(sys, 'o')) = 0.996
%C = [0 1 0]; % measure theta -> det(gram(sys, 'o')) = 0.137
C_red = [0 0 1]; % measure theta dot -> det(gram(sys, 'o')) = 0.0126
D_red = D(2:end);

states_red = {'x_dot' 'phi' 'phi_dot'};
inputs = {'F'};
outputs_red = {'phi'};
disp('Reduced state space representation:')
sys_red = ss(A_red,B_red,C_red,D_red, 'statename', states_red, 'inputname', inputs, ...
    'outputname', outputs_red) % state space


%set(sys_tf,'InputName',inputs)
%set(sys_tf,'OutputName',outputs)
%sys_tf
% ss2tf() à creuser


% det(gram(sys,'o')) with position down because it is uild on e^t and blows
% up otherwise



