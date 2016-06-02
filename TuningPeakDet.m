function TuningPeakDet(TuningData,varargin)
%this function will be used for tuning frequency detection using data comes
%from function: in_site_freTuning 

dataSize=size(TuningData);  %this should be a three dimensional data m by n by p, with m ROIs, n frequency and p intensity types
maxValue=zeros(dataSize(1),dataSize(3));
maxInds=cell(dataSize(1),dataSize(3));
TuningIndex = zeros(dataSize(1),1);

if ~isdir('./temp_test_storage/')
    mkdir('./temp_test_storage/');
end
cd('./temp_test_storage/');

for n=1:dataSize(1)
    SingleROITuning=squeeze(TuningData(n,:,:));
    TempMaxInds=[];
    NoiseMad=mad(SingleROITuning(:));
    for m=1:dataSize(3)
        c=max(SingleROITuning(:,m));
        I=find(SingleROITuning(:,m)==c);
        maxValue(n,m)=c;
        maxInds(n,m)={I};
        TempMaxInds=[TempMaxInds I'];
    end
    [M,F]=mode(TempMaxInds);
    if F == dataSize(3)
       TuningIndex(n) = M;
%        continue;
    elseif F == dataSize(3) - 1
        maxC=max(maxValue(n,:));
        NorInds=maxValue(n,:)~=maxC;
        MeanNorIndsValue=mean(maxValue(n,NorInds));
        if maxC > (3 * MeanNorIndsValue)
            disp(['One tuning curve peak value is far more larger than other values, this maybe an false positive result for ROI' num2str(n) '.\n']);
            TuningIndex(n) = -1; %this value means no tuning property
%             continue;
        else
            if maxC>(NoiseMad * 3) && max(SingleROITuning(:,M))>50
                TuningIndex(n) = M;
            else
                disp(['The peak value is around noise signal, omit as responsiveness for ROI' num2str(n) '.\n']);
            end
        end
    else
        if length(TempMaxInds) == dataSize(3)
            [indsValue1,indsindex1]= sort(TempMaxInds);
            indsDiff=diff(indsValue1);
            if isequal(diff(indsValue1),ones(1,(dataSize(3)-1)))
                TuningIndex(n) = ceil(median(TempMaxInds));
            elseif (sum(indsDiff==1) == dataSize(3)-2)  %two neighbor peak with one far low response peak
                OnediffInds=find(indsDiff==1);
                RealOnediffInds=[indsindex1(OnediffInds(1)) indsindex1(OnediffInds+1)];
                temp_index=zeros(1,dataSize(3));
                temp_index(RealOnediffInds)=1;
                temp_index=logical(temp_index);
                if max(maxValue(n,temp_index)) > 3*max(maxValue(n,~temp_index))
                    TuningIndex(n) = ceil(median(TempMaxInds(temp_index)));
%                     continue;
                else
                    TuningIndex(n) = -1;
%                     continue;
                end
            end
        else
            [indsValue,Inds] = sort(TempMaxInds);
            indsdiff=diff(indsValue);
            if sum(indsdiff == 1) == (dataSize(3)-1)
                NeighIndsdiff=find(indsdiff == 1);
                NeighInds = [NeighIndsdiff(1) NeighIndsdiff+1];
                NeighIndsReal = TempMaxInds(Inds(NeighInds));
                TuningIndex(n) = ceil(median(NeighIndsReal));
%                 continue;
            elseif sum(indsdiff == 1) > (dataSize(3)-1)
                disp(['Multi peak may exists for ROI' num2str(n) ', please check it out manually.\n']);
                TuningIndex(n) = -1;
%                 continue;
            else
                disp(['No obvious tuning peak exists for ROI' num2str(n) ', continue following analysis.\n']);
                TuningIndex(n) = -1;
            end
        end
    end
    h=figure;
    plot(SingleROITuning,'-o','LineWidth',1.5,'MarkerSize',8);
    xlim([-2 16]);
    hold on;
    h_axis=axis;
    line([TuningIndex(n),TuningIndex(n)],[h_axis(3),h_axis(4)],'color','c');
    line([h_axis(1),h_axis(2)],[NoiseMad,NoiseMad],'color','g');
    line([h_axis(1),h_axis(2)],[NoiseMad,NoiseMad]*3,'color','y');
    hold off;
    title(['ROI' num2str(n)]);
    saveas(h,['test plot for ROI' num2str(n)],'png');
    saveas(h,['test plot for ROI' num2str(n)]);
    close(h);
end
   cd ..;         