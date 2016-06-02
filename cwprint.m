%cwprint.m
function print=cwprint(filename,a,b); 
%filename为文本文件文件名，a为矩阵行数(样本数)，b为矩阵列数(变量指标数)
fid=fopen(filename,'r')
vector=fscanf(fid,'%g',[a b]);
fprintf('标准化结果如下：\n')
v1=cwstd(vector)
result=cwfac(v1);
cwscore(v1,result);
