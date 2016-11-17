function SmoothData = dataSmoothHD(Data,varargin)
% this function is used for high dimensional data smooth, more than two
% dimensional data set can be processed
% this function is generated because built-in function smooth can only
% handle one dimensional data set (one data trace)
isParallel = 0;
if nargin > 1
    if ~isempty(isParallel)
        isParallel = varargin{1};
    end
end

dataDim = ndims(Data);
if dataDim == 2
    if length(Data) == numel(Data)
        fprintf('Input data is a vector data, using the built in smooth function.\n');
        SmoothData = smooth(Data,5);
    else
        nSdim = varargin{2};
        if ~nSdim || ~isnumeric(nSdim)
            error('Input nSdim must be a positive integer.\n');
        end
        
        SmoothData = zeros(size(Data));
        if nSdim == 2
            SmoothSize = size(Data,1);
            if  isParallel
                parfor nSsize = 1 : SmoothSize
                    SmoothData(nSsize,:) = smooth(Data(nSsize,:),5);
                end
            else
                for nSsize = 1 : SmoothSize
                    SmoothData(nSsize,:) = smooth(Data(nSsize,:),5);
                end
            end
        else
            SmoothSize = size(Data,2);
            if  isParallel
                parfor nSsize = 1 : SmoothSize
                    SmoothData(:,nSsize) = smooth(Data(:,nSsize),5);
                end
            else
                for nSsize = 1 : SmoothSize
                    SmoothData(:,nSsize) = smooth(Data(:,nSsize),5);
                end
            end
        end
    end
elseif dataDim == 3
    nSdim = varargin{2};
    if ~nSdim || ~isnumeric(nSdim)
        error('Input nSdim must be a positive integer.\n');
    end
    DimS = size(Data,nSdim);
    SmoothData = zeros(size(Data));
    switch DimS
        case 1 
            for nSdim = 1 : DimS
                D2Data = squeeze(Data(nSdim,:,:));
                RemainSize = size(D2Data,1);
                RemainSmooth = zeros(size(D2Data));
                if  isParallel
                    parfor nmnm = 1 : RemainSize
                        RemainSmooth(nmnm,:) = smooth(D2Data(nmnm,:),5);
                    end
                else
                    for nmnm = 1 : RemainSize
                        RemainSmooth(nmnm,:) = smooth(D2Data(nmnm,:),5);
                    end
                end
                SmoothData(nSdim,:,:) = RemainSmooth;
            end
        case 2
            for nSdim = 1 : DimS
                D2Data = squeeze(Data(:,nSdim,:));
                RemainSize = size(D2Data,1);
                RemainSmooth = zeros(size(D2Data));
                if  isParallel
                    parfor nmnm = 1 : RemainSize
                        RemainSmooth(nmnm,:) = smooth(D2Data(nmnm,:),5);
                    end
                else
                    for nmnm = 1 : RemainSize
                        RemainSmooth(nmnm,:) = smooth(D2Data(nmnm,:),5);
                    end
                end
                SmoothData(:,nSdim,:) = RemainSmooth;
            end
        case 3
            for nSdim = 1 : DimS
                D2Data = squeeze(Data(:,:,nSdim));
                RemainSize = size(D2Data,1);
                RemainSmooth = zeros(size(D2Data));
                if  isParallel
                    parfor nmnm = 1 : RemainSize
                        RemainSmooth(nmnm,:) = smooth(D2Data(nmnm,:),5);
                    end
                else
                    for nmnm = 1 : RemainSize
                        RemainSmooth(nmnm,:) = smooth(D2Data(nmnm,:),5);
                    end
                end
                SmoothData(:,:,nSdim) = RemainSmooth;
            end
        otherwise
            error('Error smooth dim input, please check your input data.');
    end
else
    fprintf('Function can only handle no more than 3 dimensional data set, please check your data input.\n');
    SmoothData = Data;
    return;
end