%% Mass
m_cart = 0.5;               % Mass of the cart (500g)
m_shaft = 100*10^-3;        % Mass of the shaft (100g)
m_cam = 116*10^-3;          % Mass of the gropro camera (116g)
m_pend = m_shaft + m_cam;   % Mass of the pendulum
m_tot = m_cart+ m_pend;

%% Dimensions
l_shaft = 300*10^-3;       % Length of shaft (30 cm)
l_cam = 44.9*10^-3;        % Length/height of camera (4,49 cm)

l_cm = l_shaft/2 + ((l_cam+l_shaft)/2) * (m_cam/(m_cam+m_shaft));
                           % Distance to center of mass of the pendulum
%% Other constants:
b = 0.1;                    % Coef. of friction for cart
g = 9.8;                    % Gravity

%% Inertia
I = m_cam*(l_cam/2+l_shaft)^2 + (1/12)*m_shaft*l_shaft^2;
%I = 0.06;
                            % Inertia of the pendulum
                            
q = (m_cart+m_pend)*(I+m_pend*l_cm^2)-(m_pend*l_cm)^2;
                            % Coef. to ease encoding (see report)
                            