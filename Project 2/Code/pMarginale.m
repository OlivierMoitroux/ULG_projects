function P  = pMarginale(FJE, machine)
% Calcule la probabilite marginale demandee a la question 1 pour 1 machine
% IN : FJE, nom machine au format majuscule
% OUT : P, vecteur contenant les P_marginales d'une machine

hauteur     = length(FJE(:,1,1));
largeur     = length(FJE(1,:,1));
profondeur  = length(FJE(1,1,:));
maxDim = max([hauteur, largeur, profondeur]);
P = zeros(1,maxDim);

if machine == 'F'
    for num_panne=1:hauteur % plan horizontal
        for j=1:largeur
            for e=1:profondeur
                P(1,num_panne) = P(1,num_panne) + FJE(num_panne, j, e);
            end
        end
        P(hauteur+1:maxDim)= NaN;
    end

elseif machine == 'J'
    for num_panne =1:largeur
        for f=1:hauteur
            for e=1:profondeur
                P(1, num_panne) = P(1,num_panne) + FJE(f,num_panne, e);
            end
        end
    end

elseif machine == 'E'
    for num_panne=1:profondeur
        for f=1:hauteur
            for j=1:largeur
                P(1, num_panne) = P(1,num_panne) + FJE(f,j, num_panne);
            end
        end
    end
    P(profondeur+1:maxDim)= NaN;
end

end

