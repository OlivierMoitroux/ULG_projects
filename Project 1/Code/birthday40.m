%%
% Author: Francois Van Lishout
% Date : 09/02/2015
%
% This function returns 1 if at least two people out of a random group of
% 40 people are born on the same day and 0 otherwise.
%

function bool = birthday40()

group = zeros(1, 40);
for i=1:40
    group(i) = randi([1,365]);
end

bool = sameDay(group);

end
