% List of open inputs
% Coregister: Estimate: Reference Image - cfg_files
% Coregister: Estimate: Source Image - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/Users/adrien_chopin/Desktop/spm_help/mv40_tet_spm_all_epis/jobs/t1_preprocessing_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Coregister: Estimate: Reference Image - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Coregister: Estimate: Source Image - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
