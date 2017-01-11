
addchar = 'y';
DataSum = {};
DataPath = {};
LeftTrialDefines = [0,0,0];  % number of: choice, sensory, none
LeftTrialExtens = {[],[],[]};
RightTrialDefines = [0,0,0];
RightTrialExtens = {[],[],[]};
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('ErrorFactorexplain.mat','Please select your Session response modulation saving result');
    if fi
        DataPath{m} = fullfile(fp,fn);
        xx = load(DataPath{m});
        cLeftExplain = xx.LeftFactor;
        cLeftExtanded = xx.LeftExtanded;
        switch cLeftExplain
            case 'choice'
                LeftTrialDefines(1) = LeftTrialDefines(1) + 1;
                LeftTrialExtens{1} = [LeftTrialExtens{1},cLeftExtanded];
            case 'sensory'
                LeftTrialDefines(2) = LeftTrialDefines(2) + 1;
                LeftTrialExtens{2} = [LeftTrialExtens{2},cLeftExtanded];
            case 'none'
                LeftTrialDefines(3) = LeftTrialDefines(3) + 1;
                LeftTrialExtens{3} = [LeftTrialExtens{3},cLeftExtanded];
        end
        
        cRightExplain = xx.RightFactor;
        cRightExtanded = xx.RightExtanded;
        switch cRightExplain
            case 'choice'
                RightTrialDefines(1) = RightTrialDefines(1) + 1;
                RightTrialExtens{1} = [RightTrialExtens{1},cRightExtanded];
            case 'sensory'
                RightTrialDefines(2) = RightTrialDefines(2) + 1;
                RightTrialExtens{2} = [RightTrialExtens{2},cRightExtanded];
            case 'none'
                RightTrialDefines(3) = RightTrialDefines(3) + 1;
                RightTrialExtens{3} = [RightTrialExtens{3},cRightExtanded];
        end
        m = m + 1;
    end
    
    addchar = input('Would you like to add another session data?\n','s');
end

if fi
    m = m - 1;
end

%%
DataSvaePath = uigetdir('Please select a path to save current data');
cd(DataSvaePath);
save SummaryDataSave.mat DataSum LeftTrialDefines LeftTrialExtens RightTrialDefines RightTrialExtens -v7.3
f = fopen('Session_response_explanation_path.txt','w+');
fprintf(f,'Sessions used for analysis selection index contribution summary path:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,DataPath{nbnb});
end
fclose(f);

%%
h_summary = figure('position',[100 100 1000 800]);
LeftAxs = subplot(121);
pLeft = Cuspie(LeftTrialDefines,{sprintf('Choice Factor\n = %.3f',mean(LeftTrialExtens{1})),sprintf('Sensory Factor\n = %.3f',mean(LeftTrialExtens{2})),...
    sprintf('None Factor\n = %.3f',mean(LeftTrialExtens{3}))});
title('Left Trials');
set(gca,'FontSize',18);

RightAxs = subplot(122);
pRight = Cuspie(RightTrialDefines,{sprintf('Choice Factor\n = %.3f',mean(RightTrialExtens{1})),sprintf('Senspry Factor\n = %.3f',mean(RightTrialExtens{2})),...
    sprintf('None Factor\n = %.3f',mean(RightTrialExtens{3}))});
title('Right Trials');
set(gca,'FontSize',18);
annotation('textbox',[0.25,0.6,0.3,0.3],'String','Explanation of left and right trials explanation','FitBoxToText','on','EdgeColor',...
                'none','FontSize',20);
saveas(h_summary,'Session explanation distribution');
saveas(h_summary,'Session explanation distribution','png');
close(h_summary);
