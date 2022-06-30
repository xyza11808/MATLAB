% target dimension reduction from Ref: 
% Context-dependent computation by recurrent dynamics in prefrontal cortex
% test script

Unit = 120;
TimeBins = 25;
Trials = 152;
BehavTypes = 4; % behavior conditions, such as stim, choice, reward and so on

FRs = rand(Unit,TimeBins,Trials);
BehavValueMtx = rand(BehavTypes,Trials);

FRegressor = [BehavValueMtx;ones(1,Trials)];
%% calculate coef matrix

betaMtxAll = nan(Unit,TimeBins,BehavTypes+1);
for cU = 1:Unit
    for ct = 1:TimeBins
        betaMtxAll(cU,ct,:) = (FRegressor*FRegressor')\FRegressor * squeeze(FRs(cU,ct,:));
    end
end

%% construct Beta_V_T vector
UsedPCNum = 12;

beta_v_t_vec = zeros(BehavTypes,Unit,TimeBins);
for cU = 1 : BehavTypes
    cU_beta_data = (betaMtxAll(:,:,cU)); % size of TimeBins*BehavTypes
    [Coefs,Score,latent] = pca(cU_beta_data);
    ReconData = Score(:,1:UsedPCNum) * Coefs(:,1:UsedPCNum)' + mean(cU_beta_data);
    beta_v_t_vec(cU,:,:) = ReconData;
end




