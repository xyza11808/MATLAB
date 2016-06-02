%script. loads the requested simulation files into the current workspace.
%
%simNr and levelNr needs to be set before this is called.
%
%urut/april07.
%

if simNr<=3
    basepath='/svnwork/code/osort-v3-rel/data/';    % Change this to where simulation files are located
    
    load([basepath '/sim' num2str(simNr) '/simulation' num2str(simNr) '.mat']);
    %load([basepath '/sim' num2str(simNr) '/simulation' num2str(simNr) 'Params.mat']);        
else
    basepath='/data2/simulated/';
    switch(simNr)
        case 4
            load([basepath 'sim' num2str(simNr)  '/simulation' num2str(simNr) '_1000s_level_' num2str(levelNr) '.mat']);
        otherwise
            load([basepath 'sim' num2str(simNr)  '/simulation' num2str(simNr) '_100s_level_' num2str(levelNr) '.mat']);
    end
end
