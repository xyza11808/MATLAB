%cwstd.m,���ܺͱ�׼������׼������
function std=cwstd(vector)
cwsum=sum(vector,1);         %�������
[a,b]=size(vector);          %�����С,aΪ����,bΪ����
for i=1:a
    for j=1:b
        std(i,j)= vector(i,j)/cwsum(j);
    end
end
