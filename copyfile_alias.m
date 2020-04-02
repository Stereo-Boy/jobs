function copyfile_alias(current_dir,src,expr,dest)
    check_folder(fullfile(dest,current_dir), 0, 'verboseON');
    copy_files(fullfile(src,current_dir),expr,fullfile(dest,current_dir)) ;
end