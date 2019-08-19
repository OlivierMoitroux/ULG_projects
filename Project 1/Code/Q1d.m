function [Prob, t] = Q1d( N, Display )
% Q1d
%   Résolution de la question 1d:
%   a) Détermine la probabilité pour qu'au min 2 personnes parmi N  aient leur
%   anniversaire le même jour
%   b) Mesure le temps d'exécution.
%   c) Affiche le résultat ( argument Display optionnel)
%   IN : N, vecteur reprenant les différentes dimensions ; [Display (o/1)]
%   OUT : a) => Prob ; b) => t

% Données :
% N = [2 3 4 5 20 30 40 50 60 80];

% Affichage par défaut
if nargin<2
    Display = 1;
end

% Initialisation (plus rapide et recommandé pour les boucles)
Length = length(N);
t = zeros(1,Length);
Prob = ones(1,Length);

for i = 1:Length
    tic;
    for j = 1:N(i)-1
        % Prob tous différents
        Prob(i) = Prob(i) * (365 - j)/365;
    end
    
    % Prob meme jour = 1 - (prob tous différents)
    Prob(i) = 1 - Prob(i);
    
    % Fin mesure du temps
    t(i) = toc;
end
if Display == 1
    disp(['Solution : ' num2str(Prob)]);
    disp(['Temps (s) : ' num2str(t)]);
end
end