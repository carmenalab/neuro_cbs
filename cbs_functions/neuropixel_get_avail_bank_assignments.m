function avail = neuropixel_get_avail_bank_assignments(ops, ch, include_third_bank)

% assumes a 1-based channel
% returns 0-based bank values

fixed_index_bank_0 = find(ch - 1 == ops.fixed_enabled_channels, 1);
fixed_index_bank_1 = find(ch - 1 + 384 == ops.fixed_enabled_channels, 1);
fixed_index_bank_2 = find(ch - 1 + 384 * 2 == ops.fixed_enabled_channels, 1);
if ~isempty(fixed_index_bank_0)
  avail = [0];
  return;
elseif ~isempty(fixed_index_bank_1)
  avail = [1];
  return;
elseif ~isempty(fixed_index_bank_2)
  avail = [2];
  return;
end

if include_third_bank
	if ch > 192
	    avail = [0, 1];
	else
	    avail = [0, 1, 2];
	end
else
	avail = [0, 1];
end
