% Resolution de la question 4
format bank;
load('FJE.mat');

% Initialisation
Var_F = [0, 500^2, 700^2];
Var_J = [0, 700^2, 200^2, 150^2, 250^2];
Var_E = [0, 500^2, 1000^2, 1100^2];

% Q4.a1
disp('1) Borne superieure du cout de reparation selon Bienayme-Tchebyshev');
[borneBT_F,borneBT_J,borneBT_E] = borneBT(Var_F, Var_J, Var_E)

% Q4.a2
disp('2) Borne superieure du cout de reparation selon distribution normale');
[borneNorm_F, borneNorm_J, borneNorm_E] = borneN(FJE, Var_F, Var_J, Var_E)
