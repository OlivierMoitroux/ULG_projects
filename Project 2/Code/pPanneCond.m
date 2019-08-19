function [P_panneJ] = pPanneCond(FJE)
% Calcule la probabilite que la machine J tombe en panne si les deux autres
%sont considerees a coup sur comme operationnelles
% IN : FJE
% OUT : P_panneJ

% Initialisation
[PCj_FE, ~, ~] = pConditionnelle(FJE);
P_panneJ = 0;

% Calcul des probabilites se rapportant aux 4 pannes
% envisageables

for j=2:length(FJE(1,:,1))
    P_panneJ = P_panneJ + PCj_FE(1,j,1);
end

end
