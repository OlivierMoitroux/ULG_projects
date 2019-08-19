function[Cvar_F, Cvar_J, Cvar_E] = coutVariance(FJE)
% Calcule les variances des couts engendres par
% la maintenance de toutes les machines
% IN : FJE
% OUT : [Cvar_F, Cvar_J, Cvar_E]

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));
[Cout_F, Cout_J, Cout_E] = importCouts(); % a adapter si FJE change
Cvar_F = 0;
Cvar_J = 0;
Cvar_E = 0;

% Calcul des probabilites marginales
Pm_F = pMarginale(FJE, 'F');
Pm_J = pMarginale(FJE, 'J');
Pm_E = pMarginale(FJE, 'E');

% Calcul des couts moyens
[Cmoy_F, Cmoy_J, Cmoy_E] = coutMoyen(FJE);

% Calcul de la variance des couts de F
for k=1:hauteur
    Cvar_F = Cvar_F +(Cout_F(k)^2)*Pm_F(k);
end
Cvar_F = Cvar_F - Cmoy_F^2;

% Calcul de la variance des couts de J
for k=1:largeur
    Cvar_J = Cvar_J + (Cout_J(k)^2)*Pm_J(k);
end
Cvar_J = Cvar_J - Cmoy_J^2;

% Calcul de la variance des couts de E
for k=1:profondeur
    Cvar_E = Cvar_E + (Cout_E(k)^2)*Pm_E(k);
end
Cvar_E = Cvar_E - Cmoy_E^2;

end
