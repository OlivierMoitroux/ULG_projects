
data = true;

sig_alphaN = 2;
lCorrNormN = 2;

g = (sig_alphaMax - sig_alphaMin) / 10;
sig_alpha = linspace(sig_alphaMin + g, sig_alphaMax - g, sig_alphaN);
g = (lCorrNormMax - lCorrNormMin) / 10;
lCorrNorm = linspace(lCorrNormMin + g, lCorrNormMax - g, lCorrNormN);

X = zeros(length(lCorrNorm), length(sig_alpha), NDdl, N);
Fint = zeros(length(lCorrNorm), length(sig_alpha), NElem, N);

analMeanX = zeros(length(lCorrNorm), length(sig_alpha), NDdl);
analStdX = zeros(length(lCorrNorm), length(sig_alpha), NDdl);
analMeanFint = zeros(length(lCorrNorm), length(sig_alpha), NElem);
analStdFint = zeros(length(lCorrNorm), length(sig_alpha), NElem);


for i = 1:length(lCorrNorm)
    
    for j = 1:length(sig_alpha)
        
        ELEM_EA_mean_norm = ones(1, NElem) * meanEA_eqNorm(sig_alpha(j), lCorrNorm(i));
        ELEM_EA_var_norm = ones(1, NElem) * varEA_eqNorm(sig_alpha(j), lCorrNorm(i));
        
        ELEM_EA_mean = ELEM_EA_0 .* ELEM_EA_mean_norm;
        ELEM_EA_std = ELEM_EA_0 .* sqrt(ELEM_EA_var_norm);
        
        for k = 1:N
            
            Elements.ELEM_EA = ELEM_EA_mean + ELEM_EA_std .* randn(1, NElem);
            
            % construire les éléments essentiels de l'analyse
            [K,p,Ke,B] = BuildStructure(Nodes,Elements,Appui,Force);
            
            % résoudre
            x = K \ p;
            X(i, j, :, k) = x;        % contient tous les degrés de liberté NON bloqués (=libres)
            Fint(i, j, :, k) = B * x;     % calcul des forces intérieures (efforts axiaux) dans toutes les barres
        end
        
        analMeanX(i, j, :) = meanX(ELEM_EA_mean_norm, K_0, Ke_0, X_0);
        analStdX(i, j, :) = sqrt(varX(ELEM_EA_var_norm, K_0, Ke_0, X_0));
        % analMeanFint(i, j, :) = meanFint(ELEM_EA_mean_norm, ELEM_EA_var_norm, K_0, Ke_0, B_0, Be_0, X_0);
        % analStdFint(i, j, :) = sqrt(varFint(ELEM_EA_mean_norm, ELEM_EA_var_norm, K_0, Ke_0, B_0, Be_0, X_0));
    end
end

% Valeurs simulations
simMeanX = mean(X, 4);
simStdX = std(X, 0, 4);
simMeanFint = mean(Fint, 4);
simStdFint = std(Fint, 0, 4);

% Erreurs relatives
eMeanX = (analMeanX - simMeanX) ./ simMeanX
eStdX = (analStdX - simStdX) ./ simStdX
% eMeanFint = (analMeanFint - simMeanFint) ./ simMeanFint
% eStdFint = (analStdFint - simStdFint) ./ simStdFint


for i = 1:length(lCorrNorm)
    
    for j = 1:length(sig_alpha)
        
        % Plot déformée moyenne
        figure
        ampl = 500;  % amplification de la déformée
        Display(Nodes, Elements, Appui, [X_0 squeeze(simMeanX(i, j, :))], ampl)  % dessin de la déformée
        lgd = legend('pas de déplacement', 'déterministe', 'stochastique moyen');
        title(lgd, 'Déplacement')
        title(strcat('Déformée moyenne pour \sigma_\alpha = ', num2str(sig_alpha(j)), ...
            ' et l/L = ', num2str(lCorrNorm(i))))
        axis equal
        
        cmp = get(groot,'DefaultAxesColorOrder');
        
        % Plot distribution déformation
        figure
        hold on
        grid
        for k = 1:NDdl
            sample = squeeze(X(i, j, k, :));
            xAnalX = linspace(analMeanX(i, j, k) - 4 * analStdX(i, j, k), ...
                analMeanX(i, j, k) + 4 * analStdX(i, j, k), 100);
            fAnalX = normpdf(xAnalX, analMeanX(i, j, k), analStdX(i, j, k));
            [fSimX, xSimX] = hist(sample, 100);
            fSimX = fSimX / (length(sample) * (xSimX(3) - xSimX(2)));
            plot(xSimX, fSimX, 'color', cmp(mod(k,length(cmp)) + 1,:), 'DisplayName', strcat(ddlNames(k), '(simulation)'))
            plot(xAnalX, fAnalX, '--', 'color', cmp(mod(k,length(cmp)) + 1,:), 'DisplayName', strcat(ddlNames(k), '(analytique)'))
        end
        title(strcat('Distribution de probabilité des déplacements pour \sigma_\alpha = ', num2str(sig_alpha(j)), ...
            ' et l/L = ', num2str(lCorrNorm(i))))
        xlabel('x [m]')
        lgd = legend(gca, 'show', 'Location', 'NorthWest');
        title(lgd, 'Déplacement')
        hold off
        
        % saveas(gcf, strcat('distrDeplT', num2str(iStructure), '_', num2str(j), num2str(i), '.eps'), 'epsc')
        
%         % Plot distribution efforts
%         figure
%         hold on
%         grid
%         for k = 1:NElem
%             sample = squeeze(Fint(i, j, k, :));
%             % xAnalFint = linspace(analMeanFint(i, j, k) - 4 * analStdFint(i, j, k), ...
%             %   analMeanFint(i, j, k) + 4 * analStdFint(i, j, k), 100);
%             % fAnalFint = normpdf(xAnalFint, analMeanFint(i, j, k), analStdFint(i, j, k));
%             [fSimFint, xSimFint] = hist(sample, 100);
%             fSimFint = fSimFint / (length(sample) * (xSimFint(3) - xSimFint(2)));
%             plot(xSimFint, fSimFint)
%             % plot(xAnalFint, fAnalFint, '--', 'color', cmp(mod(k,length(cmp)) + 1,:), 'DisplayName', strcat(ddlNames(k), '(analytique)'))
%         end
%         
%         title(strcat('Distribution de probabilité des différences d efforts pour \sigma_\alpha = ', num2str(sig_alpha(j)), ...
%             ' et l/L = ', num2str(lCorrNorm(i))))
%         xlabel('n [N]')
%         %         lgd = legend(gca, 'show');
%         %         title(lgd, 'Effort')
%         hold off

%         saveas(gcf, strcat('distrEffT', num2str(iStructure), '_', num2str(j), num2str(i), '.eps'), 'epsc')
        
    end
end
