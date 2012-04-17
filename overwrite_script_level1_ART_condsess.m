% 
% CBS SPM preprocessing batch package -- Template Overwrite Script
% Created by Caitlin Carey
%
% This script overwrites filler variables generated by the template script.
%
%--------------------------------------------------------------------------

fprintf('Overwriting template preproc batch for %s %s\n',type,subject);

% these are taken from input
subjectNum = subject;
directoryPre = directory;
taskDir = task;
outFolder = outfold;
subjectType = type;

% creates subject directory path
if (strcmp(subjectType,'NONE'))
    subjectDir = [directoryPre, subjectNum, '/'];
else
    subjectDir = [directoryPre, type, '/', subjectNum, '/'];
end

% here i need to do some checking of the input...like if the analysis
% folder actually exists...
if (exist([subjectDir, outFolder], 'dir') == 7)
    rmdir([subjectDir, outFolder],'s');
end

mkdir([subjectDir, outFolder]);

% determines number of runs
runs = length(dir([subjectDir,taskDir, 'run*']));
    
%--------------------------------------------------------------------------

% here i'm not sure if the batch numbers change...so we might need to
% finagle this a bit more

% if we dont have the correct number of runs, throw error
if (length(matlabbatch{1}.spm.stats.fmri_spec.sess) ~= runs)
    error('TestRuns:WrongNum','Subject does not have expected number of runs.');
end 

% creates structure of epis for each run
% need to make this more generic...
for i = 1:runs
    try
        fprintf('Grabbing functionals from %s.\n', [subjectDir, taskDir, 'run', num2str(i), '/']);
        epis = strtrim(ls([subjectDir, taskDir, 'run', num2str(i), '/swrf*.img']));
    catch
        fprintf('Could not locate functionals in %s.\n', [subjectDir, taskDir, 'run', num2str(i), '/']);
        rethrow(lasterror());
    end

    % checks that we have the correct number of epis
    originallen = length(matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans);
    functionals = regexp(epis,'\n','split')';

    % if not, throw error
    if (length(functionals) ~= originallen)
        error('TestEpis:WrongNum','Subject does not have expected number of epis.');
    end

    % if so, replace template epis
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans = functionals;

    try
        regressors = strtrim(ls([subjectDir, taskDir, 'run', num2str(i), '/art_regression_outliers_and_movement_swrf*.mat']));
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg = {regressors}; 
    catch
        fprintf('Could not locate regressors in %s.\n', [subjectDir, taskDir, 'run', num2str(i), '/']);
        rethrow(lasterror());
    end

end

% defines new output folder
matlabbatch{1}.spm.stats.fmri_spec.dir = {[subjectDir, outFolder]};