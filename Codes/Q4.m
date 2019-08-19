%% Q4 - Test d'hypothèses
% @AUTHOR Olivier MOITROUX
% @AUTHOR Pierre HOCKERS

close all;
clc;
clear all;

%% Importing DATA
filename = 'C:\Users\Philippe\Documents\MATLAB\db_stat85.csv';
[countries ,beer_servings,~, ~,~] = import_csv(filename);
clear filename;

%% Tirage de 100 fois 6 échantillons i.i.d. de 50 pays
    % Initialisation1
    size = length(beer_servings); % 100
    belgiumIndex = strmatch('Belgium', countries);
    
    disp('Pourcentage des pays ayant une plus grande cons. de bière que la Belgique:');
    x = compute_x(beer_servings, belgiumIndex)
    % x = 0.10, ...
    % Initialisation2
    u_alpha = 1.645; % cfr. table de Gauss, alpha = 0.05; 
    var = sqrt((1-x)*x/size);
    rejectedState = 0; rejectedOMS = 0;
    for i = 1:100
        %% a) L'état belge
        randCountries = randsample([1:belgiumIndex-1, belgiumIndex+1:size], 49);
        randCountries(50) = belgiumIndex;
        boolRejState    = test_hyp0(beer_servings, randCountries,x, u_alpha, var);
        if(boolRejState)
        	rejectedState = rejectedState + 1;
        end
        %% b) 5 instituts de statistique indépendants
        for j = 1:5 
            randCountries = randsample([1:belgiumIndex-1, belgiumIndex+1:size], 49);
            randCountries(50) = belgiumIndex;
            boolOMS     = test_hyp0(beer_servings, randCountries,x, u_alpha, var);
            if(boolOMS)
                rejectedOMS = rejectedOMS + 1;
                break;
            end
        end
    end 
    disp('a)');
    rejectedState
    disp('b)');
    rejectedOMS






