x=readtable('G:\PreData\Statistic_result_forabstract.xlsx');

StimOnT=x.FreqOnset;
SensoryAmp=x.SensoryAmp_;
NonSensoryT=x.NonSensoryOn;
NSAmp=x.NSAmp_;
PeakDur=x.Dur;

%%
StimOnT(StimOnT==0)=[];
EmptyAmpInds = SensoryAmp==0 | NSAmp==0;
SensoryAmp(EmptyAmpInds)=[];
NSAmp(EmptyAmpInds)=[];
NonSensoryT(NonSensoryT==0)=[];
PeakDur(isnan(PeakDur))=[];
