%cwprint.m
function print=cwprint(filename,a,b); 
%filenameΪ�ı��ļ��ļ�����aΪ��������(������)��bΪ��������(����ָ����)
fid=fopen(filename,'r')
vector=fscanf(fid,'%g',[a b]);
fprintf('��׼��������£�\n')
v1=cwstd(vector)
result=cwfac(v1);
cwscore(v1,result);
