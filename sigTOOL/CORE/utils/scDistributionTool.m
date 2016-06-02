function scDistributionTool(hObject, EventData, distribution) %#ok<INUSL>
% scDistributionTool menu callback for distribution fitting
% 
% Example:
% scDistributionTool(hObject, EventData, distribution) 
% 
% fits the distribution to the data in the parent axes
%
% distribution is a string suitable for input to the mle function in the
% MATLAB Statistics Toolbox
%
% Distributions will be modeled using the MATLAB Stats Toolbox pdf
% function and the parameters returned by mle. Equality of data and model
% is compared using a Kolmogorov-Smirnov two sample test.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%
% Revisions:
% 09.08.08 Bug fix: histarea wrongly calculated with selected data
%          Tidy KS test and formatting
%          Force integer bin edges for Poisson dist

fhandle=ancestor(hObject, 'figure');
subs=getappdata(gca, 'AxesSubscript');
result=getappdata(fhandle, 'sigTOOLResultData');
data=result.data{subs(1), subs(2)};

if iscell(distribution)
    distribution=distribution{1};
end

desc=sprintf('%s', distribution);
desc(1)=desc(1)-32;

if strcmp(get(get(hObject, 'Parent'),'UserData'),'Selected Data')
    SelectMode=true;
else
    SelectMode=false;
end

try
    % Get parameters using mle
    switch SelectMode
        case false
            X=data.tdata;
            Y=data.rdata;
            [a b]=mle(X, 'distribution', distribution,...
                'frequency', Y);
            % Set scaling
        case true
            % xdata & ydata maybe from patch objects or hggroups - use original data
            % from sigTOOLResultData object
            h=findobj(gca, 'Tag', 'sigTOOL:SelectedData', 'Visible','on');
            if numel(h)>1
                msgbox('You can have only one trace visible for curve fitting', 'Curve Fitting');
                return
            end
            xdata=get(h,'xdata');
            result=getappdata(fhandle, 'sigTOOLResultData');
            idx=getappdata(gca, 'AxesSubscript');
            data=result.data{idx(1),idx(2)};
            minx=min(xdata);
            maxx=max(xdata);
            X=data.tdata(data.tdata>=minx & data.tdata<=maxx);
            % Restrict rdata to present line
            Y=data.rdata(get(h, 'UserData'),data.tdata>=minx & data.tdata<=maxx);
            [a b]=mle(X, 'distribution', distribution,...
                'frequency', Y);
    end
    binwidth=X(2)-X(1);
    histarea=sum(Y)*binwidth;% Fix 09.08.08
    % Get PDF...
    switch distribution
        case 'poisson'
            X2=floor(min(X)):ceil(max(X));
        otherwise
            X2=X+(0.5*binwidth);
    end
    switch length(a)
        case 1
            py=pdf(distribution, X2, a(1));
        case 2
            py=pdf(distribution, X2, a(1), a(2));
        case 3
            py=pdf(distribution, X2, a(1), a(2), a(3));
    end
    % ... and scale it
    py=py*histarea;
catch %#ok<CTCH>
    m=lasterror(); %#ok<LERR>
    idx=findstr(m.message,'>');
    if ~isempty(idx)
        m.message(1:idx(end))='';
    end
    errordlg(sprintf('Fitting %s distribution\n%s', desc, m.message), 'scDistributionTool');
    rethrow(m);
end

% Text output
str=sprintf('Maximium Likelihood Estimates:\n');
str=[str sprintf('Parameters for %s distribution\n', desc)];
Tol=1e4; %Force rounding
str=[str sprintf('%s\nConfidence Intervals\n%s\n', mat2str(round(Tol*a)/Tol), mat2str(round(Tol*b')/Tol))];
if numel(py)==numel(Y)
    % Kolmogorov-Smirnov test if equal number of bins only
    [H, p, KSStat]=LocalKSTest2(py, Y);
    if isnan(KSStat)
        % This can happen e.g. if py is all zeros (non-integer bins with
        % Poisson perhaps?)
        str=[str sprintf('Kolmogorov-Smirnov 2 sample test returns NaN for KS statistic')];
    elseif H==1
        str=[str sprintf('The fit is not satisfactory\nKolmogorov-Smirnov 2 sample test p=%f\n',p)];
    elseif H==-1
        str=[str sprintf('Too few data points for Kolmogorov-Smirnov 2 sample test')];
    else
        str=[str sprintf('Equality of the distributions can not be rejected\nKolmogorov-Smirnov 2 sample test p=%f\n',p)];
    end
end
% Add to plot
newax=scAddPlot(gca);
ylabel(newax, [desc ' Estimate']);
line(X2, py,'Parent', newax, 'Color', [0 0 0], 'LineWidth', 2);
annotation(fhandle,'textbox',[0.6,0.6,0.3,0.25],'String',str, 'Tag', 'sigTOOL:Annotation');
return
end


function [H, pValue, KSstatistic]=LocalKSTest2(x, y)
% LocalKSTest2: modified kstest2 from Stats Toolbox
% NULL hypothesis: distributions are the same
alpha=0.05;
x  =  x(~isnan(x));
y  =  y(~isnan(y));
sumCounts1  =  cumsum(x)./sum(x);
sumCounts2  =  cumsum(y)./sum(y);
sampleCDF1  =  sumCounts1(1:end-1);
sampleCDF2  =  sumCounts2(1:end-1);
deltaCDF  =  abs(sampleCDF1 - sampleCDF2);
KSstatistic   =  max(deltaCDF);
n1     =  length(x);
n2     =  length(y);
n      =  n1 * n2 /(n1 + n2);
if n<4
    H=-1;
    pValue=[];
    return
end
lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);
j       =  (1:101)';
pValue  =  2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
pValue  =  min(max(pValue, 0), 1);
H  =  (alpha >= pValue);
return
end