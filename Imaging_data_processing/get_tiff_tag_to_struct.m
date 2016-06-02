function tagStruct = get_tiff_tag_to_struct(imdatafile)

tifdataobj = Tiff(imdatafile, 'r');
% Use only the following tags. If need more, add manually.
tagnames = {'ImageWidth','ImageLength', 'BitsPerSample',...
    'Compression','Photometric','ImageDescription',...
    'SamplesPerPixel','RowsPerStrip','MaxSampleValue',...
    'XResolution','YResolution','PlanarConfiguration','ResolutionUnit',...
    'YCbCrSubSampling','SampleFormat'};

iminfo = imfinfo(imdatafile);

% Put tags to a structure
tagStruct = [];
for k = 1:length(iminfo)
    tifdataobj.setDirectory(k);
    % Read tag info
    for i = 1:length(tagnames),
        tagname = tagnames{i};
        try
            tagvalue = tifdataobj.getTag(tagname);
        catch
            tagvalue = NaN;
        end
        %     fprintf('%s:\t%d\n', tagname, tagvalue);
        tagStruct(k).(tagname) = tagvalue;
    end
end