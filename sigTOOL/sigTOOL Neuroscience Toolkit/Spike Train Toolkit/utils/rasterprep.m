function [x y v]=rasterprep(trigger, spikes, duration, pretime)
% RASTERPREP workhorse function for calculating spike correlations
%
% Example
% [pbin tb intervals]=RASTERPREP(trigger, spiketimes, duration, pretime)
%
% Inputs: trigger         the trigger times
%         spiketimes      the spike times
%         duration        sweep duration
%         pretime         the pretime period
%
% Outputs:
%         pbin            the histogram counts as number of spikes
%         tb              the timebase for the correlation
%         intervals       the interspike intervals for each spike:
%                               t(n)-t(n-1)
%  
% To calculate a post- or peri - stimulus time raster, debounce the
% triggers before calling rasterprep. For spike-train cross-correlation,
% do not debounce.
%
% See also debounce
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Note that this file may be shadowed by a mex-file and, in that case, will
% not execute. If no mex-file is present, a message will be be issued at
% the command line (once per MATLAB session), and this m-file will be
% executed. Note that the mex-file will run ~5000x faster.
% To produce a mex-file for the current platform, compile rasterprep.cpp
% using mex or sigTOOL('compile')
% -------------------------------------------------------------------------
%
% Revisions:
% 12.12.08  Help text corrected. Remove occasional trailing zero when intervals
%           returned and first spike fell in a sweep. rasterprep.cpp
%           updated accordingly. Unnecassary for loop removed from m-file

persistent MFileFlag
if isempty(MFileFlag)
    MFileMessage();
end
MFileFlag=true;

% Floating point warnings: User can switch these off
if rem(duration,1)~=0 || rem(pretime,1)~=0
    warning('sigtool:rasterprep:tolwarn',...
        'rasterprep m-file:\nTo avoid floating point rounding issues, duration and pretime should be whole numbers\nValues: [%20.10f %20.10f]\n',...
        duration, pretime);
end

trigger=trigger-pretime;

x=zeros(1, 2^20);
y=zeros(1, 2^20);
if nargout<3
    stindex=1;
else
    % Returning interspike intervals so ignore first spike
    stindex=2;
    v=zeros(1, 2^20);
end

count=1;
for k=1:length(trigger);
    
    temp=spikes(stindex:end)-trigger(k);
    % Find relevant indices for spikes
    idx1=find(temp>=0, 1);
    idx2=find(temp<duration,1, 'last');
    idx=idx1:idx2;
    % Correct out-by-one error [temp shorter than spike when returning
    % interspike interval]
    if stindex==2
        idx=idx+1;
    end
    
    % Increase size of output if needed in blocks of 2^20 elements
    if count+length(idx)>length(x)
        x=[x zeros(1, 2^20)]; %#ok<AGROW>
        y=[y zeros(1, 2^20)]; %#ok<AGROW>
        if nargout>2
            v=[v zeros(1, 2^20)]; %#ok<AGROW>
        end
    end
    % 12.12.08 Get rid of loop - not needed
    x(count:count+length(idx)-1)=spikes(idx)-trigger(k);
    y(count:count+length(idx)-1)=k;
    if nargout>2
        v(count:count+length(idx)-1)=spikes(idx)-spikes(idx-1);
    end

    count=count+length(idx);
end

x=x(1:count-1);
y=y(1:count-1);
if nargout>2
    v=v(1:count-1);
end

return
end


function MFileMessage()
beep();
fprintf('-------------------------------------------------------------------\n');
fprintf('| sigTOOL: raterprep.m                                            |\n');
fprintf('-------------------------------------------------------------------\n');
fprintf('| The m-file for this function is running because no mex-file     |\n');
fprintf('| for this platform could be found or it could not be run.        |\n');
fprintf('| To increase speed, compile eventcorr.cpp - Type "help mex"      |\n');
fprintf('| for details. rasterprep.cpp is located in the:                   |\n');
fprintf('| ...sigTOOL\\sigTOOL Spike Train Toolkit\\utils\\SourceCode\\ folder. |\n');
fprintf('| Compile this using mex rasterprep.cpp and place rasterprep.%s |\n', mexext());
fprintf('| in the ...sigTOOL\\sigTOOL Spike Train Toolkit\\utils folder.      |\n');
fprintf('| sigTOOL will do this for you: run sigTOOL(''compile''); at the      |\n');
fprintf('| MATLAB  command line.                                            |\n');
fprintf('|-------------------------------------------------------------------\n');
return
end
