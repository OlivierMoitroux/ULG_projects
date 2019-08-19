function [Pc_FE, Pc_FJ, Pc_JE] = pConjointe(FJE)
% Calcule les lois de probabilites conjointes se
% rapportant aux differentes paires de variables de la Q1.b
% IN : FJE
% OUT : [Pc_FE, Pc_FJ, Pc_JE]

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));

Pc_FE = zeros(hauteur,profondeur);
Pc_FJ = zeros(hauteur,largeur);
Pc_JE = zeros(largeur,profondeur);

% Calcul des probabilites conjointes

% Pc_FE
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            Pc_FE(f,e)=Pc_FE(f,e)+FJE(f,j,e);
        end
    end
end

% Pc_FJ
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            Pc_FJ(f,j)=Pc_FJ(f,j)+FJE(f,j,e);
        end
    end
end

% Pc_JE
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            Pc_JE(j,e)=Pc_JE(j,e)+FJE(f,j,e);
        end
    end
end
% Export des donnees vers latex
% matrix2latex(Pc_FJ,'Q1b1.tex','alignment','c');
% matrix2latex(Pc_JE,'Q1b2.tex','alignment','c');
% matrix2latex(Pc_FE,'Q1b3.tex','alignment','c');
end


