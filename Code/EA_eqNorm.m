function EA_eqNorm = EA_eqNorm(lCorrNorm, sig_alpha, nStep)
% Compute normalized equivalent stiffness of the beam

% Random process vector
alpha = expGen(lCorrNorm, sig_alpha, nStep);

% Equivalent stiffness
EA_eqNorm = (nStep - 1) / trapz(1 ./ (1 + alpha));

end

