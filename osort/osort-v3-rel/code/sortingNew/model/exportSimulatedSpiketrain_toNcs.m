
% export simulated recording to Ncs
%
%

%% load the data
pathToWriteTo = 'c:\ueli\simulations\CSCsim2\';
pathIn = 'c:\ueli\simulations\';

fnameOrig = 'simulatedTetrode_sim2_Ch';

%load([pathIn fnameOrig ] );

FsOrig = 25000;
Fsout = 32556;

%adjust the sampling rate
%y = resample(data, 13, 10)

%%
nChannels = 4;
noiseLevel = 2; %which noise Level to export

%for noiseLevel=1:4
offset=0;
for k=1:4 %channels
    load([pathIn fnameOrig num2str(k) '.mat'] );
    
    for noiseLevel=1:4
        disp(['exporting ' num2str(noiseLevel) ' channel ' num2str(k)]);
        
        pathOut2=[pathToWriteTo '/level' num2str(noiseLevel) '/'];
        mkdir(pathOut2);
        
        fname = [ pathOut2 'CSC' num2str(k) '.ncs' ];
        
        data = spiketrains_tetrode_chs{noiseLevel}( : );
        
        %dataResampled = resample(data,13,10);   %  25000/32556  ~= 13/10
        
        [dataResampled,t,fact] = resample_ASRC( data, FsOrig, Fsout ); %resample accuratly to get exactly 32556 !
        
        clear data
        
        %*1000 because neuralynx format is in AD counts and integers only and
        %simulated date is -1...1
        exportToCSCData(fname, Fsout, dataResampled*1000, offset, k, fnameOrig);     
        disp(['writing ' fname]);
        clear dataResampled
    end
            clear spiketrains_tetrode_chs

end