function[P]=pPanne(FJE)
% Fonction qui calcule la probabilite que la chaine de production tombe en
% panne au cours du prochain mois
% IN : FJE
% OUT : P

% Résolution
P = 1-FJE(1,1,1);

end