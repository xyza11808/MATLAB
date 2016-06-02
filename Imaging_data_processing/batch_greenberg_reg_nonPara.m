function batch_greenberg_reg_nonPara(imFileNames, out_path)
% Run greenberg image registration on a batch of image files.
% The input image files shold be already registered on the whole frame
% level, i.e., dft crosscorrelation registration
% This is a non parallel version, that run through the files in series,
% instead of using parfor command.

for i=1:length(imFileNames)
    % if isdir(datafiles(i).name)
      %  continue;
    % end
%     filename = [dft_dir filesep imFileNames];
    filename = imFileNames{i};
    info = imfinfo(filename);
    if isfield(info(1), 'ImageDescription')
        im_descr = info(1).ImageDescription;
    else
        im_descr = '';
    end
    [pthstr,file_main_name,ext] = fileparts(filename);
    
    im_s = imread_multi(filename,'g');

    im_t = mean(im_s(:,:,89:end),3); %mean(im_s,3); % im_s(:,:,1); % 
    disp(['Start ''greenberg_reg'' for file ' file_main_name ' ......................']);
    [im_c dx_r dy_r E] = imreg_greenberg(im_s, im_t, []);
    
    
    out_name = [file_main_name(1:end-3) 'greenberg_' file_main_name(end-2:end)];
    dest = [out_path filesep out_name];
    
    imwrite(uint16(im_c(:,:,1)), [dest '.tif'], 'tif', 'Compression', 'none', 'Description',im_descr, 'WriteMode', 'overwrite');
    for f=2:size(im_c,3)
        imwrite(uint16(im_c(:,:,f)), [dest '.tif'], 'tif', 'Compression', 'none', 'WriteMode', 'append');
    end
%     if ~isempty(dft_shift_all)
%         dft_shift = dft_shift_all(:,:,i); % [];%
%     else 
%         dft_shift = [];
%     end
    save([dest '_reginfo'], 'dx_r', 'dy_r' ,'E');
    fprintf('Reg data saved to %s\n',out_name);
end

