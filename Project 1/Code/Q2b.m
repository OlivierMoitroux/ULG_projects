function [Solution] = Q2b( N )
%Q2B fonction qui renvoit l'espérance et la variance de vecteurs binaires
%(de taille spécifiée dans le vecteur N) et dont les éléments sont générés par la fonction birthday40.m
%   IN : N, un vecteur contenant un certains nombre de dimension(s) 
%   OUT : Solution t.q Solution(:,1) reprend les espérances et
%   Solution(:,2) les variances des vecteurs dont les dimensions respectives ont été spécifiées en entrée.


% Données :
% N = [10 , 10^2, 10^3, 10^4];

%Initialisation
Length = length(N);
Solution = zeros(Length,2);

% Pour l'affichage
fprintf('\t\t\t Espérance: \t Variance:\n' );
for i =1:Length
    tab = zeros(1,N(i));
    for j=1:N(i)
        tab(j) = birthday40;
    end
    % Calcul de l'espérance via la fonction mean (sum(tab)/N) de MATLAB 
    Solution(i, 1) = mean(tab); % Espérance pour un vecteur de taille N(i)

    % Calcul de la variance via la fonction var de MATLAB 
    Solution(i,2) = var(tab,1);% Variance pour un vecteur de taille N(i)
    
    % Affichage des résultats
    fprintf('N = %d :\t\t', N(i));
    fprintf('%s \t\t %s \n', num2str(Solution(i,1)), num2str(Solution(i,2)));
end
end
