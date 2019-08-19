%%
% Author: Francois Van Lishout
% Date : 06/02/2014
%
% This function returns 1 if at least two people are born on the same day
% and 0 otherwise.
%
% Arguments:
%   dayList
%        a vector containing birthday days (integers between 1 and 365)

function bool = sameDay(dayList)

	bool = 0;

	srtDayList = sort(dayList);
	for i=1:length(srtDayList)-1
	    if (srtDayList(i)==srtDayList(i+1))
	        bool = 1;
	        break;
	    end
	end

end
