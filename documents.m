%%documentations
%to plot a two dimension matrix color map can use functions like surf and
%pcolor image and so on
%magesc
%imagesc
%
%function fir1 and fir2 can be used as lowband-pass filter or highbang-pass
%filter

% dunction xcorr can be used to calculate the aurocorrelation function for
% given spike train as well as two similar but phase-lagged signal
% correlations, details see the function documentation

% eval('string') can be used to make the valus of an variable to be the name
%of a new variable

%function flipud can be used to reverse the given array upside down, can be
%used to reverse colormap during plot as: colormap(flipud(hot))

%for cell components x, the expression x{:} can change the component of x
%into a string, these can be used for cell to string convert

% find the max or the min valus in a matrix more than two dimensions
% min(x(:))  or  max(x(:))
% if you want to return the min or max value of the given data, you can do like this
%     [amin, minind] = min(a(:));
%     [i, j, k] = ind2sub(size(a),minind);  %this is for the three dimension condition, or matybe just use single variable so that maybe return a vector

% %way to add a name on the top of the colorbar
% set(get(colorbar,'Title'),'string','\alphaf/f_0') %'_'here indicates to down label of the following charater (only the most closed single char)

% in axes properties, can use TickDir Property Name to control the short black line upon the x axes or below x axes (in/out);
% also, use TickLength Property Name to control the length of the short line, can note be an empty vector, if you want to hide these short lines, just set this property value as [0 0];

%function imfreehand can be used for ROI drawing (imroi class)
% h = imfreehand(gca) 
% then can use the function h_mask=h.createMask to return the roi mask with
% the same size of the original ROI drawning image

%
%using gpuArray to send CPU data to GPU memory e.g.: A2=gupArray(A1) 
%the calculation result also store in GPU memory: B2=fft(A2)  class(B2)  
% ans =
% parallel.gpu.GPUArray

%to bring data back to CPU, using gather()  e.g.: B2=gather(B2)  class(B2)
% ans =
% double

% A5 = parallel.gpu.GPUArray.rand(3000,3000);  construct data in the GPU
% directly

%arrayfun
%%# count number of values in each bin
% nj = accumarray(binIdx, 1, [nbins 1], @sum);

% assign data into bin form, but only with ordered form of input data, otherwise this function will be work as
% sort the data first and than using this function
%   e.g.:histc

%use the following two sentances to eliminate parpool warnings:
% myCluster = parcluster('local');
% delete(myCluster.Jobs)

% findobj function can be used to locate handles in current handles object and return its handle


% symbolic calculation and change the value into double: 
% syms x y z
% fx=f(x,y,z);  %function handle
% dfx=diff(fx,x);  %symbolic function Differentiation by variable x, dfx is also a symbolic variable
% x=doubleValue;
% XpointSlope=double(subs(dfx));  %function slope at point x


% %######################################################################################
% % multicolormap plot and multi colorbar plot
% 
% %% Create two axes
% ax1 = axes;
% [x,y,z] = peaks;
% surf(ax1,x,y,z)
% view(2)
% ax2 = axes;
% scatter(ax2,randn(1,120),randn(1,120),50,randn(1,120),'filled')
% %% Link them together
% linkaxes([ax1,ax2])
% %% Hide the top axes
% ax2.Visible = 'off';
% ax2.XTick = [];
% ax2.YTick = [];
% %% Give each one its own colormap
% colormap(ax1,'hot')
% colormap(ax2,'cool')
% %% Then add colorbars and get everything lined up
% set([ax1,ax2],'Position',[.17 .11 .685 .815]);
% cb1 = colorbar(ax1,'Position',[.05 .11 .0675 .815]);
% cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]);
% 
% %end of plot
% %#####################################################################################

% while using bootstrp function, there is no need to specify function output inside function input,
% all the outputs from function will be saved in bootstrp output automatically, no other modifications is needed.
    
%classification of a data set into different groups according to is value
%distribution
% using function tiedrank, e.g.
%################
% y=tiedrank(X);
% z=ceil((GroupNumber*y)/length(X));
% % z contains labels have the same length as X, and each element corresponded with element in X, so that this 
% % vector can be used to do some group calculations to X
%#################
% [curve, goodness, output] = fit(month,pressure,'smoothingspline');
% or using the smooth function, with 'rloess' option
% plot(curve,month,pressure);
%this fitting can be used to fit a smoothing spine curve through given
%variables

% y = max(x,0)
% this will return a matrix y, which is the same size as x, but set all
% negtive values in x into 0

% plot multiple lines, and set different lines into different linewidth
% hh = plot(rand(2,5));
% set(hh,{'LineWidth'},{1,1.2,1.3,1.4,2.5}');

% ######################
% lillietest
% returns a test decision for the null hypothesis that the data in vector x comes from a distribution in the normal family, 
% against the alternative that it does not come from such a distribution, using a Lilliefors test.

% ######################
% GrdistPlot(GrData,varargin)
% custum function used for Group data plots


% ############################
% exponential decay function, lamda insicates 'exponential decay constant'
% N0 = 1;
% lamda = 0.8;
% t = 0 : 1/30 : 5;
% mdFun = @(x) N0*exp(-lamda*x);
% 
% figure;
% plot(t,mdFun(t))
% https://en.wikipedia.org/wiki/Exponential_decay

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset color scale for multiple subplots
h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
nAxes = length(axesObjs);
for cA = 1 : nAxes
    try
        set(axesObjs(cA),'clim',[0 300]); %,'xlim',[0 6*28]
        set(axesObjs(cA),'box','off');
    end
end


%% %%%%% ##################################################################
%extract data from fig file
  h = gcf; %current figure handle
  axesObjs = get(h, 'Children');  %axes handles
  dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
  %% high bersion matlab
  xdata1 = get(dataObjs(1), 'XData');  %data from low-level grahics objects
  ydata1 = get(dataObjs(1), 'YData');
  xdata2 = get(dataObjs(2), 'XData');  %data from low-level grahics objects
  ydata2 = get(dataObjs(2), 'YData');
  % low version matlab
%    xdata = get(dataObjs{2}, 'XData');  %data from low-level grahics objects
%   ydata = get(dataObjs{2}, 'YData');
%   zdata = get(dataObjs, 'ZData');
%   uData = get(dataObjs, 'UData');  %extract errorbar data is using errorbar plot, the sem value
%  %find line objects data
%   lineObjs = findobj(dataObjs, 'type', 'line');
%   xdata = get(lineObjs, 'XData');
%for matlab version later than 2014b, we can also use dot calculator to
%extract data

%%
% parameter fitting using fminsearch
x = (linspace(-1,1,100))';
TestFun = @(b,x) b(1)./(b(2) + exp(-(x - b(3))*b(4)));
yData = TestFun([1,1,0,10],x);
yNoiseData = yData(:) + 0.1*(rand(length(x),1)-0.5);
ErrorYData = @(a,b,c,d,xData) sum((yNoiseData - a./(b + exp(-(xData - c)*d))).^2); % xData and yNoiseData should all be vector data
v_noise = fminsearch(@(v) ErrorYData(v(1),v(2),v(3),v(4),x),([1 1 0 1])'); % how to select proper initial parameter value, which can affect final 
                                                                           % results significantly
% further fitting options should also be tried

%%
% %rebuilt data matrix from pca result
% [coeff,scoreT,~,~,explainedT,~]=pca(data);
% PopuMean = repmat(mean(data),size(data,1),1);
% RebuildData = scoreT * coeff' + PopuMean;
% %RebuildData is the same as data, but because the float accuracy is not the
% %same, so isequal(RebuildData,data) will return 0

%while project a new matrix into exists projection matrix, perfroming
%columnwise mean value substraction from raw dataset and then perfroming
%the projection

%plot seperate lines using one line of code
% line([-4 4 NaN 0 0 NaN 0 0], [0 0 NaN -4 4 NaN 0 0],[0 0 NaN 0 0 NaN -4 4], 'Color','black')

%###################################
% classifiers to be considered
% bayes classification
% fitcnb can be used to do naive bayes classification, try it out when time is avaluable
% fitrsvm : support vector regression model generation

% linear discrimination classifier
% fitcdiscr: discriminant analysis classifier

% calculate the zscore of the given probability
% two line code:
% pd = makedist('Normal',0,1);
% ZScore = icdf(pd,p);  % calculate the corresponded z value given
% posibility p.  e.g.: if p = 0.5, z = 0;

% combinational number calculate function
% nchoosek(n,k)
% factorial(n)   % ½×³Ëº¯Êý

% function annotation: put a line object outside current axes(basically anywhere settled by the
% coordinates), can be used as an explanation of current dataset (e.g. modulation time and so on)
% annotation(figure1,'line',[0.228571428571429 0.508928571428571],...
%     [0.953761904761905 0.954761904761905],'Color',[0 1 0],'LineWidth',2);

% #########################################################################
% add a line to the colorbar
% figure;
% level = 0.9;
% h_colorbar = colorbar;
% h_axes = axes('position', h_colorbar.Position, 'ylim', h_colorbar.Limits, 'color', 'none', 'visible','off');
% line(h_axes.XLim, level*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);

% while return the reletive object position, remember to add the original
% axis position

% ##############################################################################
% % calculate the mutual information, simple example
% IndsFrac = [20 40 60 70 80 90 95 99];
% InfoAllSave = zeros(1 , length(IndsFrac));
% x = double(rand(100,1) > 0.5);
% for IndsIndex = 1 : length(IndsFrac)
%     cIndsFrac = IndsFrac(IndsIndex);
%     cInds = randsample(100,IndsFrac(IndsIndex));
%     y = double(rand(100,1) > 0.5);
%     y(cInds) = x(cInds);
%     
%     xTypes = unique(x);
%     yTypes = unique(y);
%     xTypeProb = zeros(length(xTypes),1);
%     yTypeProb = zeros(length(yTypes),1);
%     Joint_p = zeros(length(xTypes),length(yTypes));
%     InfoAll = zeros(length(xTypes),length(yTypes));
%     for cx = 1 : length(xTypes)
%         xTypeProb(cx) = mean(x == xTypes(cx));
%         for cy = 1 : length(yTypes)
%             if cx == 1
%                yTypeProb(cy) = mean(y == yTypes(cy));
%             end
%             Joint_p(cx,cy) = mean(x == xTypes(cx) & y == yTypes(cy));
%             InfoAll(cx,cy) = Joint_p(cx,cy)*log2(Joint_p(cx,cy)/(xTypeProb(cx)*yTypeProb(cy)));
%         end
%     end
%     InfoAllSave(IndsIndex) = sum(InfoAll(:));
% end
% ##############################################################################

% ##############################################################################
% calculate customized function derivative function and then calculate
% corresponded value
%     F=@(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
%     fit_ReNew = FitPsycheCurveWH_nx(cSessOcts, cSessChoice, ParaBoundLim);
%     syms x
%     ff = F(fit_ReNew.ffit.g,fit_ReNew.ffit.l,fit_ReNew.ffit.u,fit_ReNew.ffit.v,x);
%     fslope = diff(ff,x);
%     DerivData = double(subs(fslope,fit_ReNew.curve(:,1))); % calculate the derivative function and convert into double value
% %   Using the int() function to do integration operation
% ##############################################################################

% ##############################################################################
% function "sgolayfilt" was used for appling a Savitzky-Golay filtering to raw data

% A Savitzky¨CGolay filter is a digital filter that can be applied to a set of 
% digital data points for the purpose of smoothing the data, that is, 
% to increase the signal-to-noise ratio without greatly distorting the signal

% Savitzky-Golay filter as it preserves the local maxima of the original signal better than the others

% ##############################################################################

%% for passive session used frequency trial index finding

% clearvars -except NormSessPathTask NormSessPathPass
% nSess = length(NormSessPathPass);
% % ErroSess = [];
% for css = 1 : nSess
%     
%     csPath = NormSessPathPass{css};
%     cd(csPath);
%     cdTaskPath = NormSessPathTask{css};
%     clearvars SelectSArray SelectData UsedROIInds BehavDataStrc ROIIndex
%     
%     BehavDataStrc = load(fullfile(cdTaskPath,'RandP_data_plots','boundary_result.mat'));
%     TaskSound = BehavDataStrc.boundary_result.StimType;
%     if exist(fullfile(cdTaskPath,'Tunning_fun_plot_New1s','SelectROIIndex.mat'),'file')
%         load(fullfile(cdTaskPath,'Tunning_fun_plot_New1s','SelectROIIndex.mat'));
%         UsedROIInds = logical(ROIIndex);
%     end 
%     
%     load('rfSelectDataSet.mat');
%     PassFreqs = (unique(SelectSArray))';
%     disp(TaskSound);
%     disp(PassFreqs);
%     
%     PassUsedStrs = input('Please input the passive used frequency inds:\n','s');
%     PassTeUsedInds = str2num(PassUsedStrs);
%     if length(PassTeUsedInds) == 1 && PassTeUsedInds > 0
%         PassUsedInds = true(numel(PassFreqs),1);
%         PassUsedTrInds = true(numel(SelectSArray),1);
%     elseif length(PassTeUsedInds) > 2
%         PassUsedInds = PassTeUsedInds;
%         PassUsedFreqs = PassFreqs(PassUsedInds);
%         PassUsedTrInds = false(numel(SelectSArray),1);
%         for cf = 1 : length(PassUsedFreqs)
%             cfInds = SelectSArray == PassUsedFreqs(cf);
%             PassUsedTrInds(cfInds) = true;
%         end
%     else
%         PassUsedInds = [];
%         PassUsedTrInds = [];
%     end
%     
%     save PassUsedInds.mat PassUsedInds PassUsedTrInds -v7.3
% end


