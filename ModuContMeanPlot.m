function [h_all,handles,HandlesPatch] = ModuContMeanPlot(DataStrc,AlignT,varargin)
% this function iwll be used for plotting mean trace for different mean
% traces come from different control and modulation condition
% in this function, control trace will be presented as dash line, while the
% modulation trace will be presented as solid line.
% the input variable: DataStrc. is a structure contains all raw data that
% will be used for plotting, with following fields:
                % ControlOBS1: observation 1 for control condition data
                % ModulateOBS1:observation 1 for modulate condition data 
                % ... (OBS2,3... can be added if more observation exists)
% XinYu. 2016

if ~isstruct(DataStrc)
    error('First input variable should be a structure, quit function...');
end

fieldN = fieldnames(DataStrc);
% Control = regexpi()
NumberField = length(fieldN);
if mod(NumberField,2)~=0
    error('Field number should be a even number, cannot performing following analysis.');
end
NumObservations = NumberField/2;
fprintf('Current nput data have %d observations for both control and modulation data.\n',NumObservations);
handles = struct(); % the first column will be control plot handle, second column for modulation plot handle
HandlesPatch = struct(); 
h_all = figure('position',[400 300 1100 700],'paperpositionmode','auto');
hold on;
for nOBS = 1 : NumObservations
    cControlData = DataStrc.(['ControlOBS' num2str(nOBS)]);
    cModuData = DataStrc.(['ModulateOBS' num2str(nOBS)]);
    cControlMean = mean(cControlData);
    cControlSem = std(cControlData)/sqrt(size(cControlData,1));
    ts = 1 : length(cControlMean);
    xP=[ts,fliplr(ts)];
    patchColor = [.8 .8 .8];
    faceAlpha = 0.7;
    
    uE =  (cControlMean + cControlSem);
    lE =  cControlMean - cControlSem;
    yP=[lE,fliplr(uE)];
    
    HandlesPatch(nOBS,1).PatchH = patch(xP,yP,1,'facecolor',patchColor,'edgecolor','none','facealpha',faceAlpha);
    handles(nOBS,1).LineH = plot(cControlMean,'LineWidth',2,'LineStyle','--');

    
    cModuMean = mean(cModuData);
    cModuSem = std(cModuData)/sqrt(size(cModuData,1));
    uE =  cModuMean + cModuSem;
    lE =  cModuMean - cModuSem;
    yP=[lE,fliplr(uE)];
    HandlesPatch(nOBS,2).PatchH = patch(xP,yP,1,'facecolor',patchColor,'edgecolor','none','facealpha',faceAlpha);
    handles(nOBS,2).LineH = plot(cModuMean,'LineWidth',2);
    
end
yaxis = axis();
line([AlignT,AlignT],[yaxis(3),yaxis(4)],'LIneWidth',2,'Color',[.7 .7 .7]);
