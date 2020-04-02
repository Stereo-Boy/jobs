function join_ROI_mask_hemi(ROI_dir,ROI_expr,left_code,right_code, code_pos,renaming_code)
% This function will join together two ROI nifti masks from left and right hemispheres.
% ROIs should be all located in ROI_dir (absolute path recommended).
% The program will select all ROIs through ROI_expr (default: *.nii).
% Then it will find corresponding ROIs using left_code and right_code at position code_pos in the file name. Left
% and right hemispheres ROIs should have identical names, except for the left and right codes.
% After merging the ROIS mask, a new file is created without left/right
% codes but starting with renaming code
% If no corresponding area is found, the ROI is simply renamed with the
% renaming code (and it will keep the lef/right code).
%
% ex: join_ROI_mask_hemi('/Users/adrien_chopin/Desktop/spm_pipeline/MV40/retinotopic_rois/ROIs','rROI_*.nii','L','R', 6,'m')
%

if numel(left_code)~=numel(right_code)
   error('This code works only for left and right codes of identical size...sorry') 
end
files=list_files(ROI_dir,ROI_expr);
code_idx=code_pos:(code_pos+numel(right_code)-1);

remaining_ROI_idx=1:numel(files);
for i=remaining_ROI_idx
    remaining_ROI_idx;
   file=files{i}; %select one file
   if strcmp(file(code_idx),left_code)==0 && strcmp(file(code_idx),right_code)==0
       dispi('ROI ',file,' does not have a left or right code...');  error('See message above')
   end
   file_filtered=file; file_filtered(code_idx)=[]; %filter out the left/right code
   
   k=1;
   while k<=numel(remaining_ROI_idx) % find corresponding file, if any
      j=remaining_ROI_idx(k);
      if j~=i && isnan(j)==0
          file2 = files{j};
          if strcmp(file2(code_idx),left_code)==0 && strcmp(file2(code_idx),right_code)==0
            dispi('ROI ',file2,' does not have a left or right code...');  error('See message above')
          end
      
          file2_filtered=file2; file2_filtered(code_idx)=[];
        if strcmp(file_filtered,file2_filtered)
           new_name=[renaming_code,file_filtered];
           dispi('Merging ',file,' / ',file2,' into ', new_name)
           
           %reading files data and headers
           V1=spm_vol(fullfile(ROI_dir,file));
           V2=spm_vol(fullfile(ROI_dir,file2));
           Y1 = spm_read_vols(V1);
           Y2 = spm_read_vols(V2);
    
           %writing file
           V3=V2;
           V3.fname=fullfile(ROI_dir,new_name);
           spm_write_vol(V3,logical(Y1+Y2));
           
           %removing the two ROIs from the pool and stopping the loop
           remaining_ROI_idx([i,j])=nan;
           k=numel(remaining_ROI_idx)+1;
        end
      end
      k=k+1;
   end
end

remaining_ROI_idx(isnan(remaining_ROI_idx))=[];
for i=remaining_ROI_idx
    file=files{i};
    new_name=[renaming_code,file];
    dispi('Renaming unpaired ROI :',file,' into ',new_name)
    copyfile(fullfile(ROI_dir,file),fullfile(ROI_dir,new_name))
%     %reading files data and headers
%     V1=spm_vol(fullfile(ROI_dir,file));
%     Y1 = spm_read_vols(V1);
%     
%     %writing file
%     V3=V1;
%     V3.fname=fullfile(ROI_dir,new_name);
%     spm_write_vol(V3,Y1.);
end