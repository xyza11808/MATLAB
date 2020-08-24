Gaps = 8;
TotalNum = ([16,51;56,81;76,91;65,7])';
TypeFrac = TotalNum / sum(TotalNum(:));
JobTypeFrac = sum(TypeFrac);
Numbers = [16,51,Gaps,56,81,Gaps,76,91,Gaps,65,7,Gaps];
StrTexts = {'PI','Postdoc','Staff','Company'};
Colors = {[0.36 0.61 0.83],[0.93 0.49 0.19],[0.64 0.64 0.64],[0.9,0.7,0]};
Alpha = [0,1,1];
figure;
explode = [0 0 1 0 0 1 0 0 1 0 0 1];
hhh = pie3(Numbers,explode);

for cDataPatch = 1 : length(Numbers)
    PatchIndex = ceil(cDataPatch/3);
    AlphaMod = mod(cDataPatch,3)+1;
    
    if mod(cDataPatch,3)
        if mod(cDataPatch,3) == 1
            Face_Colors = Colors{PatchIndex};
            Strings = [StrTexts{PatchIndex},' ',sprintf('%.1f%%',JobTypeFrac(PatchIndex)*100)];
        elseif mod(cDataPatch,3) == 2
            Face_Colors = max(Colors{PatchIndex}-0.15,0);
            if PatchIndex == 4
                Strings = 'Other';
            else
                Strings = '';
            end
        end
            
        Edge_Color = 'none';
        cAlpha = Alpha(AlphaMod);
%         Strings = StrTexts{PatchIndex};
    else
        Face_Colors = 'none';
        Edge_Color = 'none';
        cAlpha = 0;
        Strings = '';
    end
    
    for cPlotPatch = 1 : 4
        HandleIndex = (cDataPatch-1)*4 + cPlotPatch;
        
        if cPlotPatch ~= 4
            set(hhh(HandleIndex),'Facecolor',Face_Colors,'EdgeColor',Edge_Color,'FaceAlpha',cAlpha);
        else
            set(hhh(HandleIndex),'string',Strings);
        end 
    end
    
end
        

%% 招生数据
cclr
Year =  {'1999年','2000年','2001年','2002年','2003年','2004年','2005年','2006年',...
        '2007年','2008年','2009年','2010年','2011年','2012年','2013年','2014年','2015年',...
        '2016年','2017年','2018年','2019年','2020年'};
% YearsNum = length(Year);
Liandu_data = [12,20,14,22,26,24,27,27,27,28,33,35,33,35,34,35,41,39,40,40,40,40];
Zhibo_data = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8];   
Zhuanshuo_data = [0,0,0,0,0,0,0,0,0,0,0,2,1,1,2,0,2,2,2,2,7,7];
Waibo_data = [0,0,0,0,6,6,5,5,6,7,5,4,2,2,4,3,3,8,3,5,2,7];
Xueshuo_data = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];

DataSums = [Liandu_data;Zhuanshuo_data;Waibo_data;Zhibo_data;Xueshuo_data];
LengStrs = {'liandu','zhuanshuo','waibo','zhibo','xueshuo'};

% Year = {'2017年','2018年','2019年'};
% University_985 = [219,225,281];
% University_Other = [246,266,276];
% University_985 = [95,129,177];
% University_Other = [90,115,129];

% DataSums = [University_985;University_Other];
% LengStrs = {'985 schools','other schools'};
YearsNum = length(Year);
DataTotalNums = sum(DataSums);
%%
figure;
hbar = bar(DataSums',0.4,'stacked');
NumTypes = size(DataSums,1);
xInds = 1 : YearsNum;
for cData = 1 : NumTypes
    if cData == 1
        CYData = DataSums(1,:); 
    else
        CYData = sum(DataSums(1:cData,:));
    end
    cDataNumbers = DataSums(cData,:);
    PlotInds = cDataNumbers > 0;
    PlotNumbers = cDataNumbers(PlotInds);
    if cData == 1
        text(xInds(PlotInds),CYData(PlotInds)-2,num2str(PlotNumbers(:),'%d'),'Color','w','FontSize',10,'HorizontalAlignment','center');
    else
        text(xInds(PlotInds),CYData(PlotInds)-1,num2str(PlotNumbers(:),'%d'),'Color','w','FontSize',10,'HorizontalAlignment','center');
    end
end
text(xInds,DataTotalNums+2,num2str(DataTotalNums(:),'%d'),'Color','r','FontSize',12,'HorizontalAlignment','center');
set(gca,'box','off','xtick',xInds,'xticklabel',Year','xlim',[0.5 YearsNum+0.5]);
% xlabel('years');
ylabel('招生数目');
set(gca,'FontSize',12)
legend(hbar,LengStrs,'Location','Northwest','Box','off','FontSize',10);

%%
saveas(gcf,'Summer school number_2 bar plot')
saveas(gcf,'Summer school number_2 bar plot','png')
saveas(gcf,'Summer school number_2 bar plot','pdf')

%% line plot
xInds = 1 : YearsNum;
hlinef = figure;
hold on
lineCs = [0,0.445,0.738;0.848,0.324,0.098;0.956,0.691,0.125;0.492,0.184,0.555;0.4648,0.6719,0.1875];
% lineCs = [0,0.445,0.738;0.848,0.324,0.098];
hl = [];
for cline = 1 : NumTypes
    cLineData = DataSums(cline,:);
    UsedInds = cLineData > 0;
    lll = plot(xInds(UsedInds),cLineData(UsedInds),'-o','Color',lineCs(cline,:),'linewidth',1.6,...
        'MarkerSize',8,'MarkerEdgeColor','none','MarkerFaceColor',lineCs(cline,:));
    hl = [hl;lll];
end
Totall = plot(xInds,sum(DataSums),'-o','Color','k','linewidth',1.6,...
        'MarkerSize',10,'MarkerEdgeColor','none','MarkerFaceColor','k');
hl = [hl;Totall];
legend(hl,[LengStrs(:)',{'Total'}],'Location','Northwest','Box','off','FontSize',10);
YearNumstr = cellfun(@(x) x(1:end-1), Year, 'Uniformoutput',false);
set(gca,'box','off','xtick',xInds,'xticklabel',YearNumstr');
xlabel('年份');
ylabel('招生数目');
set(gca,'FontSize',12);
%%
saveas(gcf,'Summer school number_2 line plot')
saveas(gcf,'Summer school number_2 line plot','png')
saveas(gcf,'Summer school number_2 line plot','pdf')