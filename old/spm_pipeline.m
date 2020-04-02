% List of open inputs
% Named Directory Selector: Directory - cfg_files
% DICOM Import: DICOM files - cfg_files

% PARAMETERS FOR ALL SCRIPTS
% expected folder structures is
% subject_dir > [analysis_dir]      > [t1_dicom_dir]    > (with the t1 files)
%                                   > [epi_dicom_dir]   > epi01 > (with the epis of run 1)
%                                                       > epi02 > (with the epis of run 2)
%                                                       > (...)
%                                   > [par_dir]       > [sots_epi]01.mat (onset file for run 1)
%                                    (...)
% jobs          > (with all the different batch and scripts)   
%
steps = 1:3;
disp('----- START OF THE PIPELINE --------- ')
subject_dir='MV40';
analysis_dir = 'spm_stam_thread';
job_path = fileparts(mfilename('fullpath'));
parent_path = fileparts(job_path); %this will bring us in the parent directory of the jobs folder
analysis_path = fullfile(parent_path,subject_dir,analysis_dir);
check_folder(analysis_path,1); % which is the analysis folder
dispi('Analysis path: ', analysis_path)
t1_dicom_dir = fullfile(analysis_path,'01a_mprage_DICOM','t1mprage'); %where the t1 dicom files are stored
check_folder(t1_dicom_dir,1);
epi_dicom_dir = fullfile(analysis_path,'01b_stam_DICOM'); % where the dicom epis are stored in epi01, epi02 ... folders
check_folder(epi_dicom_dir,1);
par_dir = fullfile(analysis_path,'PAR_files'); %where the onsets files are stores for loading as a multiple condition for each epi - all .mat there will be taken
model_onset_file= 'sots_epi'; %a model around which one can name the onset file (it will add 01, 02, 03...at the end)
check_folder(par_dir,1);
t1_nii_dir = '02_mprage_nifti'; %where we will store the nifti converted t1 files (will create that folder in the analysis folder)
epi_nii_dir = '03_epis_nifti'; %where we will store the nifti converted epi files (will create that folder in the analysis folder)
spm('defaults', 'FMRI');

%                                   T1_IMPORT SCRIPT
% --------------------------------------------------------------------------------------------
if any(steps==1)
    disp(' ----------------- RUNNING T1_IMPORT SCRIPT ----------------- ')
    t1_import_jobfile = fullfile(job_path,'t1_import_job.m'); 
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
    check_folder(fullfile(analysis_path,par_dir),1);
    check_folder(fullfile(analysis_path,t1_nii_dir),1);
    check_folder(fullfile(analysis_path,epi_nii_dir),1);
end

%                                   EPI_PRE_PROCESSING + MODEL SPEC
% --------------------------------------------------------------------------------------------
if any(steps==2)
    epi_preprocess_jobfile = fullfile(job_path,'epi_preprocessing2_job.m');
    % batch script for importing and pre-processing epis 
    % The batch needs the name of the analysis folder, and the location of
    % the epi dicom files to convert into nifti, as a list of files to convert. It will create a folder
    % epi_nii_dir to store the converted epi nifti files from all runs. For each run separately, it will moco to
    % the first TR of the first epi, reslice, check alignment, reslice, define a GLM folder for each run, run 
    % the GLM and put the SPM.mat files and beta maps in those folders. It
    % adds the first TR of the first epi in the list for moco, which
    % explains why we cannot use the rp_ (it has and additionnal TR)
    
    list_epis_dirs = get_dir(epi_dicom_dir,'*epi*')';
    nrun = numel(list_epis_dirs); % enter the number of runs
    dispi('Nb of runs: ',nrun)
    dispi('We will work with epi folders:')
    disp(list_epis_dirs)
    jobs = repmat({epi_preprocess_jobfile}, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        dispi('Converting to DICOM')
        list_epis_Files=list_files(list_epis_dirs{crun},'*',1)';
        list_epis_nii=cell(numel(list_epis_Files),1);
        for i=1:numel(list_epis_Files)
            hdr = spm_dicom_headers(list_epis_Files{i}, 0);
            out = spm_dicom_convert(hdr,'all','flat','nii',fullfile(analysis_path,epi_nii_dir));
            list_epis_nii(i) = out.files;
            if (crun==1) && (i==1)
                first_TR = list_epis_nii(i);%this is the first TR of the first epis - everything is corrected to it
            end
        end
        disp('...done')
        dispi('Later, we will run ', epi_preprocess_jobfile, ' for run ', crun,'with files:')
        disp([first_TR(1);list_epis_nii(:)])
        glm_dir = fullfile(analysis_path,sprintf('GLM_epi%02.0f',crun));
        check_folder(glm_dir, 0); %will be created
        inputs{1, crun} = [first_TR(1);list_epis_nii(:)];% % Realign: Estimate & Reslice: Session - cfg_files
        inputs{2, crun} = {glm_dir}; % fMRI model specification: Directory - cfg_files
        inputs{3, crun} = {fullfile(par_dir,[model_onset_file,sprintf('%02.0f',crun),'.mat'])}; % fMRI model specification: Multiple conditions - cfg_files
    end
    spm_jobman('run', jobs, inputs{:});
end

%                                   T1 PREPROCESSING
% --------------------------------------------------------------------------------------------
if any(steps==3)
    inputs=cell(2,1);
    t1_preprocess_jobfile = fullfile(job_path,'t1_preprocessing_job.m');
    % batch script for pre-processing the t1 
    % The batch needs the name of the analysis folder, and the location of
    % the t1 nifti file and epi files. It will register the t1 to the first
    % TR of the first epi in the epi folder, show the alignment and then segment the t1
    % and show what the gray matter looks like
 
    dispi('We will run ', t1_preprocess_jobfile)
    listEpisF = list_files(fullfile(analysis_path,epi_nii_dir),'*nii',1)';
    listT1F=list_files(fullfile(analysis_path,t1_nii_dir),'s*nii',1)';
    inputs{1} = listEpisF(1); % Coregister: Estimate: Reference Image - cfg_files
    inputs{2} = listT1F(1); % Coregister: Estimate: Source Image - cfg_files
    dispi('We coregister ',inputs{2}, ' to ', inputs{1});
    spm_jobman('run', t1_preprocess_jobfile, inputs{:});
end


