function [Sol] = Q2d( N, Display)
%Q2D Fonction qui prend en argument un vecteur contenant des dimensions de vecteurs 
%et qui renvoit la moyenne ainsi que la variance des 1000 estimateurs de l'esp�rance de Y. 
%   Y : rapport entre les retards (al�atoires)de deux amis arrivant ind�pendamment
%   les uns des autres. 
%
%   IN : N, [Display(0/1)]
%   OUT : Sol, un tableau contenant pour chaque N(i) fournit :
%   Sol(i,1) = Esp�rance ; Sol(i,2) = Variance

% Donn�es
% N = [10^2 10^3 10^4 10^5];

if nargin < 2
    Display = 1;
end

% Initialisation 
NBRE_EXP = 1000;
MU = 10;
SIGMA = 5^2;
MeanRatio = zeros(1, NBRE_EXP);
Length = length(N);
Sol = zeros(Length, 2);
% Pour chaque vecteur dont la dim est fournie en argument
tic;
for i=1:Length
    % Pour un certain NBRE_EXP
    for j=1:NBRE_EXP
        % Pr�allocation pour tps ex�cution
        V1 = zeros(1,N(i));
        V2 = V1;
        % Pour chaque �l�ment du vecteur �tudi�
        for k=1:N(i)
        
            %normrnd g�n�re des valeurs r�pondant � une loi normale N(MU; SIGMA)
            %l'esp�rance vaut MU et l'�cart-type SIGMA.
        
            % Retard ami 1
            V1(k)=normrnd(MU,SIGMA); 
        
            % Retard ami 2
            V2(k)=normrnd(MU,SIGMA);
        end
    % Rapport (ratio) composante par composante des retards
    Ratio=(V1)./(V2);
    
    % Moyenne des rapports (1 par exp�rience)
    MeanRatio(j)=mean(Ratio);
    
    end % end for j
    % Esp�rance
    Sol(i,1) = mean(MeanRatio);

    % Variance
    Sol(i,2) = var(MeanRatio,1);
    t = toc;
    if Display == 1
        disp(['N = ' num2str(N(i)) ' : Esperance = ' num2str(Sol(i,1)) ' ; Variance = ' num2str(Sol(i,2)) '; t = ' num2str(t) ' s']);
    end
end % end for i
end 
