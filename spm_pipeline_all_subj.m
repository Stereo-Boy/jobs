% This file loops the spm_pipeline3 analysis across all participants,
% calculate variance explained and aggregate the results for all
%
% all dicom files for anatomical and functional should be present in
% parent_path with the structure described in spm_pipeline3
%
participant_list = {'MV40'}; %the subject folders 
analysis_dir = 'spm_stam_thread';           %where the anatomical and functional folders will be located in the subject folders
GLM_dir='GLM'; %where the beta maps will be located in the analysis folder
worktask=1:2; %1 is looping through the spm pipeline, 2 is looping through the result extraction (variance explained, quantiles)
steps=1:4; 

job_path = fileparts(mfilename('fullpath'));
parent_path = fileparts(job_path); %this will bring us in the parent directory of the jobs folder
quantiles=nan(numel(participant_list),4);

if any(worktask==1)
    for s=1:numel(participant_list)
        subject_dir=participant_list{s};
        spm_pipeline3(steps,subject_dir,analysis_dir);
        cd(job_path)
    end
end
if any(worktask==2)
    record_notes(parent_path,'interSS_GLM_distr_spm')
    for s=1:numel(participant_list)
        subject_dir=participant_list{s};
        analysis_path = fullfile(parent_path,subject_dir,analysis_dir);
        glm_path=fullfile(analysis_path,GLM_dir);
        spm_path=fullfile(analysis_path,GLM_dir,'SPM.mat');
        list_epis=list_files(fullfile(analysis_path,'03_epis_nifti'),'r*.nii',1);
        calc_SST(list_epis,glm_path);  
        mask= fullfile(analysis_path,'02_mprage_nifti','gray_mask.nii');%this is epi format gray mask
        [~,quantiles(s,:)] = calc_R2(spm_path,fullfile(glm_path,'SST.nii'), fullfile(glm_path,'ResMS.nii'),glm_path,0,mask); %R2 quantiles for [0.25,0.5,0.75,0.95]
        cd(job_path)
    end
    quantiles
    save('quantiles.mat', 'quantiles')
    figure();
    plot(1:4, quantiles,'o-')
    dispi('Intersubject median of quantile 0.25: ',median(quantiles(:,1)))
    dispi('Intersubject median of quantile 0.5: ',median(quantiles(:,2)))
    dispi('Intersubject median of quantile 0.75: ',median(quantiles(:,3)))
    dispi('Intersubject median of quantile 0.95: ',median(quantiles(:,4)))
end