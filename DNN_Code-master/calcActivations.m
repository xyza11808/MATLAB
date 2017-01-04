function [yi,store]=calcActivations(in,W,b,layertypes,varargin)

        yi = in;
        store = [];
        
        if ~isempty(varargin)
            startLayer = varargin{1};
        else
            startLayer = 1;
        end
        
    for i = startLayer:length(layertypes)
        xi = W{i}*yi + repmat(b{i}, 1, size(in,2));

        if strcmp(layertypes{i}, 'logistic')
            yi = 1./(1 + exp(-xi));
        elseif strcmp(layertypes{i}, 'tanh')
            yi = tanh(xi);
        elseif strcmp(layertypes{i}, 'linear')
            yi = xi;
        elseif strcmp(layertypes{i}, 'linearSTORE')
            yi = xi;
            store = yi;
        elseif strcmp(layertypes{i}, 'softmax' )
            tmp = exp(xi);
            yi = tmp./repmat( sum(tmp), [layersizes(i+1) 1] );   
            tmp = [];
        end
    end