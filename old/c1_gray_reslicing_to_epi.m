% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/Users/adrien_chopin/Desktop/spm_pipeline/jobs/c1_gray_reslicing_to_epi_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
