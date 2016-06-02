%image=dir('E:\tesfig.jpg');
phi=zeros(64*64);

image=imread('E:\tesfig.jpg');
image=imresize(image,[64,64]);
phil=double(reshape(image,1,[]));

mean_phil=mean(phil,1);
mean_face=reshape(mean_phil,64,64);
image_mean=mat2gray(mean_face);
imwrite(imae_mean,'tesfig2.jpg','jpg')

