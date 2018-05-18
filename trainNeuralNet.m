function [errorValue delta_V delta_W] = trainNeuralNet(Input, Output, V, W, delta_V, delta_W)

%Function for calculation (steps 4 - 16)

%To train the Neural Network

%Calculating the Output of Input Layer

%No computation here.

%Output of Input Layer is same as the Input of Input  Layer

Output_of_InputLayer = Input;

%Calculating Input of the Hidden Layer

%Here we need to multiply the Output of the Input Layer with the -

%synaptic weight. That weight is in the matrix V.

Input_of_HiddenLayer = V' * Output_of_InputLayer;

%Calculate the size of Input to Hidden Layer

[m,n] = size(Input_of_HiddenLayer);

%Now, we have to calculate the Output of the Hidden Layer

%For that, we need to use Sigmoidal Function

Output_of_HiddenLayer = 1./(1+exp(-Input_of_HiddenLayer));

%Calculating Input to Output Layer

%Here we need to multiply the Output of the Hidden Layer with the -

%synaptic weight. That weight is in the matrix W

Input_of_OutputLayer = W'*Output_of_HiddenLayer;

%Clear varables

clear m n;

%Calculate the size of Input of Output Layer

[m,n] = size(Input_of_OutputLayer);

%Now, we have to calculate the Output of the Output Layer

%For that, we need to use Sigmoidal Function

Output_of_OutputLayer = 1./(1+exp(-Input_of_OutputLayer));

%Now we need to calculate the Error using Root Mean Square method

difference = Output - Output_of_OutputLayer;

square = difference.*difference;

errorValue = sqrt(sum(square(:)));

%Calculate the matrix 'd' with respect to the desired output

%Clear the variable m and n

clear m n

[n a] = size(Output);

for i = 1 : n
    
    for j = 1 : a
        
        d(i,j) =(Output(i,j)-Output_of_OutputLayer(i,j))*Output_of_OutputLayer(i,j)*(1-Output_of_OutputLayer(i,j));
        
    end
    
end

%Now, calculate the Y matrix

Y = Output_of_HiddenLayer * d'; %STEP 11

%Checking number of arguments. We are using function overloading

%On the first iteration, we don't have delta V and delta W

%So we have to initialize with zero. The size of delta V and delta W will

%be same as that of V and W matrix respectively (nargin - no of arguments)

if nargin == 4
    
    delta_W=zeros(size(W));
    
    delta_V=zeros(size(V));
    
end

%Initializing eetta with 0.6 and alpha with 1

etta=0.6;alpha=1;

%Calculating delta W

delta_W= alpha.*delta_W + etta.*Y;%STEP 12

%STEP 13

%Calculating error matrix

error = W*d;

%Calculating d*

clear m n

[m n] = size(error);

for i = 1 : m
    
    for j = 1 :n
        
        d_star(i,j)= error(i,j)*Output_of_HiddenLayer(i,j)*(1-Output_of_HiddenLayer(i,j));
        
    end
    
end

%Now find matrix, X (Input * transpose of d_star)

X = Input * d_star';

%STEP 14

%Calculating delta V

delta_V=alpha*delta_V+etta*X;

end