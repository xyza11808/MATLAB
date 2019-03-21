classdef DNI
    properties
        % Input properties
        InputDim  % size from former layer
        OutputDim % size from latter layer
        ActiFun % activation function
        ActDerivFun % Derivative Function
        LearnRate % learning rate
        
        % communication properties
        Weights
        Nonlin
        Nonlin_deriv
        alpha
        Input_data
        Output_data
        
        Weights_synthetic_grads
        Weight_synthetic_grads
        
        synthetic_grad
        synthetic_gradient_delta
    end
    
    methods
        function this = DNI(varargin)
            if nargin < 4
                error('NotEnoughInput');
            elseif nargin == 4
                [this.InputDim,this.OutputDim,this.ActiFun,this.ActDerivFun] = deal(varargin{:});
                this.LearnRate = 0.001;
            else
                [this.InputDim,this.OutputDim,this.ActiFun,...
                    this.ActDerivFun,this.LearnRate] = deal(varargin{1:5});
            end
            
            this.Weights = rand(this.InputDim,this.OutputDim)*0.02-0.01;
            this.Weights_synthetic_grads = rand(this.OutputDim,this.OutputDim)*0.02-0.01;
            this.Nonlin = this.ActiFun;
            this.Nonlin_deriv = this.ActDerivFun;
            this.alpha = this.LearnRate;
        end
        
        function [this,LayerDelta,LayerOut] = forward_and_synthetic_update(this,input)
            this.Input_data = input;
            this.Output_data = this.ActiFun(this.Input_data' * this.Weights);
            
            this.synthetic_grad = this.Output_data * this.Weights_synthetic_grads;
            this.Weight_synthetic_grads = this.synthetic_grad .* this.ActDerivFun(this.Output_data);
            this.Weights = this.Weights + this.Input_data * this.Weight_synthetic_grads * this.alpha;
            
            LayerDelta = (this.Weight_synthetic_grads * this.Weights')';
            LayerOut = this.Output_data';
            
        end
        
        function this = update_synthetic_weights(this,true_gradient)
            this.synthetic_gradient_delta = this.synthetic_grad - true_gradient;
            this.Weights_synthetic_grads = this.Weights_synthetic_grads + ...
                this.Output_data' * this.synthetic_gradient_delta * this.alpha;
        end
    end
end
            
            