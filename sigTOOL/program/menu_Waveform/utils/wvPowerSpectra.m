function varargout= wvPowerSpectra(fhandle, varargin)
% wvPowerSpectra: spectral estimates via Welch periodogram
%
% wvPowerSpectra is a gateway function for the power spectral function that 
% may be called from the command line or from menu_ functions
%
% Exampe:
% result=wvPowerSpectra(fhandle, field1, value1, field2, value2....)
%     
% returns a sigTOOLResultData object. If no output is requested the result
% will be plotted.
%
% Valid field/value pairs are:
%     'channellist'           the numbers for the channels to analyze
%                                   (scalar or vector list)
%     'start'                 the start time for data processing
%                                (scalar, in seconds)
%     'stop'                  the stop time for data processing
%                                (scalar, in seconds)'
%     'windowtype'            the window to apply to the data
%                                 (string: e.g. 'hamming')
%     'windowlength'          the length of the window and also of the data
%                               sections in seconds (scalar)
%     'overlap'               the overlap to be used between data sections
%                               as a percentage (scalar)
%     'overlapmode'           determines whether overalpping will be
%                               applied.OverlapMode may be set to 'on',
%                               'off' or 'auto':
%                           'auto': This is the default. Continuous waveform
%                                   data will be processed in overlapping
%                                   sections. Episodic and frame-based data will
%                                   not be overlapped.
%                           'off':  No overlapping will be performed 
%                                   regardless of the setting for Overlap.
%                           'on':   the overlap will be applied to all
%                                   channels including episodic and 
%                                   frame-based samples. It will rarely
%                                   make sense to do this.
%     'detrend'                Logical flag. If true, the linear trend will
%                              each data section be removed from each data
%                              section before taking its FFT
%     'spectrummode'           The type of spectrum to return as a string:
%                                   'normalized power spectral density'
%                                   'power spectral density'
%                                   'linear power spectral density'
%                                   'power spectrum'
%                                   'linear power spectrum'        
%     'spectrogramflag'       Not really a flag but a string. If set to
%                               'contour' or 'surface' the spectrum will be
%                               returned for each data section and plotted
%                               in 3D as a contour or surface. Otherwise,
%                               data will be averaged to produce a 2D
%                               result.
%     'decimation'          decimation factor (zero by default). If non-zero,
%                           the data to be analyzed will be anti-alias
%                           filtered and downsampled by the factor in
%                           decimate. This can be useful with oversampled 
%                           data when drawing 3D plots as graphics rendering
%                           may otherwise to too slow         
%
% Toolboxes Required: For decimation only, dfilt objects must be available
% e.g. via SP Toolbox
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
% -------------------------------------------------------------------------


[fhandle, channels]=scParam(fhandle);

SpectrumMode='power spectral density';
OverlapMode='auto'; %#ok<NASGU>
SpectrogramFlag='off';

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'channellist'
            ChannelList=varargin{i+1};
        case 'start'
            Start=varargin{i+1}; %#ok<NASGU>
        case 'stop'
            Stop=varargin{i+1}; %#ok<NASGU>
        case 'windowtype'
            WindowType=varargin{i+1}; %#ok<NASGU>
        case 'windowlength'
            WindowLength=varargin{i+1}; %#ok<NASGU>
        case 'overlap'
            Overlap=varargin{i+1}; %#ok<NASGU>
        case 'overlapmode'
            OverlapMode=varargin{i+1}; %#ok<NASGU>
        case 'detrend'
            DetrendFlag=varargin{i+1}; %#ok<NASGU>
        case 'spectrummode'
            SpectrumMode=varargin{i+1};
        case 'spectrogramflag'
            SpectrogramFlag=varargin{i+1};
        case 'decimation'
            Decimation=varargin{i+1}; %#ok<NASGU>
        otherwise
            error('%s unknown parameter (%s)', mfilename, varargin{i});
    end
end


% Get the two-sided Welch PSD 
P=wvWelchSpectra(fhandle, varargin{:});
P=wvOnesided(P);


for idx1=1:length(ChannelList)
    
    thischan=ChannelList(idx1);
    
    switch SpectrumMode
        case {'psd x hz'}
            str=['Power (' channels{thischan}.hdr.adc.Units '^2_{rms})'];
            P{idx1,idx1}.rdata=P{idx1,idx1}.rdata*P{idx1,idx1}.details.Fs/P{idx1,idx1}.details.nfft;
        case {'power spectral density'}
            str=['Power Density (' channels{thischan}.hdr.adc.Units '^2_{rms} Hz^{-1})'];
        case {'linear power spectral density'}
            str=['Linear Power Density (' channels{thischan}.hdr.adc.Units '_{rms}/\surdHz)'];
            P{idx1,idx1}.rdata=sqrt(P{idx1,idx1}.rdata);
        case {'power spectrum'}
            str=['Power (' channels{thischan}.hdr.adc.Units '^2_{rms})'];
            P{idx1,idx1}.rdata=P{idx1,idx1}.rdata*P{idx1,idx1}.details.enbw;
        case {'linear power spectrum'}
            str=['Linear Power (' channels{thischan}.hdr.adc.Units '_{rms})'];
            P{idx1,idx1}.rdata=sqrt(P{idx1,idx1}.rdata*P{idx1,idx1}.details.enbw);
        otherwise
            error('Unrecognized SpectrumMode: %s', SpectrumMode);
    end
    
    switch SpectrogramFlag
        case {'contour' 'surface' 'image'}
            P{idx1,idx1}.tlabel='Frequency (Hz)';
            P{idx1,idx1}.olabel='Time (s)';
            P{idx1,idx1}.rlabel=str;
        otherwise
            P{idx1,idx1}.tlabel='Frequency (Hz)';
            P{idx1,idx1}.rlabel=str;
    end
    
end

Q=scPrepareResult(P, ChannelList, channels);

switch SpectrumMode
    case {'psd x hz'}
        out.title='Power Spectral Density x Hz';
    case {'power spectral density'}
        out.title='Power Spectral Density';
    case {'linear power spectral density'}
        out.title='Linear Power Spectral Density';
    case {'power spectrum'}
        out.title='Power Spectrum';
    case {'linear power spectrum'}
        out.title='Linear Power Spectrum';
end
out.datasource=fhandle;
out.data=Q;

switch SpectrogramFlag
    case 'surface'
        out.plotstyle={@scSurf};
        out.displaymode='Surface';
        out.viewstyle='3D';
    case 'image'
        out.plotstyle={@scImagesc};
        out.displaymode='Image';
        out.viewstyle='3D';
    case 'contour'
        out.plotstyle={@scContour};
        out.displaymode='Contour';
        out.viewstyle='3D';
    otherwise
        out.plotstyle={@scBar};
        out.displaymode='Bars';
        out.viewstyle='2D';
end

out=sigTOOLResultData(out);

if nargout==0
    plot(out);
else
    varargout{1}=out;
end
end

