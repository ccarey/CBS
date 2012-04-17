function snp_art_batch(varargin)
%% SNP_ART_BATCH
%
% This is a wrapper function for snp_art which runs art with pre-defined
% parameters.
%
% PARAMETERS:
% - Location of Experiment on /ncf/snp/[#]: Provide a single digit number
% - Experiment Name: Name of experiment within /ncf/snp/[#]/., e.g. Catalyst
% - Task Name: This must match the name of the task directory in
% /ncf/snp/[#]/[subjectID]/., e.g. 'EmotID'.
%
% USAGE:
% - This script will create new directories in the subject's main
% directory, e.g. .../Catalyst/2401/., named according to
% [task]_analysis_art, e.g. .../Catalyst/2401/EmotID_analysis_art, and will
% copy the SPM.mat file from the non-art'ed first-level model into this new
% directory.
% - The script then runs ART via snp_art generating all relevant files in
% the new analysis_art directory.
%
% DDF 2/8/2011

	if (length(varargin) ~= 5)
           fprintf(['There is a problem with your input!\n',...
               'Input is: run_level1_package("TEXTFILENAME.txt", "DIRECTORY_PREFIX", "ANALYSIS_FOLDER", PARAMS, "TYPE")\n',...
               '\t TEXTFILENAME.txt is a text file with a list of your subjects in one group separated by spaces, e.g. "szsubs.txt"\n',...
               '\t DIRECTORY_PREFIX is the path to the directory that contains all of the subjects, e.g. "/ncf/snp/04/SCORE/"\n',...
               '\t ANALYSIS_FOLDER is the name of the individual directory where the run files for your task are located, e.g. "word_task/"\n',...
              '\t PARAMS is the name of the individual directory where the run files for your task are located, e.g. "word_task/"\n',...
	       '\t TYPE is the name of the group folder for your subjects, or "NONE" if all subjects are in one group, e.g. "SZ"\n']);
    end

addpath('/ncf/apps/spm8');

    % read subject list
    myfile = varargin{1};
    try
        fid = fopen(myfile);
        C = textscan(fid, '%s');
        fclose(fid);
    catch
        fprintf('There was a problem reading your text file!');
    end

    % define input vars
    directoryPre = varargin{2};
    analysisDir = varargin{3};
    params = varargin{4};
    subjectType = varargin{5};

	scriptDir = pwd();

for i=1:size(C{1})
	subjectNum = char(C{1,1}(i,1));
	% creates subject directory path
	if (strcmp(subjectType,'NONE'))
    		subjectDir = [directoryPre, subjectNum, '/'];
	else
   		subjectDir = [directoryPre, subjectType, '/', subjectNum, '/'];
	end

	task_dir = [subjectDir, analysisDir];
	art_dir = [subjectDir, sprintf('%s_art',analysisDir)];

	% here i need to do some checking of the input...like if the analysis
	% folder actually exists...
	if (exist(art_dir, 'dir') == 7)
    		rmdir(art_dir,'s');
	end

	mkdir(art_dir);

	copyfile([task_dir '/SPM.mat'],art_dir);
    
	fprintf('Running ART for %s %s via snp_art...\n\n', subjectType, subjectNum);

	snp_art([art_dir, '/SPM.mat'],params(1),params(2),params(3),params(4),params(5));
	delete([art_dir, '/SPM.mat']);

	fprintf('\nDone with %s %s!\n\n', subjectType,subjectNum);
	cd(scriptDir);
end

end
    
        
