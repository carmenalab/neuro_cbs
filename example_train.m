%%%%%
%%%%% This script shows process of applying Classification-Based 
%%%%% Selection (CBS) to a set of densely sampled bank recordings from 
%%%%% a Neuropixel Phase 1 probe.
%%%%% 

clear;

%%%%%
%%%%% First assemble a cell array of file paths to each dense bank 
%%%%% recording. Recordings are assumed to be high-pass filtered and sorted 
%%%%% by Kilosort2.
%%%%% 

% Should be the settings.xml to parse
raw_files = {...
    '/Users/pbotros/Desktop/rat_np_data/2021-02-02_08-29-12/experiment1/recording1/continuous/Neuropix-PXI-100.0/continuous.dat', ...
    '/Users/pbotros/Desktop/rat_np_data/2021-02-02_08-32-25/experiment1/recording1/continuous/Neuropix-PXI-100.0/continuous.dat', ...
    };
ks_dirs = {...
    '/Users/pbotros/Desktop/rat_np_data/2021-02-02_08-29-12', ...
    '/Users/pbotros/Desktop/rat_np_data/2021-02-02_08-32-25', ...
    };

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
ops.do_plot = true;            % plot optimization summary
ops.save_plot = false;          % save plot summary
ops.plot_dir = '../results'; % plot save directory                             
                             
ops.init_method = 'mucbs';                             
selection_map = optimize_selection_map(bank_models, ops);

%%%%%
%%%%% write output map to an .imro file 
%%%%% 

imro_file_path = 'results/cbs_map.imro';
write_cbs_imro_file(imro_file_path, selection_map, bank_models);

fprintf('\n\nSee results directory for optimization summary plots\n');