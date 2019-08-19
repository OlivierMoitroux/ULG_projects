function [ bool ] = test_hyp0(beer_servings, randCountries,x, u_alpha, var)
%test_hyp0 �value si l'hypoth�se H0 est rejet�e.

n = length(randCountries); tmp = 0; 

for i = 1:n-1
    if beer_servings(randCountries(i))  > beer_servings(randCountries(n))
        tmp = tmp + 1;
    end
end

sampleFreq = tmp/n;
if(sampleFreq >= x+u_alpha*var)
    bool = 1; % Rejet de l'hypoth�se H0
else bool = 0;
end
bool = logical(bool);
end