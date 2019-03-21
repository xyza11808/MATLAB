
clear
clc
[X,T] = simpleclass_dataset;
xData = X;
yData = T;

%%
num_examples = size(xData,2);
Out_dim = size(yData,1);
IterMax = 1000;

BatchSize = 100;
alpha = 0.001;

input_dim = size(xData,1);
layer1Dim = 128;
layer2Dim = 64;

[ActFun, DerivFun] = ActFunCheck('Sigmoid');
layer1 = DNI(input_dim, layer1Dim, ActFun, DerivFun, alpha);
layer2 = DNI(layer1Dim, layer2Dim, ActFun, DerivFun, alpha);
layer3 = DNI(layer2Dim, Out_dim, ActFun, DerivFun, alpha);
ErrorRecord = [];
k = 1;
for cIter = 1 : IterMax
    error = 0;
    
    for batch_index = 1 : num_examples/BatchSize
        batch_x = xData(:,((batch_index-1)*BatchSize+1):(batch_index*BatchSize));
        batch_y = yData(:,((batch_index-1)*BatchSize+1):(batch_index*BatchSize));
        
        [layer1,~, layer1Out] = layer1.forward_and_synthetic_update(batch_x);
        [layer2,layer1_delta,layer2Out] = layer2.forward_and_synthetic_update(layer1Out);
        [layer3,layer2_delta,layer3Out] = layer3.forward_and_synthetic_update(layer2Out);
        
        layer3_delta = layer3Out - batch_y;
        layer3.update_synthetic_weights(layer3_delta');
        layer2.update_synthetic_weights(layer2_delta');
        layer1.update_synthetic_weights(layer1_delta');
        
        error = error + mean(sum(abs(layer3_delta .* layer3Out .* (1 - layer3Out))));
        
        ErrorRecord(k+1) = error;
        k = k + 1;
        if error < 0.01
            break;
        end
        
        if mod(k,10) == 0
            fprintf('Error = %.6f, Iteration = %d.\n',error,cIter);
        end
    end
end


        