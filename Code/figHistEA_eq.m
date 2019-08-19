% Histogrammes simples

sig_alphaN = 5;
lCorrNormN = 5;

sig_alpha = linspace(sig_alphaMin, sig_alphaMax, sig_alphaN);
lCorrNorm = linspace(lCorrNormMin, lCorrNormMax, lCorrNormN);

% lCorrNorm fixée
figure
hold on
j = ceil(length(lCorrNorm) / 2);
title(strcat('Distribution de probabilité de EA_{eq} avec l/L = ', num2str(lCorrNorm(j))))
xlabel('EA_{eq} [N]')
grid
for i = 1:length(sig_alpha)
    
    sample = EA_0 * sampleEA_eqNorm(N, lCorrNorm(j), sig_alpha(i), nStep);
        
    [f, x] = hist(sample);
    f = f / (length(sample) * (x(3) - x(2)));
    plot(x, f, 'DisplayName', num2str(sig_alpha(i)))
    
end
lgd = legend(gca, 'show');
title(lgd,'\sigma_{\alpha}')
hold off

% sig_alpha fixé
figure
hold on
i = ceil(length(sig_alpha) / 2);
title(strcat('Distribution de probabilité de EA_{eq} avec \sigma_{\alpha} = ', num2str(sig_alpha(i))));
xlabel('EA_{eq} [N]')
grid
for j = 1:length(lCorrNorm)
    
    sample = EA_0 * sampleEA_eqNorm(N, lCorrNorm(j), sig_alpha(i), nStep);
        
    [f, x] = hist(sample);
    f = f / (length(sample) * (x(3) - x(2)));
    plot(x, f, 'DisplayName', num2str(lCorrNorm(j)))
end
lgd = legend(gca, 'show');
title(lgd, 'l/L')
hold off
