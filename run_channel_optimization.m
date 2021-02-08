%%%%%
%%%%% This script shows process of applying Classification-Based 
%%%%% Selection (CBS) to a set of densely sampled bank recordings from 
%%%%% a Neuropixel Phase 1 probe.
%%%%% 

function run_channel_optimization(raw_files, ks_dirs, imro_output_filename, fixed_enabled_channels)

if nargin < 4
    fixed_enabled_channels = [];
elseif iscell(fixed_enabled_channels)
    fixed_enabled_channels = cell2mat(fixed_enabled_channels);
end

%%%%%
%%%%% First assemble a cell array of file paths to each dense bank 
%%%%% recording. Recordings are assumed to be high-pass filtered and sorted 
%%%%% by Kilosort2.
%%%%% 

assert(length(raw_files) == length(ks_dirs), 'Need a raw file for each KS dir')

%%%%%
%%%%% Then, specify options. See inside functions below for more options.
%%%%% 

ops.selection_method = 'cbs';  % possible choices: {'cbs', 'mucbs'}
ops.nspikes_per_unit = 100;    % to match paper, set to 100
ops.acq_software = 'openephys'; % openephys, spikeglx

%%%%%
%%%%% Run preprocessing on individual bank recordings
%%%%% 

bank_models = get_bank_model_neuropixel(raw_files, ks_dirs, ops);

%%%%%
%%%%% optimize selection map
%%%%% 
ops.include_third_bank = false; % Only assign channels to bank 0 or 1
ops.do_classifier = true; % runs a classification validation every pass. 
                           % At the end of optimization, the selection
                           % map corresponding with the highest validation
                           % accuracy is chosen. Sometimes this is not the
                           % terminal selection map. If set to false,
                           % CBS skips the validation and just returns the
                           % terminal selection map. In the paper, we used
                           % true.
ops.banks_to_validate = 1:2;   % restricts classification validation to
                               % deepest 2 banks, as used in the paper.
ops.do_plot = false;            % plot optimization summary
ops.save_plot = false;          % save plot summary
ops.plot_dir = 'results'; % plot save directory                             
                             
ops.init_method = 'mucbs';                             
selection_map = optimize_selection_map(bank_models, ops);

%%%%%
%%%%% write output map to an .imro file 
%%%%% 

for i = 1:length(fixed_enabled_channels)
    % Parameter gives 0-based channels, convert to 1-based
    to_enable_channel = fixed_enabled_channels(i) + 1;
    selection_index = find(selection_map == to_enable_channel, 1);
    if ~isempty(selection_index)
        % Already in the array, don't touch
        continue
    end
    if to_enable_channel > 384
        to_disable_channel = to_enable_channel - 384;
    else
        to_disable_channel = to_enable_channel + 384;
    end
    selection_index = find(selection_map == to_disable_channel, 1);
    if isempty(selection_index)
        error('Could not find EITHER the channel to disable or enable');
    end
    selection_map(selection_index) = to_enable_channel;
end

write_cbs_imro_file(imro_output_filename, selection_map, bank_models);

fprintf('\n\nSee results directory for optimization summary plots\n');
end