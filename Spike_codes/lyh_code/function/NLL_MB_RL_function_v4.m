function nll = NLL_MB_RL_function_v4(theta_pred,beta_pred,alpha_pred,Plow_init,...
    Octave_used,left_choice_used,inds_correct_used,varargin)

% session default bound is predefined
Bound_1 = 0.5;%2^0.5*7000;%0.5;
Bound_2 = 1.5;%2^1.5*7000;%1.5;
if ~isempty(varargin)
    Bound_1 = varargin{1}(2);
    Bound_2 = varargin{1}(1);
end

NumUsedTrs = length(Octave_used);
P_bound_lowANDhigh = zeros(NumUsedTrs+1,2);
% P_bound_lowANDhigh_updates = zeros(NumUsedTrs,2);
P_lows = zeros(NumUsedTrs,2);
V_LR = zeros(NumUsedTrs,2);
P_L = zeros(NumUsedTrs,1);

V_Chosen = zeros(NumUsedTrs,1);
p_lowHighBound_givenA = zeros(NumUsedTrs,2);
V_Choosen_LowANDHigh = zeros(NumUsedTrs,2);
delta = zeros(NumUsedTrs,1);
P_Choice = zeros(NumUsedTrs,1);

P_bound_lowANDhigh(1,:) = [Plow_init,1-Plow_init];

for t = 1 : NumUsedTrs
    P_lows(t,:) = [roundn(cdf('norm',Bound_1,double(Octave_used(t)),theta_pred),-4),...
        roundn(cdf('norm',Bound_2,double(Octave_used(t)),theta_pred),-4)];
    
    V_LR(t,1) = sum(P_lows(t,:) .* P_bound_lowANDhigh(t,:));
    V_LR(t,2) = sum((1-P_lows(t,:)) .* P_bound_lowANDhigh(t,:));
    if any(isinf(exp(V_LR(t,:)*beta_pred)))
        values = double(isinf(exp(V_LR(t,:)*beta_pred)));
        P_L(t) = values(1);
    else
        P_L(t) = exp(V_LR(t,1)*beta_pred) / (sum(exp(V_LR(t,:)*beta_pred)));
    end
    
%     P_bound_lowANDhigh_updates(t,:) = P_bound_lowANDhigh(t,:)/sum(P_bound_lowANDhigh(t,:));
    
    if left_choice_used(t)
       V_Chosen(t) = V_LR(t,1);
       p_lowHighBound_givenA(t,:) = P_lows(t,:)/sum(P_lows(t,:));
       V_Choosen_LowANDHigh(t,:) = P_lows(t,:);
    else
       V_Chosen(t) = V_LR(t,2);
       p_lowHighBound_givenA(t,:) = (1-P_lows(t,:))/sum(1-P_lows(t,:));
       V_Choosen_LowANDHigh(t,:) = 1-P_lows(t,:);
    end
    
    delta(t) = inds_correct_used(t) - V_Chosen(t);
    
    P_bound_lowANDhigh(t+1,:) = P_bound_lowANDhigh(t,:)+...
        alpha_pred*delta(t)*V_Choosen_LowANDHigh(t,:);
    if abs(sum(P_bound_lowANDhigh(t+1,:))) < 0.01
        % if the summrized value is very small
        P_bound_lowANDhigh(t+1,:) = P_bound_lowANDhigh(t+1,:) - min(P_bound_lowANDhigh(t+1,:));
    end
    P_bound_lowANDhigh(t+1,:) = P_bound_lowANDhigh(t+1,:) / sum(P_bound_lowANDhigh(t+1,:));
    
    if left_choice_used(t)
        P_Choice(t) = P_L(t);
    else
        P_Choice(t) = 1-P_L(t);
    end
    if isnan(P_Choice(t))
        disp(t);
    end
end
hmin = 1e-100;
sel = P_Choice <= hmin;
lik = P_Choice;
lik(sel) = hmin;
nll = -sum(log(lik));





