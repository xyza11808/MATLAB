function folderFigureExtraction(FpathName,FnamePattern,FfileType,varargin)
% this function is used to using given input condition to find files that
% match input constrains and retrun the filename handles
if ~isdir(FpathName)
    error('The first input should be a valid folder name.');
end

fileName = [FnamePattern,FfileType];
fFiles = dir(fileName);
nF = length(fFiles);

fFileFreq = zeros(1,nF);
for nnf = 1 : nF
    cfname = fFiles(nnf).name;
    cfFreq = str2double(regexp(cfname,'\d*\d','match'));
    fFileFreq(nnf) = cfFreq;
end
fprintf('Following frequencies files exit within current files:\n');
disp(fFileFreq);
fprintf('\n');

pptfilename = '';
if nargin > 3
    if ~isempty(varargin{1})
        pptfilename = varargin{1};
    end
end
if isempty(pptfilename)
    fprintf('No ppt file is given, using default export name.\n');
    pptfilename = [datestr(now,'yyyymmddHHMMSS'),'.pptx'];
else
    pptfilename = [pptfilename,'.pptx'];
end

SlidesTitleStr = '';
if nargin > 4
    if ~isempty(varargin{2})
        SlidesTitleStr = varargin{2};
    end
end

pptSavePath =  pwd;
if nargin > 5
    if ~isempty(varargin{3})
        pptSavePath = varargin{3};
    end
end

pptFileFullPath = fullfile(pptSavePath,pptfilename);
if ~exist(pptFileFullPath,'file')
    NewFileExport = 1;
else
    NewFileExport = 0;
end

switch FfileType
    case '.fig'
      if NewFileExport
          exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Test export of frequency response data');
%           exportToPPTX('addslide');
      else
          exportToPPTX('open',pptFileFullPath);
%           exportToPPTX('addslide');
      end
      
        for nfs = 1 : nF
            cfName = fFiles(nnf).name;
            h_f = openfig(cfName);
            SliceAdd = mod(nfs,2);
            if SliceAdd
                exportToPPTX('addslide');
                if ~isempty(SlidesTitleStr)
                    exportToPPTX('addtext',SlidesTitleStr,'Position',[5 0 6 2],'FontSize',24);
                end
                exportToPPTX('addnote',pwd);
            end
            if SliceAdd
                exportToPPTX('addpicture',h_f,'Position',[0 2 8 6]);
            else
                exportToPPTX('addpicture',h_f,'Position',[8 2 8 6]);
            end
        end
    case '.png'
        if NewFileExport
              exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Test export of frequency response data');
    %           exportToPPTX('addslide');
        else
              exportToPPTX('open',pptFileFullPath);
    %           exportToPPTX('addslide');
        end
        
        for nfs = 1 : nF
            cfName = fFiles(nfs).name;
            h_f = imread(cfName);  % png file as input data
            SliceAdd = mod(nfs,2);
            if SliceAdd
                exportToPPTX('addslide');
                if ~isempty(SlidesTitleStr)
                    exportToPPTX('addtext',SlidesTitleStr,'Position',[5 0 6 2],'FontSize',24);
                end
                exportToPPTX('addnote',pwd);
            end
            if SliceAdd
                exportToPPTX('addpicture',h_f,'Position',[0 2 8 6]);
            else
                exportToPPTX('addpicture',h_f,'Position',[8 2 8 6]);
            end
        end
    otherwise
        fprintf('Undefined file type, quit file loading into ppt file.\n');
end
if NewFileExport  % 
    saveFname = exportToPPTX('saveandclose',pptFileFullPath);
else
    saveFname = exportToPPTX('saveandclose');
end
fprintf('Current figures saved in file:\n%s\n',saveFname);
