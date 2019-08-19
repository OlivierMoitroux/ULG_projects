clearvars;
clc;
close all;

%% -----------------------------STATE SPACE-------------------------------%
disp('1) State space representation');
ImportStateSpace;

%% ------------------------- Observability -------------------------------%

disp('2) Observability and controllability');
% Observability Matrix :
Wo = obsv(A, C);

% Full rank ?
isObservable = (rank(Wo)==length(states));
disp(string({'The system is observable:',isObservable}));

if u_d == -1
    % Check the volume of the observability ellipsoid:
    volume_obsv_ellipsoid = det(gram(sys_red, 'o'));
end

%% ------------------------- Controllability -----------------------------%

%Controllability matrix :
Wr = ctrb(A,B);

% Wr = [B A*B (A*A)*B A*A*A*B];
detWr = det(Wr);

% Full rank ?
isControllable = (rank(Wr)==length(states));
disp(string({'The system is controllable:',isControllable}));


%% -------------------------Transfer functions----------------------------%

disp('3) Transfer functions');
s = tf('s');

% Manual way (analytical expression from report):
tfCart = (((I+m_pend*l_cm^2)/q)*s^2 - (m_pend*g*l_cm/q))/(s^4 + (b*(I + m_pend*l_cm^2))*s^3/q - ((m_cart + m_pend)*m_pend*g*l_cm)*s^2/q - b*m_pend*g*l_cm*s/q);
tfPend = (m_pend*l_cm*s/q)/(s^3 + (b*(I + m_pend*l_cm^2))*s^2/q - ((m_cart + m_pend)*m_pend*g*l_cm)*s/q - b*m_pend*g*l_cm/q);
sysTf = [tfCart; tfPend]
set(sysTf,'InputName',inputs)
set(sysTf,'OutputName',outputs)

tfPendNum = cell2mat(tfPend.Numerator);
tfPendDen = cell2mat(tfPend.Denominator);

% Via Matlab (same as before but the denominator is such that the coef 
% of the cubed term is 1 + some round-off errors accumulated and epsilon 
% machine):
sysTfAuto = tf(sys)

% clean workspace for robot properties
clearvars den g I l_cam l_cm l_shaft m_cam m_cart m_pend m_shaft q

zeroOfTf = zpk(tfPend)
zeroOfTfAuto = zpk(sys) %Gain/pole/zero representation of sys

%% -------------------------Pole and stability----------------------------%
disp('4) Pole and stability');
% Poles for psi
poles = pole(sys) % pole(tfPend)==pole(sys)==pole(sysTf)== eig(A) 
isStable = isstable(sys);

plot_poles(sys, sysTf)

disp(string({'The system in open-loop is stable:', isStable}));

%% ---------------------O.L. Cart simulation -----------------------------%
simCartPend(10, [0; 0; pi; .5], -1, .01*randn)
simCartPend(10, [0; 0; 0; .5], -1, .01*randn)


%% ---------------------Open-loop impulse response------------------------%
disp('5) Response to impulse in open-loop configuration');
figure('name', 'Impulse in open-loop configuration');
t=0:0.01:1;
impulse(sysTf,t);
%title('Response to an impulse in Open-Loop configuration')

%% -----------------------Open-loop step response-------------------------%
disp('6) Step response in open-loop configuration');
plot_open_loop_step_resp(sysTf);
% Can get settling time via lsiminfo(y,t);->(2);->.SettlingTime;

%% ----------------------- State feedback controler ----------------------%
% a) Pole placement
eigs = [-4.774+5.9172i; -4.774-5.9172i; -10.1; -10.2];
K = place(sys.A, sys.B, eigs);
Ac = [(sys.A-sys.B*K)];Bc = [sys.B];Cc = [sys.C];Dc = [sys.D];
sysCl = ss(Ac,Bc,Cc,Dc,'statename',states,'inputname',inputs,'outputname',outputs);
response_plot(sysCl, 'Pole placement controlled system:', 0, 2.2);

%%
% b) LQR
[K_lqr, Q] = myLQR(sys, 1);
Ac_LQR = [(sys.A-sys.B*K_lqr)];
sysCl_LQR = ss(Ac_LQR,Bc,Cc,Dc,'statename',states,'inputname',inputs,'outputname',outputs);
response_plot(sysCl_LQR, 'LQR controlled system:', 0, 2.2);


%% Reference tracking
% Feedforward gain to track reference: y(t)~= r(t), t->+inf

%%
kr = -1/(C*inv(A-B*K)*B);
sysCart = ss(Ac,Bc*kr(1),Cc,Dc,'statename',states,'inputname',inputs,'outputname',outputs);

response_plot(sysCart, 'Pole placement controlled cart system with precompensator:', 1, 2.2);
%%
kr_LQR = -1/(C*inv(A-B*K_lqr)*B);
sysCart_LQR = ss(Ac_LQR,Bc*kr_LQR(1),Cc,Dc,'statename',states,'inputname',inputs,'outputname',outputs);
response_plot(sysCart_LQR, 'LQR controlled cart system with precompensator:', 1, 2.2);


%% ----------------------------- Observer --------------------------------%
%% Easy way, put poles 10x deeper in the left-half plane:
polesAc = eig(Ac);
base = max(real(polesAc))*10;
P = [base base-1 base-2 base-3];
L = place(A',C',P)'
[Ace, Bce, Cce, Dce] = responseObserver(sys, L, K, kr(1))

%% Pole placement (via Matlab):
multi_plot_tune_observer(sys, K, kr(1), sysCart);
%multi_plot_tune_observer2(sys, K, kr(1), sysCart);

%% Pole placement (via Simulink)
multi_plot_tune_simulink_observer;

%% ----------------------Frequency control--------------------------------%
%% Gentle approach
[Cs] = freqController(tfPend, 10, 1, 1);

%% More aggressive
[Cs] = freqController(tfPend, 20, 10, 1);
Cs_num = cell2mat(Cs.Numerator);
Cs_den = cell2mat(Cs.Denominator);

%% Test for the simulink
delay_freq=0.001;
test = Cs*tfPend;
test_num = cell2mat(test.Numerator);
test_den = cell2mat(test.Denominator);
% Not finished
%sim('closed_loop_freq_todo.slx');




