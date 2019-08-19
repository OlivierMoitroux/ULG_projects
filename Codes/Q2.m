%% Q2 - Génération d'échantillons indépendants et identiquement distribués
% @AUTHOR Olivier MOITROUX
% @AUTHOR Pierre HOCKERS
clear all;
close all;
clc;

%% Importing DATA
filename = 'C:\Users\Philippe\Documents\MATLAB\db_stat85.csv';
[~, beer_servings, wine_servings, spirit_servings, tot_lit_pure_alcohol] = import_csv(filename);
clear filename;

%% a) Tirage d'échantillon i.i.d. de 20 pays
    rng(1); 
    % Même seed pour garder la même génération aléatoire (
    % reproductibilité)
    sample = randsample(1:length(beer_servings), 20, true);
    
%% i) 
    disp('a-i)'); 
    beerAvrgSamp   = mean(beer_servings(sample))
    spiritAvrgSamp = mean(spirit_servings(sample))

    beerMedianSamp   = median(beer_servings(sample))
    spiritMedianSamp = median(spirit_servings(sample))

    beerModeSamp     = mode(beer_servings(sample))
    spiritModeSamp   = mode(spirit_servings(sample))

    beerStDevSamp    = std(beer_servings(sample)) %sqrt(var())
    spiritStDevSamp  = std(spirit_servings(sample))
   
 %% ii)
    disp('a-ii)');
    figure('Name','2a-ii) Boîte à moustache bière et alcool fort','NumberTitle', 'off');
    subplot(1,2,1); % 1x2 grid first graph
    boxplot(beer_servings(sample));
    title('Bière');
    ylabel('Consommation [L]');
    set(gca, 'XTickLabel', '', 'YTick', 0:25:400, 'fontsize', 18);
    ylim([-10 400]);

    subplot(1,2,2);
    boxplot(spirit_servings(sample));
    title('Alcool fort');
    ylabel('Consommation [L]');
    set(gca, 'XTickLabel', '', 'YTick', 0:25:400, 'fontsize', 18);
    ylim([-10 400]);
   
%% iii)
    figure('Name','2a-iii) Fréquence cumulée consommation de bière et d''alcool fort','NumberTitle', 'off');
    % Fonction de distribution empirique cumulative
    grid;
    subplot(1,2,1);
    hold on;
    cdfplot(beer_servings(sample));
    cdf2 = cdfplot(beer_servings);
    hold off;
    set(cdf2, 'Color', 'r');
    set(gca,'XTick', 0:50:400, 'fontsize', 18);
    xlim([0, 400]);
    xlabel('Consommation annuelle [Canette]');
    title('Polygone des fréquences cumulées - Bière');
    legend('Echantillon (20)', 'Population'); 
    
    subplot(1,2,2);
    hold on;
    cdfplot(spirit_servings(sample));
    cdf4 = cdfplot(spirit_servings);
    hold off;
    xlim([0, 400]);% max(spirit_servings)]
    xlabel('Consommation annuelle [Shot]');
    set(cdf4, 'Color', 'r');
    set(gca,'XTick', 0:50:400, 'fontsize', 18);
    title('Polygone des fréquences cumulées - Alcool fort');
    legend('Echantillon (20)', 'Population'); 
    
    clearvars cdf2 cdf4;
    
    % distance de Kolmogorov - Smirnov
    disp('a-iii) Distance de Kolmogorov-Smirnov : ')
    
    [~,~,beerKSD]   = kstest2(beer_servings, beer_servings(sample))
    [~,~,spiritKSD] = kstest2(spirit_servings, spirit_servings(sample))
    
%% b) Tirage d'échantillon 100 i.i.d. de 20 pays
    
    rng(2); 
    % Même seed pour garder la même génération aléatoire (
    % reproductibilité)
    size = length(beer_servings);
    
%%   i)
    beerAvrg100   = zeros(1, size);
    spiritAvrg100 = zeros(1, size);
    for i = 1:size
        rand_countries   = randsample(1:size, 20);
        beerAvrg100(i)   = mean(beer_servings(rand_countries));
        spiritAvrg100(i) = mean(spirit_servings(rand_countries));
    end
     
    figure('Name','2b-i) Histogramme moyenne consommation de bière et d''alcool fort d''échantillons','NumberTitle', 'off');
    subplot(1,2,1);
    hist(beerAvrg100);
    title('Moyennes de la consommation de bière');
    xlabel('Consommation annuelle [Cannette]');
    ylabel('Nombre d''échantillons');
    xlim([40, 180]);
    ylim([0, 25]);
    set(gca, 'fontsize', 18);
    set(gca, 'XTick', 40:10:180,'YTick', 0:2:25, 'fontsize', 18);
    % bar(beerAvrg100)
    
    subplot(1,2,2);
    hist(spiritAvrg100);
    title('Moyennes de la consommation d''alcool fort');
    xlabel('Consommation annuelle [Shot]');
    ylabel('Nombre d''échantillons');
    xlim([40, 180]);
    ylim([0, 25]);
    set(gca, 'fontsize', 18);
    set(gca, 'XTick', 40:10:180, 'YTick', 0:2:25, 'fontsize', 18);
    
    disp('b-i) Comparaisons des moyennes avec la population');
    %stdOfBeerAvrg100  = std(beerAvrg100)
    meanOfBeerAvrg100 = mean(beerAvrg100)
    
    %stdOfSpiritAvrg100  = std(spiritAvrg100)
    meanOfSpiritAvrg100 = mean(spiritAvrg100)

%%   ii)
    rng(2);
    size         = length(beer_servings);
    beerMed100   = zeros(1, size);
    spiritMed100 = zeros(1, size);
    for i = 1:size
        rand_countries  = randsample(1:size, 20);
        beerMed100(i)   = median(beer_servings(rand_countries));
        spiritMed100(i) = median(spirit_servings(rand_countries));
    end
     
    figure('Name','2b-ii) Histogramme médianes consommation de bière et d''alcool fort d''échantillons','NumberTitle', 'off');
    subplot(1,2,1);
    hist(beerMed100);
    title('Médianes de la consommation de bière');
    xlabel('Consommation annuelle [Cannette]');
    ylabel('Nombre d''échantillons');
    xlim([20, 220]);
    ylim([0, 25]);
    set(gca, 'fontsize', 18);
    set(gca, 'XTick', 20:20:220,'YTick', 0:2:25, 'fontsize', 18);
    % bar(beerAvrg100)
    
    subplot(1,2,2);
    hist(spiritMed100);
    title('Médianes de la consommation d''alcool fort');
    xlabel('Consommation annuelle [Shot]');
    ylabel('Nombre d''échantillons');
    xlim([20, 220]);
    ylim([0, 25]);
    set(gca, 'fontsize', 18);
    set(gca, 'XTick', 20:20:220, 'YTick', 0:2:25, 'fontsize', 18);
    % bar(beerAvrg100)
    
    disp('b-ii) Comparaisons des médianes avec la population et avec b-i)');
    %stdOfBeerMed100  = std(beerMed100)
    meanOfBeerMed100 = mean(beerMed100)
    
    %stdOfSpiritMed100  = std(spiritMed100)
    meanOfSpiritMed100 = mean(spiritMed100)
    
%%   iii)
    rng(2);
    size         = length(beer_servings);
    beerStd100   = zeros(1, size);
    spiritStd100 = zeros(1, size);
    for i = 1:size
        rand_countries  = randsample(1:size, 20);
        beerStd100(i)   = std(beer_servings(rand_countries));
        spiritStd100(i) = std(spirit_servings(rand_countries));
    end
     
    figure('Name','2b-iii) Histogramme écart-types consommation de bière et d''alcool fort d''échantillons','NumberTitle', 'off');
    subplot(1,2,1);
    hist(beerStd100);
    title('Ecart-types de la consommation de bière');
    xlabel('Consommation annuelle [Cannette]');
    ylabel('Nombre d''échantillons');
    xlim([50, 130]);
    ylim([0, 25]);
    set(gca, 'fontsize', 18);
    set(gca, 'XTick', 50:10:130,'YTick', 0:2:25, 'fontsize', 18);
    
    subplot(1,2,2);
    hist(spiritStd100);
    title('Ecart-types de la consommation d''alcool fort');
    xlabel('Consommation annuelle [Shot]');
    ylabel('Nombre d''échantillons');
    xlim([50, 130]);
    ylim([0, 25]);
    set(gca, 'fontsize', 18);
    set(gca, 'XTick', 50:10:130,'YTick', 0:2:25, 'fontsize', 18);
    
    disp('b-iii) Comparaisons des écart-types avec la population');
    meanOfBeerStd100   = mean(beerStd100)
    meanOfSpiritStd100 = mean(spiritStd100)

%%   iv)

    rng(2);
    size         = length(beer_servings);
    beerKSD100   = zeros(1, size);
    spiritKSD100 = zeros(1, size);
    for i = 1:size
        rand_countries        = randsample(1:size, 20);
        [~,~,beerKSD100(i)]   = kstest2(beer_servings, beer_servings(rand_countries));
        [~,~,spiritKSD100(i)] = kstest2(spirit_servings, spirit_servings(rand_countries));
    end
     
    figure('Name','2b-iv) Histogramme distance K-S consommation de bière et d''alcool fort d''échantillons','NumberTitle', 'off');
    subplot(1,2,1);
    hist(beerKSD100);
    title('Distance K-S de la consommation de bière');
    xlabel('Consommation annuelle [Cannette]');
    ylabel('Nombre d''échantillons');

    subplot(1,2,2);
    hist(spiritKSD100);
    title('Distance K-S de la consommation d''alcool fort');
    xlabel('Consommation annuelle [Shot]');
    ylabel('Nombre d''échantillons');

%%   v)
    figure('Name','2b-v) Histogramme distance K-S consommation des différents boissons','NumberTitle', 'off');
    subplot(2,2,1);
    hist(beerKSD100);
    title('Distance K-S de la consommation de bière');
    xlabel('Consommation annuelle [Cannette]');
    ylabel('Nombre d''échantillons');
    ylim([0, 30]);
    
    subplot(2,2,2);
    hist(spiritKSD100);
    title('Distance K-S de la consommation d''alcool fort');
    xlabel('Consommation annuelle [Shot]');
    ylabel('Nombre d''échantillons');
    ylim([0, 30]);

    rng(2);
    size              = length(beer_servings);
    wineKSD100        = zeros(1, size);
    pureAlcoholKSD100 = zeros(1, size);
    for i = 1:size
        rand_countries               = randsample(1:size, 20);
        [~,~,wineKSD100(i)]        = kstest2(wine_servings, wine_servings(rand_countries));
        [~,~,pureAlcoholKSD100(i)] = kstest2(tot_lit_pure_alcohol, tot_lit_pure_alcohol(rand_countries));
    end
    
    subplot(2,2,3);
    hist(wineKSD100);
    title('Distance K-S de la consommation de vin');
    xlabel('Consommation annuelle [Verre]');
    ylabel('Nombre d''échantillons');
    ylim([0, 30]);
    
    subplot(2,2,4);
    hist(pureAlcoholKSD100);
    title('Distance K-S de la consommation d''alcool pur');
    xlabel('Consommation annuelle [L]');
    ylabel('Nombre d''échantillons');
    ylim([0, 30]);
    
    clear i;
    