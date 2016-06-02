function f=get_score(TT,TE,SFr)

%GET_SCORE cross-validation of detected event times in terms of number of
%correctly detected events, number of omissions and number of false alarms.
%
%   f=GET_SCORE(TT,TE,SFr)
%   This function calculates the number of correctly detected spikes in
%   TT, the number of omissions and false alarms.
%   TT is a sequence of true spike times (row vector).
%   TE is a vector of detected spike times (row vector).
%   SFr is a sampling frequency [kHz].
%   f - 1 x 3 vector, f(1)-correct, f(2)-omissions, f(3)-false alarms.

%   Zoran Nenadic
%   California Institute of Technology
%   May 2003

W=0.5;      %[ms] allowed jitter in event times, e.g. tt=550.1; te=550.5 ->
            %these are coincident

M=max([TT TE]);

%initial indicator vectors

Indic_t=zeros(1,M);
Indic_e=Indic_t;

%put 1's where the spikes are

Indic_t(TT)=1;
Indic_e(TE)=1;

W=round(W*SFr);

%define the shifts for Indic_e

Lag=1:W;
Lead=1:W;

E_lead=lead_ts(Indic_e,Lead);
E_lead=[Indic_e; E_lead];
E_lag=lag_ts(Indic_e,Lag);

E_shift=[E_lead; E_lag];    %2W+1 x Nt matrix - the matrix of shifted Indic_e

%multiply them together

Coinc=and(ones(2*W+1,1)*Indic_t,E_shift);

%combine coincident events

temp=Coinc(1,:);
for i=1:2*W
    temp=or(Coinc(i+1,:),temp);
end

%get score

Corr=sum(temp);             %correct
Om=(length(TT)-Corr);       %omission
Com=(length(TE)-Corr);      %commission

f=[Corr Om Com];
    