AllROImask=ROIinfoBU.ROImask;
ALlRingmask=ROIinfoBU.Ringmask;

for n=1:length(AllROImask)
    if n==1
        SumMask=AllROImask{n} + (ALlRingmask{n}*2);
    else
        SumMask=SumMask+(AllROImask{n} + (ALlRingmask{n}*2));
    end
end

h=figure;
imagesc(SumMask);


%%
nROI=1;
nTrial=1;

h=figure;
subplot(3,1,1);
plot(CaTrials(nTrial).f_raw(nROI,:));

subplot(3,1,2);
plot(CaTrials(nTrial).RingF(nROI,:));

subplot(3,1,3)
plot(CaTrials(nTrial).f_raw(nROI,:)-CaTrials(nTrial).RingF(nROI,:));
