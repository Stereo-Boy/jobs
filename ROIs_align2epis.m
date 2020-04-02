function ROIs_align2epis(participant_list)
% align and reslice all ROIs into epi format - 1st tR of 1st EPI (so that it can be used as a mask for the
% betas) using the volume registration to the epi
% At the end, it also call join_ROI_mask_hemi to join together left and
% right hemispheres ROIs

if exist('participant_list','var')==0; participant_list = {'MV40'}; end %the subject folders
 %if exist('participant_list','var')==0; participant_list = {'AM52','CL90','DC95','EM21','HB85','KK100','KM79',...
%        'KR104','LYY65','MC105','MH99','MS09','MV40','MV106','RN31','SO81'}; end %the subject folders

job_path = fileparts(mfilename('fullpath'));
spm_pipeline_path = fileparts(job_path);
retino_dir='retinotopic_rois';
analysis_dir='spm_stam_thread';
epi_dir='03_epis_nifti';
%mprage_dir='02_mprage_nifti';
for p=1:numel(participant_list)
    subject_dir=participant_list{p};
    subject_path=fullfile(spm_pipeline_path,subject_dir);
    ref=list_files(fullfile(subject_path,analysis_dir,epi_dir),'r*',1); %1st TR of 1st EPI
    dispi('Reference: ', ref{1})
    src=fullfile(subject_path,retino_dir,[subject_dir,'_nu_RAS_NoRS.nii']);
    dispi('Source: ', src)
    other = list_files(fullfile(subject_path,retino_dir,'ROIs'),'ROI*.nii',1)';
    dispi('Others: ', other)
    %other(end+1)= list_files(fullfile(subject_path,analysis_dir,mprage_dir),'c1*.nii',1)';
    
    % coregister
    spm_coregister(src, ref{1}, other)
    
    % check coregistration
    coregistered=list_files(fullfile(subject_path,retino_dir),'r*_nu_RAS_NoRS.nii',1);
    matlabbatch{1}.spm.util.checkreg.data = {ref{1}; coregistered{1}};
    spm_jobman('run', matlabbatch);
    
    
    % join common ROIs across hemispheres
    join_ROI_mask_hemi(fullfile(subject_path,retino_dir,'ROIs'),'rROI_*.nii','L','R', 6,'m')

%     %transform the c1 gray realigned file into a logical gray mask
%     disp('Converting the realigned c1 gray file into a logical gray_mask.nii')
%     x=list_files(fullfile(subject_path,analysis_dir,mprage_dir),'rc1*.nii',1);
%     V=spm_vol(x);
%     [Y,XYZ] = spm_read_vols(V{1});
%     mask=logical(Y>0.5);
%     abs_path_gray=fileparts(x{1}); 
%     V{1}.fname=fullfile(abs_path_gray,'gray_mask.nii');
%     spm_write_vol(V{1},mask);
end
