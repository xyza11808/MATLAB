%cwfac.m
function result=cwfac(vector);
fprintf('���ϵ������:\n')
std=corrcoef(vector)    %�������ϵ������
fprintf('��������(vec)������ֵ(val)��\n')
[vec,val]=eig(std)    %������ֵ(val)����������(vec)
newval=diag(val) ;
[y,i]=sort(newval) ;      %����������������yΪ��������iΪ����
fprintf('����������\n')
for z=1:length(y)
    newy(z)=y(length(y)+1-z);
end
fprintf('%g\n',newy)
rate=y/sum(y);
fprintf('\n�����ʣ�\n')
newrate=newy/sum(newy)
%cwfac.m
function result=cwfac(vector);
fprintf('���ϵ������:\n')
std=corrcoef(vector)    %�������ϵ������
fprintf('��������(vec)������ֵ(val)��\n')
[vec,val]=eig(std)    %������ֵ(val)����������(vec)
newval=diag(val) ;
[y,i]=sort(newval) ;      %����������������yΪ��������iΪ����
fprintf('����������\n')
for z=1:length(y)
    newy(z)=y(length(y)+1-z);
end
fprintf('%g\n',newy)
rate=y/sum(y);
fprintf('\n�����ʣ�\n')
newrate=newy/sum(newy)
