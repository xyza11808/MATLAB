function  obj=jpeth(trig, sp1, sp2, BinWidth, Duration, pt, tscale)
% JPETH constructor for jpeth class
%
% Example:
% obj=jpeth(trig, sp1, sp2, BinWidth, Duration, pt, tscale)
% returns the jpeth object. Inputs:
%       trig:       the trigger times
%       sp1:        spike times on channel 1
%       sp2:        spike times on channel 2
%       BinWidth:   the binwidth for the histigrams
%       Duration:   the duration over which to calculate the result
%                   relative to the trigger the average (inclusive of the
%                   pre-time)
%       pt:         the pre-time length
%       tscale:     all the above arguments are arbitrarily scaled
%                   (typically in clock ticks). tscale provides the scaling
%                   factor to convert times to seconds. 
%
% The returned jpeth object has the following properties
%      data:    contains intermediate results used in calculating the jpeth
%                   object
%      display: user-settable function handle of the function used to
%                   display the matrix. This is set to @imagesc by default.
%                   Use setDisplay to alter the value.
%      filter:  a user-settable filter that will be used to filter the
%                   result matrix when the getMatrix method is called
%      handle:  the handle of the figure or uipanel used for the latest
%                   call to plot on the jpeth object (set to [] if not
%                   yet plotted)
%      label:   a user-settable string (empty ny default).
%      mode:    the mode for calculating the jpeth matrix (see below
%                       for details)
%      nsweeps: the total number of sweeps (triggers)
%      peth1:   the peri-event time histogram for spike-train 1 relative
%                       to the trigger
%      peth2:   the peri-event time histogram for spike-train 2 relative
%                       the trigger
%      raw:     the raw jpeth matrix scaled according to the number of
%                       triggers. Note this will be stored as a sparse
%                       double matrix in the object. getXXXX methods will
%                       return full matrices.
%      sqpeth1: the sum of squares of the counts in each sweep of the
%                    peri-event time histogram for spike-train 1
%      sqpeth2: the sum of squares of the counts in each sweep of the
%                   peri-event time histogram for spike-train 2
%      tbase:   the time base for the matrices and histograms
%      tscale:  all times for the propeties above are arbitrarily scaled
%                   (typically in clock ticks). The tscale property 
%                   provides the scaling factor to convert times to seconds. 
% 
% To view the object call plot(obj).
%
% -------------------------------------------------------------------------
% Note
% With the exception of mode, display, filter and label these properties
% should not be altered by the user.
% -------------------------------------------------------------------------
%
% User-settable properties:
% These may be modified by calls to setMode, setDisplay, setFilter and
% setLabel e.g.
%           obj=setMode(obj, 'surprise');
%
% -------------------------------------------------------------------------
% Note:
% If no output arguments are specified with these methods, the relevant
% property of the jpeth object in the calling workspace will be updated
% with the value of ph where this is possible (i.e. where the object is a
% named variable in the calling workspace resolvable by a call to
% inputname(...)).
% -------------------------------------------------------------------------
%
% Mode
% mode is set by calling the setMode method on the object. Valid standard
% modes are:
%   'average'       the raw jpeth matrix scaled by the number of triggers
%                   will be used 
%   'corrected'     the raw matrix will be scaled by subtracting the
%                   cross product of peth1 and peth2
%   'normalized'    the corrected matrix will be scaled by product of the
%                   standard deviations of the peths. Normalized values are
%                   therefore correlation coefficients with a range of
%                   -1 to 1.
%   'raw'           returns the spike counts without scaling
%   'errors'        returns the binomial errors i.e. the counts above 1
%                   when more than one spike falls within a bin in a given 
%                   sweep
%   'surprise'      returns Palm's surprise (Palm et al., 1988)
%
% To return the jpeth matrix for each mode call setMode followed by
% getMatrix e.g.
%           obj=jpeth(.....);                   % construct object
%           obj=setMode(obj, 'normalized');     % normalized mode
%           matrix=getMatrix(obj);              % get the answer
% -------------------------------------------------------------------------
% NOTE:
% Custom modes may be added by the user. To add a mode 'abcdefg' simply
% define a new method "getAbcdefg" (note capital "A") and place it in the
% @jpeth class folder. getMatrix will automatically detect the new method.
%--------------------------------------------------------------------------
%
% Display
% This contains a function handle to a function to plot the coincidence
% matrix. Valid settings are @imagesc (default), @contour and @surf.
% 
% Filter
% Contains the coefficients of a matrix used to filter the coincidence
% matrix within the getMatrix method. Typically a nXn matrix where n is
% odd.
%
% Label
% A user settable string.
%
% References:
% Palm et al. (1988) On the significance of correlations among neural spike
% trains Biological Cybernetics 59, 1-11. 
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% Number of sweeps
obj.nsweeps=length(trig);

% Form rasters
[a1 b1]=rasterprep(trig, sp1, Duration, pt);
[a2 b2]=rasterprep(trig, sp2, Duration, pt);

% Trim result: spikes at t==(Duration-pt) will be included by rasterprep
% but other spikes in the last bin will not be (N.B. use < in case of IEEE 
% roundoff errors)
b1=b1(a1<Duration-pt);
a1=a1(a1<Duration-pt);
b2=b2(a2<Duration-pt);
a2=a2(a2<Duration-pt);


% Set the timebase
obj.tbase=-pt:BinWidth:Duration-pt-BinWidth;
if nargin>=7
    % Factor to scale times to seconds
    obj.tscale=tscale;
else
    obj.tscale=[];
end

% Assign spikes to bins - offset by pretime to ensure positive indices
x1=floor((a1+pt)/BinWidth)+1;
x2=floor((a2+pt)/BinWidth)+1;
assignin('base','x2',[x2; a2; b2])

% Form peri-event time histograms
obj.peth1=accumarray(x1',1)';
obj.peth2=accumarray(x2',1)';
% Keep squares for calculating stats
obj.sqpeth1=sum(accumarray([b1'+1 x1'], 1).^2);
obj.sqpeth2=sum(accumarray([b2'+1 x2'], 1).^2);


% Raw JPETH
m1=sparse(x1, b1+1, 1);
m2=sparse(x2, b2+1, 1);
% May have sweeps at end containing no spikes  - if so, add zero columns
% explicitly
if size(m1,2)<obj.nsweeps
    m1=horzcat(m1, sparse(size(m1,1), obj.nsweeps-size(m1,2))); %#ok<AGROW>
end
if size(m2,2)<obj.nsweeps
    m2=horzcat(m2, sparse(size(m2,1), obj.nsweeps-size(m2,2))); %#ok<AGROW>
end

% Form raw JPETH matrix (sparse)
obj.raw=(m2*m1');

% Set the default mode...
obj.mode='raw';
obj.display=@imagesc;
obj.handle=[];

% ... and filter
obj.filter=[];

% Keep the matrices for use in user-methods
obj.data.matrix1=m1;
obj.data.matrix2=m2;

%Create an empty label for later use
obj.label='';

% Create object
obj=orderfields(obj);
obj=class(obj,'jpeth');

return
end

