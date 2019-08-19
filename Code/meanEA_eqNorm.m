function E = meanEA_eqNorm(sig_alpha, lCorrNorm)

E = 1 - sig_alpha^2 + 2 * sig_alpha^2 * lCorrNorm * ...
    (1 - lCorrNorm + lCorrNorm * exp(- 1 / lCorrNorm));

end
