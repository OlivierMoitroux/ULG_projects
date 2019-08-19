function sample = sampleEA_eqNorm(N, lCorrNorm, sig_alpha, nStep)

sample = zeros(1, N);
for i = 1:N
    sample(i) = EA_eqNorm(lCorrNorm, sig_alpha, nStep);
end

end

