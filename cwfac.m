%cwfac.m
function result=cwfac(vector);
fprintf('相关系数矩阵:\n')
std=corrcoef(vector)    %计算相关系数矩阵
fprintf('特征向量(vec)及特征值(val)：\n')
[vec,val]=eig(std)    %求特征值(val)及特征向量(vec)
newval=diag(val) ;
[y,i]=sort(newval) ;      %对特征根进行排序，y为排序结果，i为索引
fprintf('特征根排序：\n')
for z=1:length(y)
    newy(z)=y(length(y)+1-z);
end
fprintf('%g\n',newy)
rate=y/sum(y);
fprintf('\n贡献率：\n')
newrate=newy/sum(newy)
%cwfac.m
function result=cwfac(vector);
fprintf('相关系数矩阵:\n')
std=corrcoef(vector)    %计算相关系数矩阵
fprintf('特征向量(vec)及特征值(val)：\n')
[vec,val]=eig(std)    %求特征值(val)及特征向量(vec)
newval=diag(val) ;
[y,i]=sort(newval) ;      %对特征根进行排序，y为排序结果，i为索引
fprintf('特征根排序：\n')
for z=1:length(y)
    newy(z)=y(length(y)+1-z);
end
fprintf('%g\n',newy)
rate=y/sum(y);
fprintf('\n贡献率：\n')
newrate=newy/sum(newy)
