%% Q1 - Analyse descriptive
% @AUTHOR Olivier MOITROUX
% @AUTHOR Pierre HOCKERS

close all;
clc;
clear all;

%% Importing DATA
filename = 'C:\Users\Philippe\Documents\MATLAB\db_stat85.csv';
[countries, beer_servings, wine_servings, spirit_servings, tot_lit_pure_alcohol] = import_csv(filename);

%% a) Histogramme consommation biere et alcool fort
    % Plot data
    figure('Name','1a) Histogramme bière et alcool fort','NumberTitle', 'off');
    bar(1:100, [beer_servings, spirit_servings]); 
    legend('Bière [Cannette]', 'Alcool fort [shots]');
    % title('Histogramme de la consommation de bière et d''alcool fort');
    ylabel('Consommation');
    set(gca, 'XTickLabel', countries, 'XTick', 1:numel(countries), 'fontsize', 18); 
    rotateticklabel(gca); % @AUTHOR : Andy Bliss
    colormap winter
    %colormap([0 0 1; 1 0 0]);
    
    % plot histogramme
    figure;
    hist([beer_servings, spirit_servings]);
    legend('Bière [Cannette]', 'Alcool fort [Shot]');
    xlabel('Consommation');
    ylabel('Pays');
    set(gca, 'fontsize', 18);
    colormap winter

%% b) Moyenne - Médiane - Mode - écart-type
    disp('b)');
    beerAvrg   = mean(beer_servings)
    spiritAvrg = mean(spirit_servings)

    beerMedian    = median(beer_servings)
    spiritMedian  = median(spirit_servings)

    beerMode      = mode(beer_servings)
    spiritMode    = mode(spirit_servings)

    beerStDev     = std(beer_servings) %sqrt(var())
    spiritStDev   = std(spirit_servings)

%% c) Consommation normale
    beerProp = 0;
    lowerBound = beerAvrg - beerStDev;
    upperBound = beerAvrg + beerStDev;
    for i = 1:length(beer_servings)
            if beer_servings(i) > lowerBound && beer_servings(i) < upperBound
                beerProp = beerProp + 1;
            end     
    end

    beerProp = beerProp / length(countries); 

    disp(['c-i) ', num2str(beerProp*100), ' % des pays ont une consommation de bière "normale"']);
    if beer_servings(20) > lowerBound && beer_servings(20) < upperBound
        disp('La belgique a une consommation de bière "normale"');
    else disp('La Belgique a une consommation de bière "anormale"');
    end 
    
    lowerBound = spiritAvrg - spiritStDev;
    upperBound = spiritAvrg + spiritStDev;
    spiritProp = 0;
    for i = 1:length(spirit_servings)
            if spirit_servings(i) > lowerBound && spirit_servings(i) < upperBound
                spiritProp = spiritProp + 1;
            end     
    end

    spiritProp = spiritProp / length(countries); 

    disp(['c-ii) ', num2str(spiritProp*100), ' % des pays ont une consommation de spiritueux "normale"']);
    if beer_servings(20) > lowerBound && beer_servings(20) < upperBound
        disp('La belgique a une consommation de spiritueux "normale"');
    else disp('La Belgique a une consommation de spiritueux "anormale"');
    end
        
%% d) i)Boites a moustaches
    figure('Name','1d) Boîte à moustache bière et alcool fort','NumberTitle', 'off');
    subplot(1,2,1); % 1x2 grid first graph
    boxplot(beer_servings);
    title('Bière');
    ylabel('Consommation [L]');
    set(gca, 'XTickLabel', '', 'YTick', 0:25:400, 'fontsize', 18);
    ylim([-10 400]);

    subplot(1,2,2);
    boxplot(spirit_servings);
    title('Alcool fort');
    ylabel('Consommation [L]');
    set(gca, 'XTickLabel', '', 'YTick', 0:25:400, 'fontsize', 18);
    ylim([-10 400]);
    
    % ii) quartiles
    disp('d) Quartiles :');
    beerQuart   = quantile(beer_servings, [.25, .50, .75])
    spiritQuart = quantile(spirit_servings, [.25, .50, .75])
    
%% e) Polygone de fréquence cumulée de la consommation de bière
    figure('Name','1e) Fréquence cumulée consommation de bière','NumberTitle', 'off');
    p = cdfplot(beer_servings); % empirical cumulative distribution function 
    % On aurait pu exploiter la structure STATS [H,STATS] renvoyée par
    % cdfplot pour b)
    hold on;
    l1 = line([200 200], [0 .78], 'Color', 'g', 'LineStyle','--');
    l2 = line([0 200], [.78 .78], 'Color', 'g', 'LineStyle','--');
    l3 = line([beer_servings(20) beer_servings(20)], [0 .91], 'Color', 'r', 'LineStyle','--');
    l4 = line([0 beer_servings(20)], [.91 .91], 'Color', 'r', 'LineStyle','--');
    hold off;
    legend([p, l1, l3], 'Polygone des fréquences cumulées', 'Consommation de 200 cannettes', 'Consommation belge');
    set(gca, 'fontsize', 18);
    title(''); % turn off auto title
    
%% f) Scatterplot et coéfficients de corrélation linéaire

    % $$Cor(X,Y) = \frac{Cov{X,Y}}{\sigma_X \sigma_Y}$$
    disp('f) Coéfficients de corrélation linéaire :');
    
    figure('Name','1f) ScatterPlots','NumberTitle', 'off');
    subplot(1,3,1);
    scatter(tot_lit_pure_alcohol, beer_servings,'filled',  'b');
    title('Alcool pur et bière');
    set(gca, 'fontsize', 18);
    xlabel('Consommation annuelle [L]');
    ylabel('Consommation annuelle [Cannette]');
    
    disp('Alcool pur - Bière');
    r1 = corrcoef(tot_lit_pure_alcohol, beer_servings);
    r1 = r1(1,2)

    subplot(1,3, 2);
    scatter(tot_lit_pure_alcohol, wine_servings, 'filled', 'r');
    title('Alcool pur et vin');
    set(gca, 'fontsize', 18);
    xlabel('Consommation annuelle [L]');
    ylabel('Consommation annuelle [Verre]');
    
    disp('Alcool pur - Vin');
    r2 = corrcoef(tot_lit_pure_alcohol, wine_servings);
    r2 = r2(1,2)
    
    subplot(1,3, 3);
    scatter(tot_lit_pure_alcohol, spirit_servings, 'filled', 'g');
    title('Alcool pur et spiritueux');
    set(gca, 'fontsize', 18);
    xlabel('Consommation annuelle [L]');
    ylabel('Consommation annuelle [Shot]');
    
    disp('Alcool pur - Spiritueux');
    r3 = corrcoef(tot_lit_pure_alcohol, spirit_servings);
    r3 = r3(1,2)
     
    clearvars l1 l2 l3 l4 p filename i

    