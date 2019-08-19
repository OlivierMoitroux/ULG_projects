function[Cmoy_F, Cmoy_J, Cmoy_E] = coutMoyen(FJE)
% Détermine les couts moyens lies a la nécessite de reparer chacune des
% machines
% IN : FJE
% OUT : [Cmoy_F, Cmoy_J, Cmoy_E]

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));
[cout_F, cout_J, cout_E]=importCouts;% a adapter si FJE change

% Calcul des probabilites marginales
Pm_F = pMarginale(FJE, 'F');
Pm_J = pMarginale(FJE, 'J');
Pm_E = pMarginale(FJE, 'E');

% Initialisation 2
Cmoy_F = 0;
Cmoy_J = 0;
Cmoy_E = 0;

% Calcul des couts moyens

% Maintenance de F
for k=1:hauteur
    Cmoy_F = Cmoy_F + cout_F(k)*Pm_F(k);
end

% Maintenance de J
for k=1:largeur
    Cmoy_J = Cmoy_J + cout_J(k)*Pm_J(k);
end

% Maintenance de E
for k=1:profondeur
    Cmoy_E = Cmoy_E+cout_E(k)*Pm_E(k);
end

end