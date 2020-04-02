    x=list_files('/Users/adrien_chopin/Desktop/spm_pipeline/MV40/spm_stam_thread/03_epis_nifti/','r*.nii',1);
    V=spm_vol(x);
    [Y] = spm_read_vols(V{1});
    V2=spm_vol('/Users/adrien_chopin/Desktop/spm_pipeline/MV40/retinotopic_rois/ROIs/rROI_RV1.nii');
    [Y2] = spm_read_vols(V2);
    masked=Y.*Y2;
    abs_path_gray=fileparts(x{1}); 
    V3=V2;
    V3.fname=fullfile(abs_path_gray,'test.nii');
    sum(Y2(:))
    spm_write_vol(V3,masked);