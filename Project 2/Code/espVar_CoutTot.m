function[esp_CoutTot, var_CoutTot]= espVar_CoutTot(FJE)
% Calcule l'esperance et la variance de la fonction de cout liee a
% l'entretien de l'ensemble de la chaine de production.
% IN : FJE
% OUT : [esp_CoutTot, var_CoutTot]

% Importation des donnees
[cout_F, cout_J, cout_E] = importCouts;

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));
esp_CoutTot = 0;
var_CoutTot = 0;

% Esperance de la fonction de cout :
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            esp_CoutTot = esp_CoutTot + FJE(f,j,e)*(cout_F(f)+cout_J(j)+cout_E(e));
        end
    end
end

% Variance de la fonction de cout :
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            var_CoutTot= var_CoutTot+FJE(f,j,e)*(cout_F(f)+cout_J(j)+cout_E(e))^2;
        end
    end
end

var_CoutTot = var_CoutTot - esp_CoutTot^2;

end
