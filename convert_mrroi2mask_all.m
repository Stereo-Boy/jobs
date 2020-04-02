function convert_mrroi2mask_all(participant_list)

% convert all ROIs in roi_dir for participants in participant_list from
% volume coords to masks (0,1) in the volume format

if exist('participant_list','var')==0; participant_list = {'MV40'}; end %the subject folders
%if exist('participant_list','var')==0; participant_list = {'AM52','CL90','DC95','EM21','HB85','KK100','KM79',...
%        'KR104','LYY65','MC105','MH99','MS09','MV40','MV106','RN31','SO81'}; end %the subject folders
analysis_dir = 'retinotopic_rois';           %where the ROIs and volume will be located
roi_dir = 'ROIs'; %where the actual roi.mat will be located
job_path = fileparts(mfilename('fullpath'));
parent_path = fileparts(job_path); %this will bring us in the parent directory of the jobs folder

for p=1:numel(participant_list)
    dispi('Converting ROIs for ',participant_list{p})
    subject_dir=participant_list{p};
    disp('Cleaning up existing  ROI nii files')
    cd(fullfile(parent_path,subject_dir,analysis_dir,roi_dir))
    delete *.nii

    list_rois=list_files(fullfile(parent_path,subject_dir,analysis_dir,roi_dir),'*.mat',1);
    nameROIS=list_files(fullfile(parent_path,subject_dir,analysis_dir,roi_dir),'*.mat',0);
    volume=fullfile(parent_path,subject_dir,analysis_dir,[subject_dir,'_nu_RAS_NoRS.nii.gz']);
    if check_files(fileparts(volume),volume,1,0);          gunzip(volume); else
    disp('This warning only mean that the file is already unzipped');end
    volume_ni=fullfile(parent_path,subject_dir,analysis_dir,[subject_dir,'_nu_RAS_NoRS.nii']);
    for r=1:numel(list_rois)
        [~,n_vox]=create_ROI_volume_mask(volume_ni,list_rois{r});  % convert the roi in the volume space, as a binary mask
        dispi('Done with ',subject_dir,': ',nameROIS{r},' (',n_vox,' voxels)')
    end
end

end