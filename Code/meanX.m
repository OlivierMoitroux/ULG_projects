function E = meanX(meanEA_eqNorm, K_0, Ke_0, x_0)

meanAlpha_k = meanEA_eqNorm - 1;

sumsom = zeros(size(K_0, 1), size(K_0, 2));

for k = 1:size(Ke_0, 3)
    y = meanAlpha_k(k) * Ke_0(:,:,k);
    sumsom = y + sumsom;
end

E = x_0 - ((K_0)^(-1) * sumsom) * x_0 + 1e-4;

end