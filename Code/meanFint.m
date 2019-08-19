function E = meanFint(meanEA_eqNorm, varEA_eqNorm, K_0, Ke_0, B_0, Be_0, X_0)

meanAlpha_k = meanEA_eqNorm - 1;
varAlpha_k = varEA_eqNorm;

% TO DO
sumsom1 = zeros(size(B_0, 1), size(B_0, 2));
sumsom2 = zeros(size(K_0, 1), size(K_0, 2));
sumsom3 = zeros(size(B_0, 1), size(B_0, 2));
sommeTot = B_0*X_0;

for k = 1:size(Ke_0, 3)
    y = meanAlpha_k(k)^2*Be_0(:,:,k);
    sumsom1 = y + sumsom1;
end

size(sumsom1)

for k = 1:size(Ke_0, 3)
    y = meanAlpha_k(k)^2*Ke_0(:,:,k)*X_0;
    sumsom2 = y + sumsom2;
end

size(sumsom2)

for k = 1:size(Ke_0, 3)
    y = (varAlpha_k(k)+ meanAlpha_k(k)^2) * Be_0(:,:,k)*K_0^(-1)*Ke_0(:,:,k)*X_0;
    sumsom3 = y + sumsom3;
end

size(sumsom3)

E = sommeTot + sumsom1 - B_0*K_0^(-1)*sumsom2 - sumsom3;

end