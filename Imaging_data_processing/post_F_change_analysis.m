function

f_change=zeros(65,3,75)
f_raw_trials=zeros(65,3,75);
for i=1:65
    f_raw_trials(i,:,:)=CaTrials(i).f_raw(:,:);
end

for  %ROI mode calculation
    a=reshape(f_raw_trials(:,1,:),[],1);
    [N,x]=hist(a,100);
    f_mode=min(x(N==max(N)));%calculate the value of F0
    
    %calculate DF/F0
    
end

