%cwscore.m,����÷�
function score=cwscore(vector1,vector2);
sco=vector1*vector2;
csum=sum(sco,2);
[newcsum,i]=sort(-1*csum);
[newi,j]=sort(i);
fprintf('����÷֣�\n')
score=[sco,csum,j]             
%�÷־���scoΪ�����ɷֵ÷֣�csumΪ�ۺϵ÷֣�jΪ������
