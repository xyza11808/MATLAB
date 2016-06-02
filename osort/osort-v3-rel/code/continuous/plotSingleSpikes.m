function plotSingleSpikes(spikes)
till=size(spikes,2);

for i=1:100
    subplot(10,10,i);
    
    spike = spikes(i,:);
    
    
    
    
    %classify
    [waveFormStat,mD,sD,d, dd] = classifyWave( spike );

    
    plot(spike, 'r','linewidth',2);
%    hold on
    
    mm = max(spike);
    line([1 till], [mm mm],'Color','m');
    line([1 till], [1/2*mm 1/2*mm],'Color','g');
    
    %line([1 till], [mean(spike) mean(spike)],'Color','g');
    %line([1 till], [mean(spike)+std(spike) mean(spike)+std(spike)],'Color','g');
    %line([1 till], [mean(spike)-std(spike) mean(spike)-std(spike)],'Color','g');
    
    
    
%     d=d(3:256);
%     plot(3:256,3*d,'m');
%      line([1 till], 3*[mean(d) mean(d)],'Color','g');
%      line([1 till], 3*[mean(d)+3.5*std(d) mean(d)+3.5*std(d)],'Color','g');
%      line([1 till], 3*[mean(d)-3.5*std(d) mean(d)-3.5*std(d)],'Color','g');
%     
    
%     dd=dd(3:256);
%     plot(3:256, 15*dd,'b');
%     line([1 till], 15*[mean(dd) mean(dd)],'Color','g');
%     line([1 till], 15*[mean(dd)+3.5*std(dd) mean(dd)+3.5*std(dd)],'Color','g');
%     line([1 till], 15*[mean(dd)-3.5*std(dd) mean(dd)-3.5*std(dd)],'Color','g');

%    hold off
    
    
    if waveFormStat==true
        text(1,1000,'good');
    else
        text(1,1000,'bad','color','r');
    end
    
    line([0 till],[0 0],'color','m');
    xlim([0 till]);
    ylim([-3000 3000]);
    set(gca,'XTickLabel',{})
    set(gca,'YTickLabel',{})
    
end