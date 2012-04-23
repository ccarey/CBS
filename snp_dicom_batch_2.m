function snp_dicom_batch_2
%% SNP_DICOM_BATCH_2
%
% Converts dicoms and sorts converted images into appropriate
% directories for the specified sequences.
%
% NOTES:
% - All dicom images must be in a directory named 'RAW' within each
% subject's directory, e.g. /ncf/snp/08/FAME/FHR/2501/RAW.
% - Directories for each sequences will be named according to the name
% provided for 'Sequence name'.
% - Run numbers should correspond to those recorded at the scanner.
% - When entering more than 1 run number, provide the runs in vector format with
% square brackets, e.g. [14 15 16 17] or [14:17].
%
% DDF 11/9/10
%  - Originally scripted
%
% DDF 11/6/11 (about 1 year later...thought it's time for an update)
%  - Ask for full path to data instead of experiment location, name and
%  subject ID separately.
%  - Ask to create run and analysis directories instead of whether the run
%  is a structural or functional.
%  - To ever so slightly increase compatibility with cbsget, code is set to
%  expect the RAW directory to be named in capitals, i.e. RAW, not raw.

clc;
fprintf('***DICOM Conversion***\n\n');
rootdir = input('Path to data, e.g. /ncf/snp/08/FAME/FHR/2501: ','s');
subjID_parentheses = find(rootdir=='/');
subjID = rootdir(subjID_parentheses(end)+1:end);

fprintf('\n***Please enter the sequence name and corresponding run numbers***\n\n');
more = 1;
iteration = 0;
while more == 1
    iteration = iteration + 1;
    task_name = input('Sequence name: ','s');
    run_nums = input(sprintf('Run numbers for %s: ',task_name));
    type = input('Create run and analysis directories? [y/n]: ','s');
    task_dir = fullfile(rootdir,task_name);
    mkdir(task_dir);
    
    if type == 'y'
        mkdir(sprintf('%s_analysis',task_dir));
        for run = 1:length(run_nums)
            run_dir = fullfile(rootdir,task_name,sprintf('run%d',run));
            mkdir(run_dir);
        end
    end
    
    % save task name and run numbers
    run_info{iteration}.name = task_name;
    run_info{iteration}.runs = run_nums;
    run_info{iteration}.doodle = type;
    save([rootdir '/' subjID '_run_info.mat'],'run_info');
    
    done = input('Add additional sequence? [y/n]: ','s');
    if done == 'n'
        more = 2;
    end
    fprintf('\n');
end

batch_dir = fullfile(rootdir,'batch');
mkdir(batch_dir);
clear iteration task_name type run_nums task_dir run_dir;
correct = input('Are these values correct? [y/n]: ','s');
if correct == 'n'
    catalyst_dicom_convert
end

fprintf('\nConverting DICOMS for subject %s in %s \n',subjID,rootdir);

% % find dicoms to be converted, read headers, then convert
cd(fullfile(rootdir,'RAW'))
dicom_files = spm_select('list',fullfile(rootdir,'RAW'),'.*');
hdrs = spm_dicom_headers(dicom_files);
spm_dicom_convert(hdrs,'all');
clear dicom_files hdrs;

% % load saved run info and move files
load([rootdir '/' subjID '_run_info.mat']);
fprintf('Relocating DICOMS for subject %s\n',subjID);

for run = 1:length(run_info)
    if run_info{run}.doodle == 'n'
        for task_run = 1:length(run_info{run}.runs)
            try
                movefile(sprintf('*-%.4d-*',run_info{run}.runs(task_run)),fullfile(rootdir,run_info{run}.name));
            catch 
                fprintf('Error: Could not move images for run %d of %s -- run number may be incorrect\n',run_info{run}.runs(task_run),run_info{run}.name);
            end
        end
    elseif run_info{run}.doodle == 'y'
        for task_run = 1:length(run_info{run}.runs)
            try
                movefile(sprintf('*-%.4d-*',run_info{run}.runs(task_run)),fullfile(rootdir,run_info{run}.name,num2str(sprintf('run%d',task_run))));
            catch 
                fprintf('Error: Could not move images for run %d of %s -- run number may be incorrect\n',run_info{run}.runs(task_run),run_info{run}.name);
            end
        end
    end
end

fprintf('Done!\n');
end % function


