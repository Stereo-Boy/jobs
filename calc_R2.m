function [R2,quantiles]=calc_R2(SPM_file,SST_nii, Res_nii, output_dir,plotOrNot,maskfile)
%calculate the R2 from the ratio between residuals and total variance
% SPM_file is the location of the SPM.mat or equivalent, with the design for spm
% var_nii: file containing the SST of data
% Res_nii: file containing the variance of residuals
% plotOrNot: plot (1) or not (0)
% It also extract 25% 50% 75% and 95% quantiles for the distrubtiion of R2.
% maskfile allows to restrict the analysis to only the 1 voxels in
% maskfile
    
load(SPM_file)
dl=SPM.xX.trRV; %extract dl

% get the SST (total sum of squares)
V1 = spm_vol(SST_nii); % read header of a nii file
SST = spm_read_vols(V1); % use the header of the nii file (and potentially a mask) to read the data and gives it in Y.
if exist('maskfile','var')==0; mask = ones(size(SST));else
     V=spm_vol(maskfile);
     [mask,~] = spm_read_vols(V);
end

% get the Residuals sum of squres
V2 = spm_vol(Res_nii); % read header of a nii file
Res = spm_read_vols(V2); % use the header of the nii file (and potentially a mask) to read the data and gives it in Y.
if exist('output_dir','var')==0;    output_dir=fileparts(V2.fname); end

% calculate the R2 from residuals and SST and print it in a nii file
V=V2;
V.fname=fullfile(output_dir,'R2.nii');
R2=(1-((Res.*dl)./SST)).*mask;
spm_write_vol(V,R2);

% plot descriptive stats 
if plotOrNot
    figure()
    subplot(1,2,1);hist(R2(R2(:)>0));
    subplot(1,2,2);boxplot(R2(R2(:)>0));
end
quantiles = quantile(R2(:),[0.25,0.5,0.75,0.95]);