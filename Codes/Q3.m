%% Q3 - Estimation
% @AUTHOR Olivier MOITROUX
% @AUTHOR Pierre HOCKERS

close all;
clc;
clear all;

%% Importing DATA
filename = 'C:\Users\Philippe\Documents\MATLAB\db_stat85.csv';
[~,~, wine_servings, ~,~] = import_csv(filename);

%% a) moyenne, biais et variance
    disp('a)');
    [biaisMx20, varMx20, mx20] = mean_estim(wine_servings, 20);
    biaisMx20, varMx20
%% b) médiane
    disp('b)');
    [biaisMedx20, varMedx20] = med_estim(wine_servings, 20)
    
 %% c) Idem avec 50
    
    disp('c-i)');
    [biaisMx50, varMx50] = mean_estim(wine_servings, 50)

    disp('c-ii)');
    [biaisMedx50, varMedx50] = med_estim(wine_servings, 50)
 
 %% d) Intervalle de confiance à 95 %

    size = length(wine_servings);
    cntStudent = 0;
    cntGauss = 0;
    studLowerBound  = zeros(1,100); studUpperBound  = zeros(1,100);
    gaussLowerBound = zeros(1,100); gaussUpperBound = zeros(1,100);
    
    for i=1:size
     %% i) Student
        stdStud = std(randsample(1:size, 20))/sqrt(19);
        studLowerBound(i) = mx20(i) - 2.093*stdStud;
        studUpperBound(i) = mx20(i) + 2.093*stdStud;

        if mean(wine_servings) >= studLowerBound(i) && mean(wine_servings) <= studUpperBound(i)
            cntStudent = cntStudent+1;
        end
     %% ii) Gauss
        stdGauss = std(randsample(1:size, 20))/sqrt(20);
        gaussLowerBound(i) = mx20(i) - 1.960*stdGauss;
        gaussUpperBound(i) = mx20(i) + 1.960*stdGauss; 
        if mean(wine_servings) >= gaussLowerBound(i) && mean(wine_servings) <= gaussUpperBound(i)
            cntGauss = cntGauss+1;
        end
    end
    
    disp('d)');
    cntStudent
    cntGauss
    
    clearvars i  filename;





