function [ Solution ] = Q2cRecursif( N, NbreExperience)
%Q2.C Fonction qui prend en arguments la dimension souhait�e du vecteur
%(binaire dont les �l�ments sont obtenus en utilisant la fonction birthday40.m) ainsi
%qu'optionellement, le nombre d'exp�riences souhait�es pour le calcul de la
%moyenne (variance) de l'esp�rance et la moyenne (variance) de la variance.
%
%   IN : N, NbreExperience
%   OUT : le tableau "Solution" (le plus pr�cis si StatEnnabled =1) avec pour indices :
%   (1) la moyenne de l'esp�rance
%   (2) la variance de l'esp�rance
%   (3) la moyenne de la variance
%   (4) la variance de la variance

% Mettre cette variable � 1 si l'on veut le d�velloppement complet du
% tableau pour r�solution de la Q2c. Appel : Q2c(10)
tic;
StatEnnabled = 1;

% Si NbreExperience pas sp�cifi�, valeur par d�faut.
if nargin < 2
    NbreExperience = 1000;
end

Array = zeros (1,N);
MeanVect = zeros(1,NbreExperience);
VarVect = zeros(1,NbreExperience);
for i = 1 : NbreExperience
    for j = 1 : N
        Array(j) = birthday40;
    end
    % Calcul de la moyenne :
    MeanVect(i) = mean(Array);
    
    % DOC : "Y = var(X,1) normalizes by N and produces the second moment of
    % the sample about its mean"
    VarVect(i) = var(Array,1);  
end
% Moyenne de l'esp�rance
Solution(1) = mean(MeanVect);

% Variance de l'esp�rance
Solution(2) = var(MeanVect,1);

% Moyenne de la variance
Solution(3) = mean(VarVect);

% Variance de la variance
Solution(4) = var(VarVect,1);

if StatEnnabled == 1
    t = toc;
    disp(['N = ' num2str(N) ' : [' num2str(Solution) '] ; t = ' num2str(t) ' s']);
    % On ne va pas plus loin que 10^4 ( tps execution)
    if(N < 10^4)
        Q2c(N*10 , NbreExperience);
    end
end

end
