
t = fitgeotrans(mpNew,fpNew,'projective');
Rfixed = imref2d(size(Im2Reads));
registered = imwarp(Im1Reads,t,'OutputView',Rfixed);
imshowpair(Im2Reads,registered,'blend')

%%
a = rand(5,4,3);
writeNPY(a, 'a.npy');
b = readNPY('a.npy');