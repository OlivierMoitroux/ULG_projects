function E = varFint(meanEA_eqNorm, varEA_eqNorm, K_0, Ke_0, B_0, Be_0, X_0)

meanAlpha_k = meanEA_eqNorm - 1;
varAlpha_k = varEA_eqNorm;

sumsom1 = zeros(size(K_0, 1), size(K_0, 2));

for k = 1:size(Ke_0, 3)
    y = (varAlpha_k(k)+ meanAlpha_k(k)^2)*(Be_0(:,:,k)-Be_0(:,:,k)*Ke_0(:,:,k)*(K_0^(-1)).'*B_0.'-transpose(Be_0(:,:,k)*Ke_0(:,:,k)*(K_0^(-1)).'*(B_0^(-1)).')+B_0*K_0^(-1)*Ke_0(:,:,k)*X_0*X_0.'*Ke_0(:,:,k).'*(K_0^(-1)).'*(B_0^(-1)).');
    sumsom1 = y + sumsom1;
end

E = diag(sumsom1);

end