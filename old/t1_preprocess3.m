% List of open inputs
% Segment: Volumes - cfg_files
% Coregister: Estimate & Reslice: Reference Image - cfg_files
% Coregister: Estimate & Reslice: Source Image - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/Users/adrien_chopin/Desktop/t1_preproc_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Segment: Volumes - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Coregister: Estimate & Reslice: Reference Image - cfg_files
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Coregister: Estimate & Reslice: Source Image - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
