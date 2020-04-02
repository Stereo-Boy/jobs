function create_folder_structure(participant_list)
%create the folder structure for the analysis but also feed it with files
%that should be there

%if exist('participant_list','var')==0; participant_list = {'AM52','DC95'}; end %the subject folders
if exist('participant_list','var')==0; participant_list = {'AM52','CL90','DC95','EM21','HB85','KK100','KM79',...
        'KR104','LYY65','MC105','MH99','MS09','MV40','MV106','RN31','SO81'}; end %the subject folders

job_path = fileparts(mfilename('fullpath'));
addpath(job_path);
spm_pipeline_path = fileparts(job_path); %this will bring us in the parent directory of the jobs folder
desktop_path=fileparts(spm_pipeline_path);
data_path = fullfile(desktop_path,'Data Sync 2018'); 
analysis_dir = 'spm_stam_thread'; 
retino_dir = 'retinotopic_rois';           %where the ROIs and volume will be located
roi_dir = 'ROIs'; %where the actual roi.mat will be located

for p=1:numel(participant_list)
    try
    subject_dir=participant_list{p};
    dispi('Starting with participant ',subject_dir)
    %creates participant dir and inner folders
        dispi('Structure in spm')
        subject_path=fullfile(spm_pipeline_path,subject_dir);
        check_folder(subject_path,0);
        analysis_path=fullfile(subject_path,analysis_dir);
        check_folder(analysis_path,0);
        retino_path=fullfile(subject_path,retino_dir);
        check_folder(retino_path,0);
        roi_path=fullfile(retino_path,roi_dir);
        check_folder(roi_path,0);
        
    %populate folders with files       
        %ROIS
        dispi('ROIs')
        subject_pRF_path_src=fullfile(data_path,'retinotopic_drawings_6_8_18',[subject_dir,'_pRF_selected_runs']);
        roi_path_src=fullfile(fullfile(subject_pRF_path_src,'06_retino_mrSession'),'Volume','ROIs'); %where the ROIs are coming from
        copy_files(roi_path_src,'*.mat',roi_path)
        
        %Volume for ROIs
        disp('Volume for ROIs')
        copy_files(fullfile(subject_pRF_path_src,'04_mprage_nifti_fixed'),'*_nu_RAS_NoRS.nii*',retino_path)  
        
%         OOPS I did that manually!
%         %DICOM for mprage 
%         disp('DICOM for mprage')
         subject_path_src=fullfile(data_path,subject_dir,[subject_dir,' Stam selected runs Pre']);
%         t1_dicom_path_src = fullfile(subject_path_src, '01a_mprage_DICOM','mprage'); %where the t1 dicom files are stored
%         if exist(t1_dicom_path_src,'dir')==0; t1_dicom_path_src = fullfile(data_path,subject_dir,'mprage'); end
%         t1_dicom_path_dest = fullfile(analysis_path,'01a_mprage_DICOM');
%         check_folder(t1_dicom_path_dest,0);
%         copy_files(t1_dicom_path_src,'*.dcm',t1_dicom_path_dest)

        %DICOM for epis
        disp('DICOM for epis')
        epi_dicom_path_src = fullfile(subject_path_src,'01b_stam_DICOM'); %where the t1 dicom files are stored
        %if exist(t1_dicom_path_src,'dir')==0; t1_dicom_path_src = fullfile(data_path,subject_dir,'mprage'); end
        epi_dicom_path_dest = fullfile(analysis_path,'01b_stam_DICOM');
        check_folder(epi_dicom_path_dest,0);
        cell_dist('copyfile_alias',list_folders(epi_dicom_path_src,'epi*',0),epi_dicom_path_src,'*.dcm',epi_dicom_path_dest)
     
%         OOPS I did that manually!
%         %Onset files from PAR files
%         disp('PAR files and onset files')
%         PAR_path = fullfile(subject_path_src,'Parfiles'); 
%         cd(PAR_path);
%         par2onsets2   
%         model_onset_file= 'sots_epi'; %a model around which one can name the onset file (it will add 01, 02, 03...at the end)
%         onset_path = fullfile(analysis_path,'onsets_files'); %where the onsets files are stores for loading as a multiple condition for each epi - all .mat there will be taken
%         check_folder(onset_path,0);
%         copy_files(PAR_path,['*',model_onset_file,'*'],onset_path)

    catch err
        warni('Something went wront with that participant: ',subject_dir,'. Please check carefully')
        dispi('Error was:')
        disp(err)
        disp(err.cause)
    end

end

end


