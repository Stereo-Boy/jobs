function spm_pipeline3(steps,subject_dir,analysis_dir)
% main spm pipeline function to analyse stam data and obtain beta for
% later mvpa

% expected folder structures is (and can be created automatically with
% create_folder_structure)
% [parent_path] > [subject_dir] > [analysis_dir]    > [t1_dicom_dir]    > mprage > (with the t1 files)
%                                                   > [epi_dicom_dir]   > epi01(...) > (with the epis of run 1)
%                                                                       > epi02(...) > (with the epis of run 2)
%                                                                       > (...)
%                                                   > [par_dir]         > [sots_epi]01.mat (onset file for run 1)
%                                                                           (...)
%               > jobs          > (with all the different batch and scripts)   
%
% steps (defaut 1:3) are the steps to proceed for the participant
%   1: t1 import (conversion dicom to nifiti)
%   2: epi pre-procesing/model spec: includes dicom to nifti, moco, model
%   spec and estimation
%   3: t1 pre-processing (register to functional + segmentation)

if exist('steps','var')==0;steps = 1:4;end
if exist('subject_dir','var')==0;subject_dir='KK100';end
if exist('analysis_dir','var')==0;analysis_dir = 'spm_stam_thread';end

job_path = fileparts(mfilename('fullpath'));
parent_path = fileparts(job_path); %this will bring us in the parent directory of the jobs folder

analysis_path = fullfile(parent_path,subject_dir,analysis_dir);
check_folder(analysis_path,1); % which is the analysis folder
record_notes(analysis_path,'spm_pipeline_log')
disp('----- START OF THE PIPELINE --------- ')
dispi('Analysis path: ', analysis_path)
t1_dicom_dir = fullfile(analysis_path,'01a_mprage_DICOM','mprage'); %where the t1 dicom files are stored
check_folder(t1_dicom_dir,1);
epi_dicom_dir = fullfile(analysis_path,'01b_stam_DICOM'); % where the dicom epis are stored in epi01, epi02 ... folders
check_folder(epi_dicom_dir,1);
par_dir = fullfile(analysis_path,'onsets_files'); %where the onsets files are stores for loading as a multiple condition for each epi - all .mat there will be taken
model_onset_file= 'sots_epi'; %a model around which one can name the onset file (it will add 01, 02, 03...at the end)
check_folder(par_dir,1);
t1_nii_dir = '02_mprage_nifti'; %where we will store the nifti converted t1 files (will create that folder in the analysis folder)
epi_nii_dir = '03_epis_nifti'; %where we will store the nifti converted epi files (will create that folder in the analysis folder)
spm('defaults', 'FMRI');

%                                   T1_IMPORT SCRIPT
% --------------------------------------------------------------------------------------------
if any(steps==1)
    disp(' ----------------- RUNNING T1_IMPORT SCRIPT ----------------- ')
    t1_import_jobfile = fullfile(job_path,'t1_import3_job.m'); 
    % batch script for importing t1
    % The batch needs the name of the analysis folder, and the location of
    % the t1 dicom files to convert into nifti, as a list of files to convert. It will create a folder
    % t1_nii_dir to store the converted t1 nifti files, a GLM folder for the stats results. Then it will
    % convert the t1 dicom into nifti (but not the epis).
    
    inputs = cell(2, 1);
    inputs{1} = {analysis_path}; % Named Directory Selector: Directory - cfg_files - the analysis folder
    inputs{2} = t1_nii_dir; %where we will store the nifti converted t1 files (will create that folder in the analysis folder)
    inputs{3} = epi_nii_dir; %where we will store the nifti converted epis files (will create that folder in the analysis folder)
    inputs{4} = list_files(t1_dicom_dir,'*',1)'; % DICOM Import: DICOM files - cfg_files (needs absolute paths)
    dispi('We are converting the following ', numel(inputs{4}),' t1 files:')
    disp(inputs{4})
    dispi('Running: ', t1_import_jobfile)
    spm_jobman('run', t1_import_jobfile, inputs{:});
    check_folder(par_dir,1);
    check_folder(fullfile(analysis_path,t1_nii_dir),1);
    check_folder(fullfile(analysis_path,epi_nii_dir),1);
end

%                                   EPI_PRE_PROCESSING + MODEL SPEC
% --------------------------------------------------------------------------------------------
if any(steps==2)
    % epi_preprocess_jobfile = fullfile(job_path,'epi_preprocessing3_job.m'); UNUSED
    % batch script for importing and pre-processing epis 
    % The batch needs the name of the analysis folder, and the location of
    % the epi dicom files to convert into nifti, as a list of files to convert. It will create a folder
    % epi_nii_dir to store the converted epi nifti files for all runs. It will moco to
    % the first TR of the first epi, reslice, check alignment, create a GLM folder if needed, run 
    % the GLM and put the SPM.mat files and beta maps in those folders. We
    % also use the rp_ as regressors, so they need to be provided.
    
    list_epis_dirs = list_folders(epi_dicom_dir,'*epi*')';
    nrun = numel(list_epis_dirs); % enter the number of runs
    dispi('Nb of runs: ',nrun)
    dispi('We will work with epi folders:')
    disp(list_epis_dirs)
    %jobs = repmat({epi_preprocess_jobfile}, 1, nrun);
    list_all_epi_nii=cell(nrun,1);
    onset_files=cell(nrun,1);
    % DICOM TO NIFTI
    for crun = 1:nrun
        dispi('Converting to DICOM: ',list_epis_dirs{crun})
        list_epis_Files=list_files(fullfile(epi_dicom_dir,list_epis_dirs{crun}),'*',1)';
        for i=1:numel(list_epis_Files)
            hdr = spm_dicom_headers(list_epis_Files{i}, 0);
            out = spm_dicom_convert(hdr,'all','flat','nii',fullfile(analysis_path,epi_nii_dir));
            list_epis_nii(i,1) = out.files;
            if (crun==1) && (i==1)
                first_TR = list_epis_nii{i,1};%this is the first TR of the first epis - everything is corrected to it
            end
            if (crun==round(nrun/2)) && (i==round(numel(list_epis_Files)/2))
                middle_TR = list_epis_nii{i,1};%this is the middle TR of the middle epis - for later comparison
            end
        end
        dispi('Conversion done for : ',numel(list_epis_nii),' epi files')
        list_all_epi_nii{crun}=list_epis_nii;
        onset_files{crun}=fullfile(par_dir,[model_onset_file,sprintf('%02.0f',crun),'.mat']);
    end
    
    % MOCO
    for crun = 1:nrun
        matlabbatch{1}.spm.spatial.realign.estwrite.data{crun} = cellstr(list_all_epi_nii{crun});
    end
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    %save('moco_est_reslice','matlabbatch');
    disp('Run Motion correction: moco (est_reslice)')
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
    % CHECK REG
    disp('Check registration of first TR of first epi and middle TR of middle epi')
    matlabbatch{1}.spm.util.checkreg.data = {first_TR;middle_TR};
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
    % MODEL SPEC / REVIEW / ESTIMATE
    disp('MODEL SPEC / REVIEW / ESTIMATE')
    glm_dir = fullfile(analysis_path,'GLM');
    check_folder(glm_dir, 0); %will be created
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {glm_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.2428;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    rp_list=list_files(fullfile(analysis_path,epi_nii_dir),'rp_*',1)'; %for regressing the motion correction parameters of each run
    for ses=1:nrun
        list=cell(numel(list_all_epi_nii{ses}),1);
        for i=1:numel(list_all_epi_nii{ses})
            [a,b,c]=fileparts(list_all_epi_nii{ses}{i});
            list{i}=fullfile(a,['r',b,c]);
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).scans = cellstr(list);
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).multi = onset_files(ses);
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).hpf = 128;
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).multi_reg = rp_list(ses);  
    end
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.review.spmmat(1) = {fullfile(glm_dir,'SPM.mat')};
    matlabbatch{2}.spm.stats.review.display.matrix = 1;
    matlabbatch{2}.spm.stats.review.print = 'ps';
    matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = {fullfile(glm_dir,'SPM.mat')};
    matlabbatch{3}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    spm_jobman('run', matlabbatch);
    clear matlabbatch
   

end

%                                   T1 PREPROCESSING
% --------------------------------------------------------------------------------------------
if any(steps==3)
    inputs=cell(2,1);
    t1_preprocess_jobfile = fullfile(job_path,'t1_preprocess3_job.m');
    % batch script for pre-processing the t1 
    % The batch needs the name of the analysis folder, and the location of
    % the t1 nifti file and epi files. 
    % It will first segment the t1, show what the gray matter looks like and then will register the t1 and c1 to the first
    % TR of the first epi in the epi folder, and show the alignment. It
    % will reslice too and rename the resliced c1 to gray_mask.nii.
 
    dispi('We will run ', t1_preprocess_jobfile)
    listEpisF = list_files(fullfile(analysis_path,epi_nii_dir),'rf*nii',1)';
    listT1F=list_files(fullfile(analysis_path,t1_nii_dir),'s*nii',1)';
    inputs{1} = listT1F(1); %this is the t1 - for segmentation 
    dispi('We will segment ',cell2mat(inputs{1}));
    inputs{2} = listEpisF(1); % this is the epi - Coregister: Estimate: Reference Image - cfg_files
    inputs{3} = listT1F(1); %this is the t1 - for est+resl this time  
    dispi('We will coregister (and reslice) ',cell2mat(inputs{3}), ' to ', cell2mat(inputs{2}));
    dispi('along with the segmented c1 file')
    spm_jobman('run', t1_preprocess_jobfile, inputs{:});
    dispi('Now we rename the rc1 file to gray_mask.nii')
    path2rC1=list_files(fullfile(analysis_path,t1_nii_dir),'rc1*nii',1);
    %transform the c1 gray realigned file into a logical gray mask
     disp('Converting the realigned c1 gray file into a logical gray_mask.nii')
     V=spm_vol(path2rC1);
     [Y,~] = spm_read_vols(V{1});
     mask=logical(Y>0.5);
     V{1}.fname=fullfile(analysis_path,t1_nii_dir,'gray_mask.nii');
     dispi('gray_mask.nii will be in ',fullfile(analysis_path,t1_nii_dir))
     spm_write_vol(V{1},mask);
     %copyfile(path2rC1{1},fullfile(analysis_path,t1_nii_dir,'gray_mask.nii'));
end



% %                                   T1 PREPROCESSING
% % --------------------------------------------------------------------------------------------
% if any(steps==3)
%     inputs=cell(2,1);
%     t1_preprocess_jobfile = fullfile(job_path,'t1_preprocessing3_job.m');
%     % batch script for pre-processing the t1 
%     % The batch needs the name of the analysis folder, and the location of
%     % the t1 nifti file and epi files. It will register the t1 to the first
%     % TR of the first epi in the epi folder, show the alignment and then segment the t1
%     % and show what the gray matter looks like
%  
%     dispi('We will run ', t1_preprocess_jobfile)
%     listEpisF = list_files(fullfile(analysis_path,epi_nii_dir),'*nii',1)';
%     listT1F=list_files(fullfile(analysis_path,t1_nii_dir),'s*nii',1)';
%     inputs{1} = listEpisF(1); % Coregister: Estimate: Reference Image - cfg_files
%     inputs{2} = listT1F(1); % Coregister: Estimate: Source Image - cfg_files
%     dispi('We coregister ',cell2mat(inputs{2}), ' to ', cell2mat(inputs{1}));
%     spm_jobman('run', t1_preprocess_jobfile, inputs{:});
% end
% 
% if any(steps==4) %here we reslice the c1 file into epi format
%     inputs=cell(2,1);
%     t1_preprocess_jobfile = fullfile(job_path,'t1_preprocessing3_job.m');
%     % batch script for pre-processing the t1 
%     % The batch needs the name of the analysis folder, and the location of
%     % the t1 nifti file and epi files. It will register the t1 to the first
%     % TR of the first epi in the epi folder, show the alignment and then segment the t1
%     % and show what the gray matter looks like
%  
%     dispi('We will run ', t1_preprocess_jobfile)
%     listEpisF = list_files(fullfile(analysis_path,epi_nii_dir),'*nii',1)';
%     listT1F=list_files(fullfile(analysis_path,t1_nii_dir),'s*nii',1)';
%     inputs{1} = listEpisF(1); % Coregister: Estimate: Reference Image - cfg_files
%     inputs{2} = listT1F(1); % Coregister: Estimate: Source Image - cfg_files
%     dispi('We coregister ',cell2mat(inputs{2}), ' to ', cell2mat(inputs{1}));
%     spm_jobman('run', t1_preprocess_jobfile, inputs{:});
% end

