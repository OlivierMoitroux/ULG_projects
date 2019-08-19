
sig_alphaN = 50;
lCorrNormN = 4;

sig_alpha = linspace(sig_alphaMin, sig_alphaMax, sig_alphaN);
lCorrNorm = linspace(lCorrNormMin, lCorrNormMax, lCorrNormN);

means = zeros(length(lCorrNorm), length(sig_alpha));
stds = zeros(length(lCorrNorm), length(sig_alpha));

for i = 1:length(lCorrNorm)
    
    for j = 1:length(sig_alpha)
        
        sample = EA_0 * sampleEA_eqNorm(N, lCorrNorm(i), sig_alpha(j), nStep);
        
        means(i, j) = mean(sample);
        stds(i, j) = std(sample);
    end
end
