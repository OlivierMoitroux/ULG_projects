function [ PCj_FE, PCe_FJ, PCf_JE ] = pConditionnelle( FJE )
% Calcule les lois de probabilites conditionnelles de la Q1.c
% IN : FJE
% OUT : [ PCj_FE, PCe_FJ, PCf_JE ]

% Calcul des probabilites conjointes
[Pc_FE, Pc_FJ, Pc_JE]= pConjointe(FJE);

% Initialisation
hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));

PCj_FE = zeros(hauteur,largeur,profondeur);
PCe_FJ = zeros(hauteur,largeur,profondeur);
PCf_JE = zeros(hauteur,largeur,profondeur);

% Calcul des probabilites conditionnelles
for f=1:hauteur
    for j=1:largeur
        for e=1:profondeur
            PCf_JE(f,j,e)=(FJE(f,j,e))/(Pc_JE(j,e)); 
            PCj_FE(f,j,e)=(FJE(f,j,e))/(Pc_FE(f,e));
            PCe_FJ(f,j,e)=(FJE(f,j,e))/(Pc_FJ(f,j));
        end
    end
end

% Export
% matrix2latex(PCf_JE(:,:,1),'Q1c1_1.tex','alignment','c');
% matrix2latex(PCf_JE(:,:,2),'Q1c1_2.tex','alignment','c');
% matrix2latex(PCf_JE(:,:,3),'Q1c1_3.tex','alignment','c');
% matrix2latex(PCf_JE(:,:,4),'Q1c1_4.tex','alignment','c');
% 
% matrix2latex(PCj_FE(:,:,1),'Q1c2_1.tex','alignment','c');
% matrix2latex(PCj_FE(:,:,2),'Q1c2_2.tex','alignment','c');
% matrix2latex(PCj_FE(:,:,3),'Q1c2_3.tex','alignment','c');
% matrix2latex(PCj_FE(:,:,4),'Q1c2_4.tex','alignment','c');
% 
% matrix2latex(PCe_FJ(:,:,1),'Q1c3_1.tex','alignment','c');
% matrix2latex(PCe_FJ(:,:,2),'Q1c3_2.tex','alignment','c');
% matrix2latex(PCe_FJ(:,:,3),'Q1c3_3.tex','alignment','c');
% matrix2latex(PCe_FJ(:,:,4),'Q1c3_4.tex','alignment','c');

end



