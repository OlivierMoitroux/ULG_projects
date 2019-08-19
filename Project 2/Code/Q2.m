% Resolution question 2
format bank;
% Importation des donnees 
load('FJE.mat');

% Q2.a
disp('1) Probabilite que la chaine de production tombe en panne le mois prochain');
P_panne = pPanne(FJE)

% Q2.b
disp('2) Probabilite que J tombe en panne si F et E ont ete controlees');
P_panneJ = pPanneCond(FJE)