% Plot de mu et std de EA_eq

% Run figMeanStdEA_eqData

% mean
figure
hold on
title('\mu_{EA_{eq}} en fonction de \sigma_\alpha pour différentes valeurs de l/L')
xlabel('\sigma_\alpha [-]')
ylabel('\mu_{EA_{eq}} [N]')
grid
c = winter(length(lCorrNorm));
for k = 1:length(lCorrNorm)
    analyticMean = EA_0 * arrayfun(@(x) meanEA_eqNorm(x, lCorrNorm(k)), sig_alpha);
    plot(sig_alpha, means(k, :), 'Color', c(k, :), 'DisplayName', strcat(num2str(lCorrNorm(k)), ' (simulation)'))
    plot(sig_alpha, analyticMean, '--', 'Color', c(k, :), 'DisplayName', strcat(num2str(lCorrNorm(k)), ' (analytique)'))
end
lgd = legend(gca, 'show');
title(lgd, 'l/L')
hold off

% std
figure
hold on
grid
title('\sigma_{EA_{eq}} en fonction de \sigma_\alpha pour différentes valeurs de l/L')
xlabel('\sigma_\alpha [-]')
ylabel('\sigma_{EA_{eq}} [N]')
c = winter(length(lCorrNorm));
for k = 1:length(lCorrNorm)
    analyticStd = arrayfun(@(x) sqrt(EA_0^2 * varEA_eqNorm(x, lCorrNorm(k))), sig_alpha);
    plot(sig_alpha, stds(k, :), 'Color', c(k, :), 'DisplayName', strcat(num2str(lCorrNorm(k)), ' (simulation)'))
    plot(sig_alpha, analyticStd, '--', 'Color', c(k, :), 'DisplayName', strcat(num2str(lCorrNorm(k)), ' (analytique)'))
end
lgd = legend(gca, 'show');
title(lgd, 'l/L')
hold off
