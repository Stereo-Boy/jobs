function variance = calc_var(series_nii,output_dir)
%this function calculate the variance for a series of run
%(proportional to SST)
%alternately, it could also find outliers
%series_nii is a cell list of nii files

n = numel(series_nii); %nb of timepoints
V = spm_vol(series_nii{1}); 
imgs=nan([V.dim,n]);

for i=1:n
    V = spm_vol(series_nii{i}); % read header of a nii file
    Y = spm_read_vols(V); % use the header of the nii file (and potentially a mask) to read the data and gives it in Y.
    imgs(:,:,:,i)=Y;
end

variance=nanvar(imgs,0,4);
if exist('output_dir','var')==0
    output_dir=fileparts(V.fname);
end
V.fname=fullfile(output_dir,'var.nii');
spm_write_vol(V,variance);