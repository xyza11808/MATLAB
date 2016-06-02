function y=EventsFitFun(x,TauOn,A1,Tau1,A2,Tau2)  
%,A3,Tau3,A4,Tau4
t0=58;  %data points number extracted before timeOnset
% t1=158;
y=zeros(size(x));
for m=1:length(x)
    t=x(m);
    if t<=t0
        y(m)=0;
    else  %if t<t1
        y(m)=(1-exp(-(t-t0)/TauOn))*( ...
        A1*exp(-(t-t0)/Tau1) + A2*exp(-(t-t0)/Tau2));
%     else
%         y(m)=(1-exp(-(t-t0)/TauOn))*( ...
%         A1*exp(-(t-t0)/Tau1) + A2*exp(-(t-t0)/Tau2))+ ...
%         (1-exp(-(t-t1)/TauOn))*(A3*exp(-(t-t1)/Tau3) + A4*exp(-(t-t1)/Tau4));
    end
end

%%
% double-peak fitting
% for m=1:length(x)
%     t=x(m);
%     if t<t0
%         y(m)=0;
%     elseif t<t1
%         y(m)=(1-exp(-(t-t0)/TauOn))*( ...
%         A1*exp(-(t-t0)/Tau1) + A2*exp(-(t-t0)/Tau2));
%     else
%         y(m)=(1-exp(-(t-t0)/TauOn))*( ...
%         A1*exp(-(t-t0)/Tau1) + A2*exp(-(t-t0)/Tau2))+ ...
%         (1-exp(-(t-t1)/TauOn))*(A3*exp(-(t-t1)/Tau3) + A4*exp(-(t-t1)/Tau4));
%     end
% end