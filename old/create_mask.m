function create_mask(image, threshold_down, threshold_up, output_name)
% obsolete because imcalc deso not fail 

%
%given the imcalc batch often fails, this is a backup to create binary nii mask
%from nii images

%the function will put 0 in all voxels that do not have a value between
%threshold_down and threshold_up

V = spm_vol(image); % read header of a nii file

[Y,XYZ] = spm_read_vols(V); % use the header of the nii file to read the data and gives it in Y.

mask = ((Y>threshold_down) & (Y<threshold_up));

V.fname=output_name;
V.descrip = 'spm_mask';
spm_write_vol(V,mask);

