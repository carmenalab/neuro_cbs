function avail = neuropixel_get_avail_bank_assignments(ch, include_third_bank)

% assumes a 1-based channel
% returns 0-based bank values
if include_third_bank
	if ch > 192
	    avail = [0, 1];
	else
	    avail = [0, 1, 2];
	end
else
	avail = [0, 1];
end