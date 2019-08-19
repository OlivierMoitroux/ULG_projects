% Plot (contourf) de skewness et kurtosis

sig_alphaN = 10;
lCorrNormN = 10;

sig_alpha = linspace(sig_alphaMin, sig_alphaMax, sig_alphaN);
lCorrNorm = linspace(lCorrNormMin, lCorrNormMax, lCorrNormN);

skews = zeros(length(lCorrNorm), length(sig_alpha));
kurts = zeros(length(lCorrNorm), length(sig_alpha));

for i = 1:length(lCorrNorm)
    
    for j = 1:length(sig_alpha)
        
        sample = EA_0 * sampleEA_eqNorm(N, lCorrNorm(i), sig_alpha(j), nStep);
        
        skews(i, j) = skewness(sample);
        kurts(i, j) = kurtosis(sample);
    end
end

% skewness
figure
contourf(sig_alpha, lCorrNorm, skews)
colorbar
title('Skewness')
xlabel('\sigma_\alpha [-]')
ylabel('l/L [-]')

minSkew = min(min(skews))
maxSkew = max(max(skews))

% kurtosis
figure
contourf(sig_alpha, lCorrNorm, kurts)
colorbar
title('Kurtosis')
xlabel('\sigma_\alpha [-]')
ylabel('l/L [-]')

minKurt = min(min(kurts))
maxKurt = max(max(kurts))
