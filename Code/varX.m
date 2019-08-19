function E = varX(varEA_eqNorm, K_0, K_E, x_0)

varAlpha_k = varEA_eqNorm;

sumsom = zeros(size(K_0, 1), size(K_0, 2));

for k = 1:size(K_E, 3)
    y = varAlpha_k(k) * (K_0)^(-1) * K_E(:,:,k) * x_0 * transpose((K_0)^(-1) * K_E(:,:,k) * x_0);
    sumsom = y + sumsom;
end

E = diag(sumsom);

end
