%cwstd.m,用总和标准化法标准化矩阵
function std=cwstd(vector)
cwsum=sum(vector,1);         %对列求和
[a,b]=size(vector);          %矩阵大小,a为行数,b为列数
for i=1:a
    for j=1:b
        std(i,j)= vector(i,j)/cwsum(j);
    end
end
