function [ estBiaisMedx, varMedx ] = med_estim( servings, nbCountry)
%Med_estim estime le biais et la variance de l'estimateur median_x de la
%consommation moyenne de servings.

size    = length(servings);
medx = zeros(1, size);
%rng(3);
for i = 1:size
    rand_country = randsample(1:size, nbCountry);
    medx(i)      = median(servings(rand_country));
end

% Biais
estBiaisMedx = mean(medx) - median(servings);
% Variance
varMedx      = var(medx);
end

