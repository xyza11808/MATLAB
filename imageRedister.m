Hhisto = imread('H:\images.PNG');
AllenMap = imread('H:\AllenMap.PNG');

%%
[mpNew,fpNew] = cpselect(Hhisto,AllenMap,'Wait',true);

%%
t = fitgeotrans(mpNew,fpNew,'projective');
Rfixed = imref2d(size(AllenMap));
registered = imwarp(Hhisto,t,'OutputView',Rfixed);
imshowpair(AllenMap,registered,'blend')
%%
[mpNew2,fpNew2] = cpselect(Hhisto,AllenMap,mpNew,fpNew,'Wait',true);

%%
t = fitgeotrans(mpNew2,fpNew2,'projective');
Rfixed = imref2d(size(AllenMap));
registered = imwarp(Hhisto,t,'OutputView',Rfixed);
imshowpair(AllenMap,registered,'blend')

%%
a = rand(5,4,3);
writeNPY(a, 'a.npy');
b = readNPY('a.npy');