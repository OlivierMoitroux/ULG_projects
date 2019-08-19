% Resolution question 3
format bank;
% Importation des donnees
load('FJE.mat');

% Q3.a
disp('1) Cout moyen lie a la necessite de reparer une machine et calcul de la variance');
[Cmoy_F, Cmoy_J, Cmoy_E] = coutMoyen(FJE)
[Cvar_F, Cvar_J, Cvar_E] = coutVariance(FJE)

% Q3.b
disp('2) Esperance et variance du budget total de maintenance des machines');
[esp_CoutTot, var_CoutTot] = espVar_CoutTot(FJE)

% Q3.c
disp('3) Esperance et variance conditionnelles de la fonction cout connaissant F');
[esp_CoutCond, var_CoutCond, espTot, varTot] = espVar_CoutCond(FJE)

% Export
% matrix2latex([esp_CoutCond var_CoutCond],'Q3d.tex','alignment','c');


