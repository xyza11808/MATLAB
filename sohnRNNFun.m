function varargout = sohnRNNFun(RNNUnits,mode,x_init,NetParas,Tau,InOutSize,...
    BatchData,BatchTarget,TBPTT_k,StartPosition,BatchTsLen,LearnRate)
% BatchData three dimension, Batchsize,inputsize,timestep
mode = lower(mode);
varargout = {[],[],[]};
switch mode
    case 'init'
        % initiate RNN network parameters
        InputSize = InOutSize(1);
        OutDataSize = InOutSize(2);
        % J should be a fully connected weights matrix for all units
        J = randn(RNNUnits)/RNNUnits; % zeros mean and 1/N variance
        
        B = (rand(RNNUnits,InputSize)-0.5)*2; % [-1,1]
        
        x_init = (rand(RNNUnits,1)-0.5)*2; 
        
        c_unit_bias = (rand-0.5)*2; 
        
        w_o = zeros(RNNUnits,OutDataSize);
        
        c_z_Outbias = 0;
        
        NetParas = {J, B, w_o, c_unit_bias, c_z_Outbias};
        
        varargout{1} = NetParas;
        varargout{2} = x_init;
        varargout{3} = [];
        
    case 'tbptt'
        [InputSize,TimeSteps,BatchSize] = size(BatchData);
        OutDataSize = size(BatchTarget,1);
        [J, B, w_o, c_unit_bias, c_z_Outbias] = NetParas{:};
        for cBatch = 1 : BatchSize
            cBatchData = squeeze(BatchData(:,:,cBatch));
            cTargetFun = squeeze(BatchTarget(:,:,cBatch));
            cStartPos = StartPosition(cBatch);
            EndPos = cStartPos + BatchTsLen(cBatch);
            
            Unitx_tAll = zeros(RNNUnits,TimeSteps);
            UnitR_tAll = zeros(RNNUnits,TimeSteps);
            OutDataAll = zeros(OutDataSize,TimeSteps);
            [TanhFun,TanhDecFun] = ActFunCheck('Tanh');
            k1 = TBPTT_k(1);
            k2 = TBPTT_k(2);
            
            for cStep = 1 : TimeSteps
                if cStep == 1
                    Delta_x_t = (-x_init + J*TanhFun(x_init) + ...
                        B * (cBatchData(:,cStep)) + c_unit_bias + randn(RNNUnits,1)*0.01)/Tau;
                    Unitx_tAll(:,cStep) = x_init + Delta_x_t;
                else
                    Delta_x_t = (-Unitx_tAll(:,cStep-1) + J*UnitR_tAll(:,cStep-1) + ...
                        B * (cBatchData(:,cStep)) + c_unit_bias + randn(RNNUnits,1)*0.01)/Tau;
                    Unitx_tAll(:,cStep) = Unitx_tAll(:,cStep-1) + Delta_x_t;
                end
                UnitR_tAll(:,cStep) = TanhFun(Unitx_tAll(:,cStep));

                OutDataAll(:,cStep) = w_o'*UnitR_tAll(:,cStep) + c_z_Outbias;
                if sum(isnan(OutDataAll(:,cStep)))
                    sprintf('DB stop');
                end
                    
                if ~mod(cStep,k1)
                    db_o = 0;
                    dw_o = 0;
                    dc_x = 0;
                    dloss_J = 0;
                    dloss_B = 0;
                    % performing BPTT for k2 steps
                    for ccStep = cStep :-1: cStep - k2
%                             do_t = 1 * (OutDataAll(:,cStep) - cTargetFun(:,cStep));
%                             db_o = db_o + do_t;
%                             dw_oh = dw_oh + do_t * (UnitR_tAll(:,cStep))';
%                             dh_t = dh_t + w_o * do_t;
%                             du_t = TanhDecFun(Unitx_tAll(:,cStep)) .* dh_t;
%                             dw_hv = dw_hv + du_t * (Unitx_tAll(:,cStep))';
%                             db_h = db_h + du_t;
%                             dw_hh = dw_hh + du_t * (UnitR_tAll(:,cStep-1))';
%                             dh_t = J' * du_t;
                        do_t = (OutDataAll(:,ccStep) - cTargetFun(:,ccStep));
                        if abs(do_t) > 1e-3
                            sprintf('DB stop');
                        end
                        dw_o = dw_o + (UnitR_tAll(:,ccStep))*do_t';
                        db_o = db_o + do_t;
                        d_loss_cx = do_t * w_o .* TanhDecFun(Unitx_tAll(:,ccStep))/Tau;
                        if sum(isnan(d_loss_cx))
                            sprintf('DB stop');
                        end
                        dc_x = dc_x + d_loss_cx;
                        dloss_J = dloss_J + d_loss_cx * (UnitR_tAll(:,ccStep))';
                        dloss_B = dloss_B + d_loss_cx * (cBatchData(:,ccStep))';

                    end
%                         d_sigma = {dw_hv,dw_hh,dw_oh,db_h,dbo,dh_t};

                    % update parameters
                    J = J - LearnRate * dloss_J;
                    B = B - LearnRate * dloss_B;
                    w_o = w_o - LearnRate * dw_o;
                    c_unit_bias = c_unit_bias - LearnRate * dc_x;
                    c_z_Outbias = c_z_Outbias - LearnRate * db_o;

                    if sum(isnan(w_o))
                        sprintf('DB stop');
                    end
                end
                LearnRate = LearnRate * 0.9;
                if LearnRate < 0.01
                    LearnRate = 0.2;
                end
            end    
        end
        
        % calculate batch errors
        BatchErrors = cell(BatchSize,1);
        for cBatch = 1 : BatchSize
            cBatchData = squeeze(BatchData(:,:,cBatch));
            cTargetFun = squeeze(BatchTarget(:,:,cBatch));
            cStartPos = StartPosition(cBatch);
            EndPos = cStartPos + BatchTsLen(cBatch);
            
            Unitx_tAll = zeros(RNNUnits,TimeSteps);
            UnitR_tAll = zeros(RNNUnits,TimeSteps);
            OutDataAll = zeros(OutDataSize,TimeSteps);
            [TanhFun,~] = ActFunCheck('Tanh');
            
            for cStep = 1 : TimeSteps
                if cStep == 1
                    Delta_x_t = (-x_init + J*TanhFun(x_init) + ...
                        B * (cBatchData(:,cStep)) + c_unit_bias + randn(RNNUnits,1)*0.01)/Tau;
                    Unitx_tAll(:,cStep) = x_init + Delta_x_t;
                else
                    Delta_x_t = (-Unitx_tAll(:,cStep-1) + J*UnitR_tAll(:,cStep-1) + ...
                        B * (cBatchData(:,cStep)) + c_unit_bias + randn(RNNUnits,1)*0.01)/Tau;
                    Unitx_tAll(:,cStep) = Unitx_tAll(:,cStep-1) + Delta_x_t;
                end
                UnitR_tAll(:,cStep) = TanhFun(Unitx_tAll(:,cStep));

                OutDataAll(:,cStep) = w_o'*UnitR_tAll(:,cStep) + c_z_Outbias;
            end
            
            cErro = sum((OutDataAll(:,cStartPos:EndPos) - cTargetFun(:,cStartPos:EndPos)).^2)/2;
            BatchErrors{cBatch} = cErro(:); 
        end
        cBatchError = mean(cell2mat(BatchErrors));
        fprintf('Current batch error %.6f\n',cBatchError);
        
        NetParas = {J, B, w_o, c_unit_bias, c_z_Outbias};
        varargout{1} = NetParas;
        varargout{2} = cBatchError;
        varargout{3} = LearnRate;
        
    case 'Calculation'
        % pure forward calculation
        
        
    otherwise 
        fprintf('Unknown input type.\n');        
end
        
            
        
        
            
        
        
        
        
        