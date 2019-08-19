function [esp_CoutCond, var_CoutCond, espTot, varTot] = espVar_CoutCond(FJE)
% Calcule l'esperance conditionnelle et la variance conditionnelle de la
% fonction cout phi connaissant F. Fournit egalement la preuve des theoremes de
% l'esperance totales et de la variance totale via espTot et varTot
% IN : FJE
% OUT : [esp_CoutCond, var_CoutCond, espTot, varTot]

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));
[Cout_F, Cout_J, Cout_E] = importCouts(); % a adapter si FJE change

esp_CoutCond = zeros(max([hauteur, largeur, profondeur]),1);
tmp = zeros(max([hauteur, largeur, profondeur]),1);

% Calcul des probabilites marginales
Pm_F = pMarginale(FJE, 'F');

% Esperance de phi sachant que F = i (et terme temporaire pour la variance)
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            esp_CoutCond(f)=esp_CoutCond(f)+(Cout_F(f)+Cout_J(j)+Cout_E(e))*(FJE(f,j,e)/Pm_F(f));
            tmp(f)=tmp(f)+(Cout_F(f)+Cout_J(j)+Cout_E(e)).^2*(FJE(f,j,e)/Pm_F(f));
        end
    end
end

% Variance de phi sachant que F = i
var_CoutCond = tmp - esp_CoutCond.^2;

% Calcul de l'esperance totale
espTot = 0;
for f=1:hauteur
    espTot = espTot + esp_CoutCond(f)*Pm_F(f);
end

% Calcul de la variance totale
t1 = 0; % 1er terme de l'equ.
t2 = 0; % 2e terme de l'equ

for f=1:hauteur
    t1 = t1 + ( (esp_CoutCond(f) - espTot)^2 )*  Pm_F(f);
end

for f=1:hauteur
    t2 = t2 + var_CoutCond(f)* Pm_F(f);
end

varTot = t1 + t2;

end
