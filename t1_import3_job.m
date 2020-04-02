%-----------------------------------------------------------------------
% Job saved on 12-Mar-2018 12:56:52 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.name = 'Analysis_directory';
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {'<UNDEFINED>'};
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_cd.dir(1) = cfg_dep('Named Directory Selector: Analysis_directory(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent(1) = cfg_dep('Named Directory Selector: Analysis_directory(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'GLM';
matlabbatch{4}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent(1) = cfg_dep('Named Directory Selector: Analysis_directory(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{4}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = '<UNDEFINED>';
matlabbatch{5}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent(1) = cfg_dep('Named Directory Selector: Analysis_directory(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{5}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = '<UNDEFINED>';
matlabbatch{6}.spm.util.import.dicom.data = '<UNDEFINED>';
matlabbatch{6}.spm.util.import.dicom.root = 'flat';
matlabbatch{6}.spm.util.import.dicom.outdir(1) = cfg_dep('Make Directory: Make Directory ''02_mprage_nifti''', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dir'));
matlabbatch{6}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{6}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{6}.spm.util.import.dicom.convopts.icedims = 0;
