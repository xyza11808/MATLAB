classdef NPspikeDataMining
    properties (SetAccess = private)
        
    
    
    end
    
    properties (SetAccess = public)
        ksFolder = '';
        RawDataFilename = ''
        NumChn = 385; % the last channel index is the trigger channel recording
        Numsamp = [];
        Datatype = 'int16'
        mmf
        SpikeStrc = struct()
        
        SpikeClus
        SpikeTimes % in seconds
        chnMaps
        
        ClusterInfoAll
        UsedClus_IDs % used cluster index
        ChannelUseds_id % used channel index
        UsedChnDepth
        ClusterUsedInds % indes indicating which cluster is to be used
    end
    
    
    methods
        function obj = NPspikeDataMining(FolderPath)
           binfileInfo = dir(fullfile(FolderPath,'*.ap.bin'));
           if isempty(binfileInfo)
               warning('Unable to find target bin file.');
               return;
           end
               
           obj.RawDataFilename = binfileInfo(1).name;
           obj.ksFolder = FolderPath;
           
           dataTypeNBytes = numel(typecast(cast(0, obj.Datatype), 'uint8')); % determine number of bytes per sample
           obj.Numsamp = binfileInfo(1).bytes/(dataTypeNBytes*obj.NumChn);
           fullpaths = fullfile(FolderPath, obj.RawDataFilename);
           obj.mmf = memmapfile(fullpaths, 'Format', {Datatypes, [obj.NumChn obj.Numsamp], 'x'});
           
           % spike data info reading
           obj.SpikeStrc = loadParamsPy(fullfile(FolderPath, 'params.py'));
           
           % read npy files
           obj.SpikeClus = readNPY('spike_clusters.npy');
           SpikeTimeSample = readNPY('spike_times.npy');
           obj.SpikeTimes = double(SpikeTimeSample)/obj.SpikeStrc.sample_rate;
           obj.chnMaps = readNPY('channel_map.npy');
           
           if exists(fullfile(FolderPath,'cluster_info.tsv'))
               % sorted data have been processed by phy
               % cluster include criteria: good, not noise, fr >=1
               cgsFile = fullfile(FolderPath,'cluster_info.tsv');
               [opt.UsedClus_IDs,opt.ChannelUseds_id,opt.UsedClusinds,...
                   opt.ClusterInfoAll] = ClusterGroups_Reads(cgsFile);
               
               ChannelDepth = cell2mat(opt.ClusterInfoAll(2:end,7));
               opt.UsedChnDepth = ChannelDepth(UsedIDs_inds);
               NumGoodClus = length(opt.UsedClus_IDs);
               fprintf('Totally %d number of good units were find.\n',NumGoodClus);
           else
               warning('Unbale to locate phy processed file.');
               return;
           end
           
               
        end
        
        function SpikeWaveFun(obj,varargin)
            SpecificClus = obj.UsedClus_IDs;
            if nargin > 1
                if ~isempty(varargin{1})
                    SpecificClus = varargin{1};
                end
            end
           NumExtractClus = length(SpecificClus);
           
            
        end
        
    end
    
end
