function Interface_to_FastICA(fhandle, clist)


% This global variable from the fasticag function in FastICA
global hf_FastICA_MAIN;


channels=getappdata(fhandle, 'channels');
len=Inf;
for k=1:length(clist)
    len=min(len, length(channels{clist(k)}.adc));
end

x=zeros(length(clist),len);

for k=1:length(clist)
    x(k,:)=channels{clist(k)}.adc(1:len)';
end

if ishandle(hf_FastICA_MAIN)
    delete(hf_FastICA_MAIN);
    hf_FastICA_MAIN=[];
end

fasticag(x);