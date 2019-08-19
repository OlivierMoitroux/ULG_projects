function [borneBT_F,borneBT_J,borneBT_E] = borneBT(Var_F, Var_J, Var_E)
% Resolution via Bienayme-Tchebyshev : calcule la borne superieur du cout
% de reparation de chaque machine pour chaque panne telle que la 
% probabilite que le cout soit superieur a la borne soit <=0.1
% IN : [Var_F, Var_J, Var_E] (les variances)
% OUT : [borneBT_F,borneBT_J,borneBT_E]

% De Bienayme-Tchebyshev, on tire:
c = sqrt(10);

% Initialisation
[Esp_F, Esp_J, Esp_E]= importCouts();

% On isole X dans la formule ( avec ecart-type == sqrt(variance))
borneBT_F = sqrt(Var_F) * c + Esp_F;
borneBT_J = sqrt(Var_J) * c + Esp_J;
borneBT_E = sqrt(Var_E) * c + Esp_E;

end
