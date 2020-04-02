function spm_coregister(src, ref, other)
% this is a function that simply use the co-register estimate+reslice with
% default parameters in spm. Put your source file in src (the one to be modified), the ref file
% in ref (the one to align to) and the other files in other (in a cell array) so that they
% are also aligned to the ref in the operation.

matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {ref};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {src};
matlabbatch{1}.spm.spatial.coreg.estwrite.other =  cellstr(other);
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
spm_jobman('run', matlabbatch);