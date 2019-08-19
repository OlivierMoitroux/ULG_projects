% Resolution de la question 1
format bank;
% Importation des donnees
load('FJE.mat')

% Probabilites marginales
disp('a) Probabilites marginales :');
Pm_F = pMarginale(FJE, 'F')
Pm_J = pMarginale(FJE, 'J')
Pm_E = pMarginale(FJE, 'E')

% Export vers latex
% matrix2latex([Pm_F Pm_J Pm_E],'Q1a.tex','alignment','c');

% Probabilites conjointes
disp('b) Probabilites conjointes :');
[Pc_FE, Pc_FJ, Pc_JE] = pConjointe(FJE)

% Probabilites conditionnelles
disp('c) Probabilites conditionnelles :');
[PCj_FE, PCe_FJ, PCf_JE] = pConditionnelle(FJE)
