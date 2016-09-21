% this scription will be used for summarize multi-sessional data and
% calculate overall cell rsponsive type fraction

add_char = 'y';
% DataSummary = struct();
m = 1;
datapath = {};

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('SheetAnaResult.mat','Please select your cell response fraction analysis data');
    if fi
        xxx = load(fullfile(fp,fn));
        DataStruct = xxx.ROIrespSummary;
        datapath(m) = {fullfile(fp,fn)};
    end
    if m == 1
        StrFieldName = fieldnames(DataStruct);
        NumStrFieldName = length(StrFieldName);
        DataSummary = DataStruct;
    else
        for n = 1 : NumStrFieldName
            cFieldName = StrFieldName{n};
            if ~strcmpi(cFieldName,'MixedRespSummary')
                DataSummary.(cFieldName) = [DataSummary.(cFieldName); DataStruct.(cFieldName)];
            else
                DataSummary.MixedRespSummary.LeftResp = [DataSummary.MixedRespSummary.LeftResp,DataStruct.MixedRespSummary.LeftResp];
                DataSummary.MixedRespSummary.RightResp = [DataSummary.MixedRespSummary.RightResp,DataStruct.MixedRespSummary.RightResp];
            end
        end
    end
    add_char = input('would you like to add more data?\n','s');
    m = m +1;
end

%%
m = m - 1;
ROIrespSummary = DataSummary;
SrespSum = (length(ROIrespSummary.LeftSRespROI) + length(ROIrespSummary.RightSRespROI));
CrespSum = (length(ROIrespSummary.LeftCRespROI) + length(ROIrespSummary.RightCRespROI));
MrespSum = length(ROIrespSummary.MixedRespROI);
NrespSum = length(ROIrespSummary.NonResponseROI);
TotalROINum = (SrespSum+CrespSum+MrespSum+NrespSum);

H_simplePie = figure('position',[400 220 1150 830]);
Labels = {sprintf('SoundResp(%.1f%%)',SrespSum/TotalROINum*100),sprintf('BehavResp(%.1f%%)',CrespSum/TotalROINum*100),...
    sprintf('MixedResp(%.1f%%)',MrespSum/TotalROINum*100),sprintf('NoneResp(%.1f%%)',NrespSum/TotalROINum*100)};
p = pie([SrespSum,CrespSum,MrespSum,NrespSum],Labels);
xx=findobj(gcf,'Type','text');
set(xx,'FontSize',20)
%     set(gca,'FontSize',20);
title('Summarized Session response fraction','FontSize',20);
text(1,-1,sprintf('n = %d',TotalROINum),'FontSize',25);
saveas(H_simplePie,'Sim_Summarized response fraction');
saveas(H_simplePie,'Sim_Summarized response fraction','png');
% close(H_simplePie);

%detailed pie plot
PieData = [length(ROIrespSummary.LeftSRespROI),length(ROIrespSummary.RightSRespROI),length(ROIrespSummary.LeftCRespROI),...
    length(ROIrespSummary.RightCRespROI),MrespSum,NrespSum];
FractionD = PieData / TotalROINum * 100; % percentage
LabelsD = {sprintf('LeftSound(%.1f%%)',FractionD(1)),sprintf('RightSound(%.1f%%)',FractionD(2)),sprintf('LeftChoice(%.1f%%)',FractionD(3)),...
    sprintf('RightChoice(%.1f%%)',FractionD(4)),sprintf('MixedResp(%.1f%%)',FractionD(5)),sprintf('NoneResp(%.1f%%)',FractionD(6))};
H_detailedPie = figure('position',[400 220 1150 830]);
pD = pie(PieData,LabelsD);
xx=findobj(gcf,'Type','text');
set(xx,'FontSize',20)
title('Detailed Session response fraction','FontSize',20);
text(1,-1,sprintf('n = %d',TotalROINum),'FontSize',25);
saveas(H_detailedPie,'Detailed response fraction');
saveas(H_detailedPie,'Detailed response fraction','png');
% close(H_detailedPie);

save SessionSumSave.mat DataSummary datapath -v7.3