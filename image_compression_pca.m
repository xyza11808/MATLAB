function image_compression_pca

clear;
clc; 
  
% Start of PCA code, 
Data = imread('/home/ammar/Desktop/PCA/Ammar3.png');    
Data_gray = rgb2gray(Data);       
Data_grayD = im2double(Data_gray);     
figure, 
set(gcf,'numbertitle','off','name','Grayscale Image'),  
imshow(Data_grayD)          
Data_mean = mean(Data_grayD);      
[a b] = size(Data_gray); 
Data_meanNew = repmat(Data_mean,a,1); 
DataAdjust = Data_grayD ¨C Data_meanNew; 
cov_data = cov(DataAdjust);   
[V, D] = eig(cov_data); 
V_trans = transpose(V); 
DataAdjust_trans = transpose(DataAdjust);  
FinalData = V_trans * DataAdjust_trans;   
% End of PCA code 
  
% Start of Inverse PCA code, 
OriginalData_trans = inv(V_trans) * FinalData;                         
OriginalData = transpose(OriginalData_trans) + Data_meanNew;           
figure, 
set(gcf,'numbertitle','off','name','RecoveredImage'), 
imshow(OriginalData)       
% End of Inverse PCA code 
  
% Image compression 
PCs=input('Enter number of PC colomuns needed?  ');                    
PCs = b - PCs;                                                         
Reduced_V = V;                                                         
for i = 1:PCs,                                                         
Reduced_V(:,1) =[]; 
end 
Y=Reduced_V'* DataAdjust_trans;                                        
Compressed_Data=Reduced_V*Y;                                           
Compressed_Data = Compressed_Data' + Data_meanNew;                     
figure,                                                                
set(gcf,'numbertitle','off','name','Compressed Image'),  
imshow(Compressed_Data) 
% End of image compression