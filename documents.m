%%documentations
%to plot a two dimension matrix color map can use functions like surf and
%pcolor image and so on
%magesc
%imagesc
%
%function fir1 and fir2 can be used as lowband-pass filter or highbang-pass
%filter

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
% y=tiedrand(X);
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


%% %%%%% ##################################################################
%extract data from fig file
  h = gcf; %current figure handle
  axesObjs = get(h, 'Children');  %axes handles
  dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
  % high bersion matlab
  xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
  ydata = get(dataObjs, 'YData');
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


%%
%this section used to be used for all trials plot in AFC_ROI_analysis
%function, just as a backup
%     %######################################################
%     %plot of all trial results
%     if ~isdir('.\ALLTrial_plot_save_SM\')
%         mkdir('.\ALLTrial_plot_save_SM\');
%     end
%     cd('.\ALLTrial_plot_save_SM\');
%     C_lim_all=[];
%     x_tick=frame_rate:frame_rate:framelength;
%     x_tick_label=1:floor(double(framelength)/frame_rate);
%     for n=1:size_data(2)
%         temp_data=squeeze(data_aligned(:,n,:));
%         C_lim_all(1)=min(temp_data(:));
%          C_lim_all(2)=max(temp_data(:));
%          if C_lim_all(2)>(10*median(temp_data(:)))
%              C_lim_all(2) = (C_lim_all(2)+median(temp_data(:)))/3;
%          end
%          if C_lim_all(2) > 500
%                  C_lim_all(2) = 400;
%          end
%          if diff(C_lim_all)<=0 || sum(isnan(C_lim_all))~=0
%              disp(['Error data present for ROI' num2str(n) ', skip this ROI.\n']);
%              continue;
%          end
%         h_all=figure;
%         subplot(3,2,1);
%         imagesc(temp_data(plot_data_inds.left_trials_bingo_inds,:),C_lim_all);
%         set(gca,'xticklabel',[],'yticklabel',[]);
%         ylabel('correct\_left\_trial');
%         hold on;
%         hh2=axis;   
%         triger_position=floor((double(align_time_point)/1000)*frame_rate);
%         plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
%         hold off;
%         
%         subplot(3,2,3);
%         imagesc(temp_data(plot_data_inds.left_trials_oops_inds,:),C_lim_all);
%         set(gca,'xticklabel',[],'yticklabel',[]);
%         ylabel('Error\_left\_trial');
%         hold on;
%         hh2=axis;   
% %         triger_position=align_time_point*frame_rate;
%         plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
%         hold off;
%         
%         subplot(3,2,5);
%         imagesc(temp_data(plot_data_inds.left_trials_miss_inds,:),C_lim_all);
%         set(gca,'xtick',x_tick,'xticklabel',x_tick_label,'yticklabel',[]);
%         ylabel('Miss\_left\_trial');
%         hold on;
%         hh2=axis;   
% %         triger_position=align_time_point*frame_rate;
%         plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
%         hold off;
%         
%         subplot(3,2,2);
%         imagesc(temp_data(plot_data_inds.right_trials_bingo_inds,:),C_lim_all);
%         set(gca,'xticklabel',[],'yticklabel',[]);
%         ylabel('correct\_right\_trial');
%          hold on;
%         hh2=axis;   
% %         triger_position=align_time_point*frame_rate;
%         plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
%         hold off;
%         
%         subplot(3,2,4);
%         imagesc(temp_data(plot_data_inds.right_trials_oops_inds,:),C_lim_all);
%         set(gca,'xticklabel',[],'yticklabel',[]);
%         ylabel('Error\_right\_trial');
%          hold on;
%         hh2=axis;   
% %         triger_position=align_time_point*frame_rate;
%         plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
%         hold off;
%         
%         subplot(3,2,6);
%         imagesc(temp_data(plot_data_inds.right_trials_miss_inds,:),C_lim_all);
%         set(gca,'xtick',x_tick,'xticklabel',x_tick_label,'yticklabel',[]);
%         ylabel('Miss\_right\_trial');
%          h_bar=colorbar;
%         plot_position_all=get(h_bar,'position');
%         set(h_bar,'position',[plot_position_all(1)*1.13 plot_position_all(2) plot_position_all(3)*0.4 plot_position_all(4)])
%         set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%          hold on;
%         hh2=axis;   
% %         triger_position=align_time_point*frame_rate;
%         plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
%         hold off;
%         
%         suptitle(['ROI\_',num2str(n,'%03d')]);
%         saveas(h_all,[session_date','_Sum_plot_ROI_',num2str(n,'%03d'),'.png']);
%         close;
%     end
%     cd ..;
%
%%

%current ROI drawing progress:
%L:\imagingdata\batch\batch17\20150819\anm03\test01\im_data_reg



