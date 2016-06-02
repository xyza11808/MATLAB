function [pbin tb]=eventcorr(trigger, spikes, binwidth, nsweeps, duration, pretime)
% EVENTCORR workhorse function for calculating spike correlations
%
% Example
% [pbin tb]=EVENTCORR(trigger, spiketimes, binwidth, duration, pretime)
%
% Inputs: trigger         the trigger times
%         spiketimes      the spike times
%         binwidth        binwidth for the histogram
%         nsweeps         the number of triggers per histogram, zero for a
%                         single histogram using all triggers
%         duration        sweep duration
%         pretime         the pretime period
%
% Outputs:
%         pbin            the histogram counts as number of spikes
%         tb              the timebase for the correlation
%
% EVENTCORR uses all triggers and spikes. The calling function should deal
% with end-effects where incomplete sweeps may be available.
%
% To calculate a post- or peri - stimulus time histogram, debounce the
% triggers before calling eventcorr. For spike-train cross-correlation,
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
% To produce a mex-file for the current platform, compile eventcorr.c using
% mex or sigTOOL('compile').
% -------------------------------------------------------------------------

persistent MFileFlag
if isempty(MFileFlag)
    MFileMessage();
end
MFileFlag=true;

% Floating point warnings: User can switch these off
if rem(binwidth,1)~=0 || rem(duration,1)~=0 || rem(pretime,1)~=0
    warning('sigtool:eventcorr:tolwarn',...
        'eventcorr m-file:\nTo avoid floating point rounding issues, binwidth duration and pretime should be whole numbers\nValues: [%20.10f %20.10f %20.10f]\n',...
        binwidth, duration, pretime);
end
if rem(pretime/binwidth,1)~=0
		warning('sigTOOL:eventcorr:pretime', 'eventcorr m-file:\nPretime is not an exact multiple of the binwidth\nValues: [%20.10f %20.10f]',...
            pretime, binwidth);
end

trigger=trigger-pretime;

if nsweeps==0
    % Use all triggers returning a single correlation. pbin will be a
    % vector
    pbin=zeros(1, floor(duration/binwidth));
    for k=1:length(trigger);
        temp=spikes-trigger(k);
        idx1=find(temp>=0, 1);
        idx2=find(temp<duration,1, 'last');
        idx=floor(temp(idx1:idx2)/binwidth)+1;
        for n=1:length(idx)
            % Need loop as idx may have repeated values
            % TODO: replace with accumarray
            pbin(idx(n))=pbin(idx(n))+1;
        end
    end
else
    % Use nsweeps triggers per correlation returning a matrix of results in
    % pbin
    len=floor(length(trigger)/nsweeps);
    pbin=zeros(len, floor(duration/binwidth));
    for j=1:nsweeps:length(trigger)-nsweeps
        for m=j:j+nsweeps-1
            temp=spikes-trigger(m);
            idx1=find(temp>=0, 1);
            idx2=find(temp<duration, 1, 'last');
            idx=floor(temp(idx1:idx2)/binwidth)+1;
            row=ceil(j/nsweeps);
            for n=1:length(idx)
                pbin(row, idx(n))=pbin(row, idx(n))+1;
            end
        end
    end
end

tb=-pretime:binwidth:duration-pretime-binwidth;
return
end


function MFileMessage()
% Message will print once per MATLAB session
beep();
fprintf('-------------------------------------------------------------------\n');
fprintf('| sigTOOL: eventcorr.m                                            |\n');
fprintf('-------------------------------------------------------------------\n');
fprintf('| The m-file for this function is running because no mex-file     |\n');
fprintf('| for this platform could be found or it could not be run.        |\n');
fprintf('| To increase speed, compile eventcorr.cpp - Type "help mex"      |\n');
fprintf('| for details. eventcorr.cpp is located in the:                   |\n');
fprintf('| ...sigTOOL\\sigTOOL Spike Train Toolkit\\utils\\SourceCode\\ folder. |\n');
fprintf('| Compile this using mex eventcorr.cpp and place eventcorr.%s |\n', mexext());
fprintf('| in the ...sigTOOL\\sigTOOL Spike Train Toolkit\\utils folder.      |\n');
fprintf('| sigTOOL will do this for you: run sigTOOL(''compile''); at the      |\n');
fprintf('| MATLAB  command line.                                            |\n');
fprintf('|-------------------------------------------------------------------\n');
return
end
