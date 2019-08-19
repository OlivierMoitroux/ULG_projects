%%
% Author: Francois Van Lishout
% Date : 06/02/2014
%
% This function returns the tree obtained after applying the first step of
% the Lehman and Leighton methodology to the birthday problem. The N
% birthdays of the people are coded as 1, 2, ..., 365.
%
% The tree is represented as an 365^N * N array.
% Each column represents a level of the tree. The first column is the first
% level, ..., the last column is the last level (leaves of the tree).
% Each row represents a path in the tree. 
% For example, for N=2, the 3rd row means that the first person is born on 
% the 1st of january and the second person is born on the 3rd of january.
%
% Arguments:
%   N
%        the amount of people (N>0)

function birthdayTree = createBirthdayTree(N)

	if (N == 1)
		for i=1:365
			birthdayTree(i,:) = i;
		end
	else
		rec = createBirthdayTree(N-1);
		for k=1:length(rec)
			for i=1:365
				birthdayTree(365*(k-1)+i,:) = [rec(k,:) i];
			end
		end
	end

end