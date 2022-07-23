function nll = NLL_MB_RL_function_v3(theta_pred,beta_pred,alpha_pred,Plow_init,Octave_used,left_choice_used,inds_correct_used)

Bound_1 = .5;%2^0.5*7000;%0.5;
Bound_2 = 1.5;%2^1.5*7000;%1.5;
P_bound_low(1) = Plow_init;
P_bound_high(1) = 1 -Plow_init;

for t = 1:length(Octave_used)
    
    P_low_1(t) = cdf('norm',Bound_1,double(Octave_used(t)),theta_pred); % the probability for sound freq < low boundary
    P_low_2(t) = cdf('norm',Bound_2,double(Octave_used(t)),theta_pred); % the probability for sound freq < high boundary
    
    P_low_1(t) = roundn(P_low_1(t),-2);
    P_low_2(t) = roundn(P_low_2(t),-2);
    
    V_L(t) = P_low_1(t)*P_bound_low(t) + P_low_2(t)*P_bound_high(t);
    V_R(t) = (1-P_low_1(t))*P_bound_low(t) + (1-P_low_2(t))*P_bound_high(t);
    P_L(t) = exp(V_L(t).*beta_pred)./(exp(V_L(t).*beta_pred) + exp(V_R(t).*beta_pred));
    
    P_bound_low_update(t) = P_bound_low(t)/(P_bound_low(t)+P_bound_high(t));
    P_bound_high_update(t) = P_bound_high(t)/(P_bound_low(t)+P_bound_high(t));
    
    if left_choice_used(t)
        V_Chosen(t) = V_L(t);
        p_LowB_givenA(t) = P_low_1(t)/(P_low_1(t) + P_low_2(t));
        p_HighB_givenA(t) = P_low_2(t)/(P_low_1(t) + P_low_2(t));
        V_Chosen_low(t) = P_low_1(t);
        V_Chosen_high(t) = P_low_2(t);
    else
        V_Chosen(t) = V_R(t);
        p_LowB_givenA(t) = (1-P_low_1(t))/(2-(P_low_1(t) + P_low_2(t)));
        p_HighB_givenA(t) = (1-P_low_2(t))/(2-(P_low_1(t) + P_low_2(t)));
        V_Chosen_low(t) = 1- P_low_1(t);
        V_Chosen_high(t) = 1- P_low_2(t);
    end

    

    delta(t) =  inds_correct_used(t) - V_Chosen(t);

    

       P_bound_low(t+1) = P_bound_low(t) + alpha_pred*delta(t)*V_Chosen_low(t);
       P_bound_high(t+1) = P_bound_high(t) + alpha_pred*delta(t)*V_Chosen_high(t);
    

    
    if left_choice_used(t)
        P_choice(t) = P_L(t);
    else
        P_choice(t) = 1-P_L(t);
    end
    
    
end
hmin = 1e-300;
sel = P_choice <= hmin;
lik = P_choice;
lik(sel) = hmin;
nll = -sum(log(lik));
end