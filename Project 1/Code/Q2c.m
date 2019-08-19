function [ Sol ] = Q2c( N, Display)
%Q2.C Fonction qui calcule la moyenne (variance) de l'esp�rance et la moyenne
%(variance) de la variance et prenant en arguments un vecteur contenant
%les dimensions souhait�es des vecteur (binaires dont les �l�ments sont 
%obtenus en utilisant la fonction birthday40.m) ainsi qu'optionellement, 
%une valeur bool�enne servant � activer/d�sactiver l'affichage du r�sultat
%et du temps d'ex�cution.
%
%   IN : N, [Display (0/1)]
%   OUT : le tableau "Solution" avec pour indices
%   Sol(i,1) la moyenne de l'esp�rance pour "la dimension N(i)"
%   Sol(i,2) la variance de l'esp�rance pour "la dimension N(i)"
%   Sol(i,3) la moyenne de la variance pour "la dimension N(i)"
%   Sol(i,4) la variance de la variance pour "la dimension N(i)"

% Donn�es
% N = [10 10^2 10^3 10^4];

% Par d�faut, affichage des r�sultats
if(nargin<2)
    Display = 1;
end

% Initialisation
NBRE_EXP = 1000;
MeanVect = zeros(1,NBRE_EXP);
VarVect = zeros(1,NBRE_EXP);
Length = length(N);
Sol = zeros(Length, 4);
tic;
% Pour chaque dimension de vecteur dans N:
for i = 1:Length
    Array = zeros (1,N(i));
    % Pour une moyenne sur NBRE_EXP
    for j = 1 : NBRE_EXP
        % Pour chaque �l�ment du vect de dim N(i)
        for k = 1 : N(i)
            Array(k) = birthday40;
        end
        % Calcul de la moyenne :
        MeanVect(j) = mean(Array);
    
        % Calcul de la variance
        VarVect(j) = var(Array,1);  
    end
    % Moyenne de l'esp�rance
    Sol(i,1) = mean(MeanVect);

    % Variance de l'esp�rance
    Sol(i,2) = var(MeanVect,1);

    % Moyenne de la variance
    Sol(i,3) = mean(VarVect);

    % Variance de la variance
    Sol(i,4) = var(VarVect,1);
    t = toc;
    if Display == 1
        disp(['N = ' num2str(N(i)) ' : [' num2str(Sol(i,:)) '] ; t = ' num2str(t) ' s']);
    end
end
end
