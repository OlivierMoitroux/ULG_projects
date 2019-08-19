function V = varEA_eqNorm(sig_alpha, lCorrNorm)

V = 2 * sig_alpha^2 * lCorrNorm * (1 - lCorrNorm + lCorrNorm * exp(- 1 / lCorrNorm));

end