classdef C_LSTM
    properties
        InputSize
        HiddenSize
        Outputsize
        TrainingSteps
        
        % parameters for single cell
        Weights_f
        Weights_i
        Weights_c
        Weights_o
        W_Softmax
        
        Bias_f
        Bias_i
        Bias_c
        Bias_o
        b_Softmax
        
        Mtx_f
        Mtx_i
        C_t
        Mtx_o
        
        H_T % hidden layer matrix
        H_T_1 % hidden layer data from former layer
        Cell_t_1 
        SM_Output % SM output layer matrix
        Output
        Input_data % input data
        Target_data % target data
        
        LossData % loss 
        OutPutDelta
        
        IsSoftMaxOut = 0;
    end
    
    methods
        function this = C_LSTM(varargin) %Input_size,Hidden_size,Output_size,Training_step
            if nargin < 4
                error('NotEnoughInputForInitiation');
            end
            
            [this.InputSize,this.HiddenSize,this.Outputsize,this.TrainingSteps] = deal(...
                varargin{1:4});
            HiddenPlusInputNum = this.InputSize + this.HiddenSize;
            
            [this.Weights_f,this.Weights_i,this.Weights_c,this.Weights_o] = deal(...
                rand(this.HiddenSize,HiddenPlusInputNum));
%                 eye(HiddenPlusInputNum,HiddenPlusInputNum,'like',this.InputSize));
             
            [this.Bias_f,this.Bias_i,this.Bias_c,this.Bias_o] = deal(ones(this.HiddenSize,1));
            
            this.W_Softmax = rand(this.Outputsize,this.HiddenSize)*0.02-0.01;
            this.b_Softmax = rand(this.Outputsize,1)*0.02-0.01;
        end
        
        function this = Forward_cal(this,Inputs,Outputs,h_t_1,c_t_1) % input data for steps
            this.Input_data = Inputs;
            this.H_T_1 = h_t_1;
            this.Target_data = Outputs;
            this.Cell_t_1 = c_t_1;
            
            [SigmFun,~] = ActFunCheck('Sigmoid');
            [TanhFun,~] = ActFunCheck('Tanh');
            [SoftMaxFun,~] = ActFunCheck('SoftMax');
            
            Input = this.Input_data(:);
            Hidden_t_1 = this.H_T_1(:);
            
            this.Mtx_f = SigmFun(this.Weights_f * [Hidden_t_1;Input] + this.Bias_f);
            this.Mtx_i = SigmFun(this.Weights_i * [Hidden_t_1;Input] + this.Bias_i);
            c_hat = TanhFun(this.Weights_c * [Hidden_t_1;Input] + this.Bias_c);
            this.C_t = this.Mtx_f .* this.Cell_t_1 + this.Mtx_i .* c_hat;
            this.Mtx_o = SigmFun(this.Weights_o * [Hidden_t_1;Input] + this.Bias_o);
            this.H_T = this.Mtx_o .* TanhFun(this.C_t);
            
            this.Output = this.W_Softmax * this.H_T + this.b_Softmax;
            if this.IsSoftMaxOut % whether using softmax output
                this.SM_Output = SoftMaxFun(this.Output);
                this.LossData = -log(this.SM_Output(logical(this.Target_data)));
            else
                this.SM_Output = SigmFun(this.Output);
                this.LossData = 0.5 * sum((this.SM_Output - this.Target_data).^2);
            end 
        end
        
        function [this,Grads,State] = Backprop_cal(this,d_next)
           [~,SigmDerivFun] = ActFunCheck('Sigmoid');
           [TanhFun,TanhDerivFun] = ActFunCheck('Tanh');
%            [SoftMaxFun,~] = ActFunCheck('SoftMax');
           
           [dh_next,dc_next] = deal(d_next{:});
           h_t_1_x = [this.H_T_1;this.Input_data];
           % back propagation errors
           if this.IsSoftMaxOut
               this.OutPutDelta = this.SM_Output;
               PosTargInds = this.Target_data > 0;
               this.OutPutDelta(PosTargInds) = this.OutPutDelta(PosTargInds) - 1;
           else
               this.OutPutDelta = (this.SM_Output - this.Target_data) .* SigmDerivFun(this.SM_Output);
           end
            
           % hidden to output gradient
           dW_softmax = (this.OutPutDelta * this.H_T');
           db_softmax = this.OutPutDelta;
           dh = this.W_Softmax' * this.OutPutDelta + dh_next;
           
           % gradient for ho
           dho = SigmDerivFun(this.Mtx_o) .* TanhFun(this.C_t) .* dh;
           
           % gradient for c
           dc = this.Mtx_o .* dh .* TanhDerivFun(this.C_t);
           dc = dc + dc_next;
           
           % gradient for hf in c = hf * c_t_1 + hi * c_t
           dhf = this.Cell_t_1 .* dc;
           dhf = SigmDerivFun(this.Mtx_f) .* dhf;
           
           % gradient for hf in c = hf * c_t_1 + hi * c_t
           dhi = this.C_t .* dc;
           dhi = SigmDerivFun(this.Mtx_i) .* dhi;
           
           % gradient for c_t
           dhc = this.Mtx_i .* dc;
           dhc = TanhDerivFun(this.C_t) .* dhc;
           
           % Gate gradient
           dwf = dhf * h_t_1_x';
           dbf = dhf;
           dxf = this.Weights_f' * dhf;
           
           dwi = dhi * h_t_1_x';
           dbi = dhi;
           dxi = this.Weights_i' * dhi;
           
           dwo = dho * h_t_1_x';
           dbo = dho;
           dxo = this.Weights_o' * dho;
           
           dwc = dhc * h_t_1_x';
           dbc = dhc;
           dxc = this.Weights_c' * dhc;
           
           % accumulate gradient for multiple gates
           dx = dxf + dxi + dxo + dxc;
           dh_next = dx(1:this.HiddenSize);
           
           % gradient for c_old
           dc_next = this.Mtx_f .* dc;
           Grads = {dwf,dwi,dwc,dwo,dW_softmax,dbf,dbi,dbc,dbo,db_softmax};
           State = {dh_next,dc_next};
           
        end
            
        function [this,varargout] = UpdateParas(this,Type,varargin)
            switch Type
                case 'SGD'
                    GradsAll = varargin{1};
                    LearnRate = varargin{2};
                    
                    [dwf,dwi,dwc,dwo,dW_softmax,dbf,dbi,dbc,dbo,db_softmax] = deal(GradsAll{:});
                    
                    this.Weights_f = this.Weights_f - dwf * LearnRate;
                    this.Weights_i = this.Weights_i - dwi * LearnRate;
                    this.Weights_c = this.Weights_c - dwc * LearnRate;
                    this.Weights_o = this.Weights_o - dwo * LearnRate;
                    this.W_Softmax = this.W_Softmax - dW_softmax * LearnRate;

                    this.Bias_f = this.Bias_f - dbf * LearnRate;
                    this.Bias_i = this.Bias_i - dbi * LearnRate;
                    this.Bias_c = this.Bias_c - dbc * LearnRate;
                    this.Bias_o = this.Bias_o - dbo * LearnRate;
                    this.b_Softmax = this.b_Softmax - db_softmax * LearnRate;
                    
                    varargout = {};
                case 'Adam'
                    GradsAll = varargin{1};
                    AdamParam = varargin{2};
                    if isempty(AdamParam)
                        AdamParam.LearnAlpha = 0.001;
                        AdamParam.Beta_1 = 0.9;
                        AdamParam.Beta_2 = 0.999;
                        AdamParam.Beta_1Updates = AdamParam.Beta_1;
                        AdamParam.Beta_2Updates = AdamParam.Beta_2;
                        AdamParam.ThresMargin = 1e-8; % to avoid zeros diveision
                        AdamParam.FirstMomentVec_W = {zeros(size(this.Weights_f)),zeros(size(this.Weights_i)),zeros(size(this.Weights_c)),...
                            zeros(size(this.Weights_o)),zeros(size(this.W_Softmax))};
                        AdamParam.FirstMomentVec_B = {zeros(size(this.Bias_f)),zeros(size(this.Bias_i)),zeros(size(this.Bias_c)),...
                            zeros(size(this.Bias_o)),zeros(size(this.b_Softmax))};
                        AdamParam.SecondMomentVec_W = {zeros(size(this.Weights_f)),zeros(size(this.Weights_i)),zeros(size(this.Weights_c)),...
                            zeros(size(this.Weights_o)),zeros(size(this.W_Softmax))};
                        AdamParam.SecondMomentVec_B = {zeros(size(this.Bias_f)),zeros(size(this.Bias_i)),zeros(size(this.Bias_c)),...
                            zeros(size(this.Bias_o)),zeros(size(this.b_Softmax))};
                        
                    end
                    
                    nUpdates = length(GradsAll)/2;
                    dWeightsAll = GradsAll(1:nUpdates);
                    dBiasAll = GradsAll((1+nUpdates):end);
                    WeightsAll = {this.Weights_f,this.Weights_i,this.Weights_c,this.Weights_o,this.W_Softmax};
                    BiasAll = {this.Bias_f,this.Bias_i,this.Bias_c,this.Bias_o,this.b_Softmax};
                    
                    for nHls = 1 : 5
                        AdamParam.FirstMomentVec_W{nHls} = AdamParam.Beta_1 * AdamParam.FirstMomentVec_W{nHls} + ...
                            (1-AdamParam.Beta_1)*dWeightsAll{nHls};
                        AdamParam.SecondMomentVec_W{nHls} = AdamParam.Beta_2 * AdamParam.SecondMomentVec_W{nHls} + ...
                            (1-AdamParam.Beta_2)*((dWeightsAll{nHls}).^2);
                        
                        AdamParam.FirstMomentVec_B{nHls} =AdamParam.Beta_1 * AdamParam.FirstMomentVec_B{nHls} + ...
                            (1-AdamParam.Beta_1)*dBiasAll{nHls};
                        AdamParam.SecondMomentVec_B{nHls} = AdamParam.Beta_2 * AdamParam.SecondMomentVec_B{nHls} + ...
                            (1-AdamParam.Beta_2)*((dBiasAll{nHls}).^2);
                        
                        m_hat_W = AdamParam.FirstMomentVec_W{nHls}/(1 - AdamParam.Beta_1Updates);
                        v_hat_W = AdamParam.SecondMomentVec_W{nHls}/(1 - AdamParam.Beta_2Updates);
                        m_hat_B = AdamParam.FirstMomentVec_B{nHls}/(1 - AdamParam.Beta_1Updates);
                        v_hat_B = AdamParam.SecondMomentVec_B{nHls}/(1 - AdamParam.Beta_2Updates);
                        
                        TempHidenW = WeightsAll{nHls} - ...
                            AdamParam.LearnAlpha.*m_hat_W./(sqrt(v_hat_W)+AdamParam.ThresMargin);
                        WeightsAll{nHls} = TempHidenW;
                        BiasAll{nHls} = BiasAll{nHls} - ...
                            AdamParam.LearnAlpha.*m_hat_B./(sqrt(v_hat_B)+AdamParam.ThresMargin);
                    end
                    
                    AdamParam.Beta_1Updates = AdamParam.Beta_1Updates * AdamParam.Beta_1;
                    AdamParam.Beta_2Updates = AdamParam.Beta_2Updates * AdamParam.Beta_2;
                    
                    [this.Weights_f,this.Weights_i,this.Weights_c,this.Weights_o,this.W_Softmax] = deal(WeightsAll{:});
                    [this.Bias_f,this.Bias_i,this.Bias_c,this.Bias_o,this.b_Softmax] = deal(BiasAll{:});
                    
                    varargout{1} = AdamParam;
                otherwise
                    error('Undefined weight updates methods.');
            end
        end
        
    end
end
            