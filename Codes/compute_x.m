function [x] = compute_x(beer_servings, countryIndex)
%Calcule le pourcentage 'x' de pays ayant une consommation plus grande que
% l'index du pays donné en argument.

n = length(beer_servings); tmp = 0;

for i = [1:countryIndex-1, countryIndex+1:n]
    if(beer_servings(i) > beer_servings(countryIndex))
        tmp = tmp + 1;
    end
end

x = tmp/n;

end

