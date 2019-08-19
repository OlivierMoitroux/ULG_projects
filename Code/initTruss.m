% Initialisation treillis

N = 10000;

iStructure = 3;

switch iStructure
    
    case 1
        L = 3;
        H = 3;
        Nodes.XNOD = [0 1 2 1] * L;       % m
        Nodes.YNOD = [0 0 0 1] * H;       % m
        
        EA0 = (8000 * 50*50);             % N
        
        Elements.ELEMNOA = [1 2 3 4 4];
        Elements.ELEMNOB = [2 3 4 1 2];
        ELEM_EA_0 = [1 1 1 1 1] * EA0;  % valeur de EA pour chaque barre
        
        Appui = [1 1; 1 2; 3 2]; % N° de noeud, n° de DDL (1 ou 2) - autant de lignes que d'appuis
        
        ddlNames = ["x_1" "x_2" "y_2" "x_3" "y_3"];
        
        Force = [2 2 -1000]; %N° de noeud, n° de ddl (1 ou 2), charge nodale  - autant de lignes que de force
        
    case 2 % seconde structure en treillis proposée dans le cadre du projet
        L = 1.5;
        H = 2;
        Nodes.XNOD = [-2 -2 -1 -1 0 0 1 1 2 2] * L;       % m
        Nodes.YNOD = [0 1 0 1 0 1 0 1 0 1] * H;       % m
        
        EA0 = (8000 * 50*50);             % N
        
        % TO DO : continuer a adapter les valeurs à la deuxieme structure
        Elements.ELEMNOA = [6 8 10 12 14 6 8 10 12 5 7 9 11 6 8 12 14 8 10 10 12] - 4; % Barres verticales - Horizontales superieures - Horizontales inferieures - Obliques
        Elements.ELEMNOB = [5 7 9 11 13 8 10 12 14 7 9 11 13 7 9 9 11 5 7 11 13] - 4; % Barres verticales - Horizontales superieures - Horizontales inferieures - Obliques
        ELEM_EA_0 = ones(1, 21) * EA0;  % valeur de EA pour chaque barre
        
        Appui = [5-4 1; 5-4 2; 13-4 1; 13-4 2]; % N° de noeud, n° de DDL (1 ou 2) - autant de lignes que d'appuis
        
        ddlNames = ["x_6" "y_6" "x_7" "y_7" "x_8" "y_8" "x_9" "y_9" "x_{10}" "y_{10}" "x_{11}" "y_{11}" "x_{12}" "y_{12}" "x_{14}" "y_{14}"];
        
        Force = [7-4 2 -500; 9-4 2 -500; 11-4 2 -500]; %N° de noeud, n° de ddl (1 ou 2), charge nodale  - autant de lignes que de force
        
    case 3 % [optionel] votre structure en treillis
        L = 3;
        H = 3;
        Nodes.XNOD = [0 0 1 1 2] * L;       % m
        Nodes.YNOD = [0 1 0 1 0] * H;       % m
        
        EA0 = (8000 * 50*50);             % N
        
        Elements.ELEMNOA = [18 16 15 17 16 18 18] - 14;
        Elements.ELEMNOB = [17 18 17 19 17 15 19] - 14;
        ELEM_EA_0 = ones(1, 7) * EA0;  % valeur de EA pour chaque barre
        
        Appui = [15-14 1; 15-14 2; 16-14 1; 16-14 2]; % N° de noeud, n° de DDL (1 ou 2) - autant de lignes que d'appuis
        
        ddlNames = ["x_{17}" "y_{17}" "x_{18}" "y_{18}" "x_{19}" "y_{19}"];
        
        Force = [19-14 2 -500]; %N° de noeud, n° de ddl (1 ou 2), charge nodale  - autant de lignes que de force
               
end

NElem = length(Elements.ELEMNOA);
NNode = length(Nodes.XNOD);

NDdl = 2 * NNode - length(Appui);

Elements.ELEM_EA = ELEM_EA_0;

% construire les éléments essentiels de l'analyse
[K_0, p, Ke_0, B_0, Re_0, Be_0] = BuildStructure(Nodes,Elements,Appui,Force);

% résoudre 
X_0 = K_0 \ p;        % contient tous les degrés de liberté NON bloqués (=libres)
Fint_0 = B_0 * X_0;     % calcul des forces intérieures (efforts axiaux) dans toutes les barres

% plot déterministe
ampl = 500;  % amplification de la déformée
Display(Nodes, Elements, Appui, X_0, ampl)  % dessin de la déformée
title('Déformée')
axis equal
