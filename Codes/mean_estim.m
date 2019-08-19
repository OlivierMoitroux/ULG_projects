function [estBiaisMx, varMx, mx] = mean_estim( servings, nbCountry)
%Mean_estim estime le biais et la variance de l'estimateur m_x de la
%consommation moyenne de servings.

size    = length(servings);
mx = zeros(1, size);
%rng(3);
for i = 1:size
    rand_country = randsample(1:size, nbCountry, true);
    mx(i)        = mean(servings(rand_country));
end

% Biais
estBiaisMx = mean(mx) - mean(servings);
% Variance
varMx      = var(mx);

end

