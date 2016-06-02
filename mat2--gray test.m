i=gpuarray(imread('E:\tesfig.jpg'));
j=filter2(fspecial('sobel'),i);
k=mat2gray(j);
figure,imshow(i),figure,imshow(k)