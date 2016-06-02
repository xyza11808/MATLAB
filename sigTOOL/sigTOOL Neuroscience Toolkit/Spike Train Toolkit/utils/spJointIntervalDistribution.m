function varargout=spJointIntervalDistribution(fhandle, varargin)
% spJointIntervalDistribution
%
% Plots the joint frequency distribution of the intervals between 
% successive events as a colored image.
%
% Example:
% spJointIntervalDistribution(fhandle, InputName1, InputValue1,....)
% spJointIntervalDistribution(fhandle, InputName1, InputValue1,....)
% or
% out=spJointIntervalDistribution(....)
%     
% where
%         fhandle is a valid sigTOOL data view handle
%         channels is a sigTOOL channel cell array
%         out (if requested) will be a sigTOOLResultData object
%     
% If no output is requested the result will be plotted
%
% Inputs are string/value pairs
%     'Sources'               Vector of source channels
%     'Start'                 Start time for processing (in seconds)
%     'Stop'                  End time for processing (in seconds)
%     'BinWidth'              The width of the bins in the result (in
%                               seconds)
%
% 
% A similar analysis can be presented as a scatter plot through the
% spPoincare function
%
% See also spPoincare
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 04/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

% Process arguments
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'sources'
            Sources=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'binwidth'
            BinWidth=varargin{i+1};
        otherwise
            error('Unrecognized parameter ''%s''', varargin{i});
    end
end

[fhandle, channels]=scParam(fhandle);
Start=Start/channels{Sources(1)}.tim.Units;
Stop=Stop/channels{Sources(1)}.tim.Units;

P=spPoincare(fhandle, varargin{:});

for i=2:size(P.data,2)

    x=P.data{i,i}.tdata;
    y=P.data{i,i}.rdata;

    idx1=floor(x/BinWidth)+1;
    idx2=floor(y/BinWidth)+1;

    mx=max(max(idx1),max(idx2));
    
    z=zeros(mx);
    for j=1:length(idx1)
        z(idx1(j),idx2(j))=z(idx1(j),idx2(j))+1;
    end

    
    P.data{i,i}.tdata=0:BinWidth:BinWidth*mx-1;
    P.data{i,i}.odata=0:BinWidth:BinWidth*mx-1;
    P.data{i,i}.rdata=sparse(z);
    
    P.data{i,i}.tlabel='Interval n (ms)';
    P.data{i,i}.olabel='Interval n+1 (ms)';
    P.data{i,i}.rlabel='Count';
end
P.plotstyle={@scImagesc};
P.displaymode='Image';
P.viewstyle='2D';
P.title='Joint Interval Distribution';

if nargout==0
    plot(P);
else
    varargout{1}=P;
end

return
end



