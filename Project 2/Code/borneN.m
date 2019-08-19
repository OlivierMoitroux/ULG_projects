function [borneNorm_F, borneNorm_J, borneNorm_E] = borneN(FJE, Var_F, Var_J, Var_E)
% Calcule la borne superieur du cout de reparation de chaque machine pour 
% chaque panne telle que la probabilite que le cout soit superieur a la
% borne soit <=0.1 dans le cas d'une distribution normale.
% IN : [FJE, Var_F, Var_J, Var_E] (FJE et les variances)
% OUT : [borneNorm_F, borneNorm_J, borneNorm_E]

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));

% Esperance
[Esp_F, Esp_J, Esp_E]= importCouts();

% Ecart-type
eType_F = sqrt(Var_F);  
eType_J = sqrt(Var_J);
eType_E = sqrt(Var_E);
[borneBT_F,borneBT_J,borneBT_E] = borneBT(Var_F, Var_J, Var_E);

% Preallocation memoire
borneNorm_F = zeros(hauteur,1);
borneNorm_J = zeros(largeur,1);
borneNorm_E = zeros(profondeur,1);

% Resolution de l'integrale (cfr rapport)
for k=2:hauteur
    funct = @(x) (1/(eType_F(k)*sqrt(2*pi)))*exp(-(1/2)*((x-Esp_F(k))/eType_F(k)).^2);
	integ = @(b) integral(funct,b,Inf);
	borneNorm_F(k) = fzero(@(b) integ(b)-0.1,borneBT_F(k));
end

for k=2:largeur
    funct = @(x) (1/(eType_J(k)*sqrt(2*pi)))*exp(-(1/2)*((x-Esp_J(k))/eType_J(k)).^2);
	integ = @(b) integral(funct,b,Inf);
	borneNorm_J(k) = fzero(@(b) integ(b)-0.1,borneBT_J(k));
end

for k=2:profondeur
    funct = @(x) (1/(eType_E(k)*sqrt(2*pi)))*exp(-(1/2)*((x-Esp_E(k))/eType_E(k)).^2);
	integ = @(b) integral(funct,b,Inf);
	borneNorm_E(k) = fzero(@(b) integ(b)-0.1,borneBT_E(k));
end

end
