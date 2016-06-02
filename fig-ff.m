clear;
clc;
ima=imread('E:\ttt1.png');
 imaf=fft(ima);
 imwrite(imaf,'E:\ttt2.png')