%cwscore.m,计算得分
function score=cwscore(vector1,vector2);
sco=vector1*vector2;
csum=sum(sco,2);
[newcsum,i]=sort(-1*csum);
[newi,j]=sort(i);
fprintf('计算得分：\n')
score=[sco,csum,j]             
%得分矩阵：sco为各主成分得分；csum为综合得分；j为排序结果
