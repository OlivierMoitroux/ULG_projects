function alpha = expGen(lCorrNorm, sig_alpha, nStep)
% Generate exponential auto-correlated vector function

% Initialize phi, generation parameter
phi = exp(-1 / (lCorrNorm * nStep));

% Standard deviation of w
sig_w = sig_alpha * sqrt((1 + phi) / (1 - phi));

% Initialize w, band-limited white noise
w = sig_w * randn(nStep, 1);

% Initialize return vector
alpha = zeros(1, nStep);

% Initialize alpha from stationary distribution for the exponential
% autocorrelation
alpha(1) = 0 + sig_alpha * randn(1,1);
for i = 2:nStep
    alpha(i) = phi * alpha(i - 1) + (1 - phi) * w(i);
end

end

