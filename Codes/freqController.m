function [Cs] = freqController(P_pend, K, alpha, graph)
    %% Defining variables
    % Proportional Gain
    % K = 10;

    % Transfer function variable
    s = tf('s');

    % System transfer function
    % P_pend = (m_pend*l_cm*s/q)/(s^3 + (b*(I + m_pend*l_cm^2))*s^2/q - ((m_cart + m_pend)*m_pend*g*l_cm)*s/q - b*m_pend*g*l_cm/q);

    % Controller transfer function
    Cs = K*(s+1)*(s+alpha)/s;

    % Time interval for response graph
    t = 0:0.001:10;

    %% Computing Gang of Four 

    % L(s)
    Ls = P_pend*Cs;

    % S(s)
    Ss = 1/(1+Ls);

    % T(s)
    Ts = Ls/(1+Ls);

    % PS(s)
    PSs = P_pend/(1+Ls);

    % CS(s)
    CSs = Cs/(1+Ls);

    %% Bode diagrams

    if(graph)
        figure('name', 'Ss');
        bode(Ss)

        figure('name', 'Ts');
        bode(Ts)

        figure('name', 'Ls');
        bode(Ls)
    end

    %% Response of the system to an impulse

    T = feedback(P_pend, Cs);

    figure('name', 'Impulse response in frequency domain');
    impulse(T, t), grid
end