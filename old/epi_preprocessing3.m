% List of open inputs
% Realign: Estimate & Reslice: Session - cfg_files
% fMRI model specification: Directory - cfg_files
% fMRI model specification: Multiple conditions - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/Users/adrien_chopin/Desktop/spm_help/jobs/epi_preprocessing2_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Realign: Estimate & Reslice: Session - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Directory - cfg_files
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Multiple conditions - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
