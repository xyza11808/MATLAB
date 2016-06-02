function p_c_a(mx);
%��ʼ������
   %������ľ��������ϵ�����󷽷����н�ά����
cwsum=sum(mx,2);         %�������
[a,b]=size(mx);          %�����С,aΪ����,bΪ����

% mean_mx=mean(mx,2);
% mx=mx-repmat(mean_mx,1,b); %�Ծ������ȥ��ֵ������

for i=1:a
    for j=1:b
        std(i,j)= mx(i,j)/cwsum(j);  %����ÿһ�е�˳����б�׼������
    end
end
coeff_give=corrcoef(std);  %���ϵ���������
[vect,lamda]=eig(coeff_give);
%disp(vect)

lamda=diag(lamda);
[sort_lamda,list]=sort(lamda,'descend');
     %��������ɸѡ���
     %����ѡȡ�ܹ���������90%�����ɷ�
 rate=sort_lamda/sum(sort_lamda);
 sumrate=0;
 for k=length(sort_lamda):-1:1
    sumrate=sumrate+rate(length(sort_lamda)+1-k);
    new_list(length(sort_lamda)+1-k)=list(length(sort_lamda)+1-k);
    if sumrate>0.9 break;
    end  
end 
fprintf('���ɷ�����%g\n\n',length(new_list));

%�����غɣ�������Ҳ��������������Ӱ�첻�󡫡���
fprintf('���ɷ��غɣ�\n')
pc_number=length(new_list);
for p=1:pc_number
    for q=1:length(sort_lamda)
        result(q,p)=sqrt(lamda(new_list(p)))*vect(q,new_list(p));
    end
end                    %�����غ�
disp(result)
fprintf('pc_number is: %d \n',pc_number)

project_m=[];
%ɸѡ��ѡ�е����ɷ֣�������ȡ����Ӧ����������
for i=1:pc_number
    v=vect(:,new_list(i));
    project_m=cat(2,project_m,v);
end   
 fprintf('ͶӰ�ռ����Ϊ��\n')
% project_m

%���㽵ά��Ľ��

p_c_a_m=mx*project_m

 %2-D��ͼ
 if pc_number==2
    figure;
    i=1:a; 
    plot(p_c_a_m(i,1),p_c_a_m(i,2));
    title('Line in 2-D Space');
    xlabel('PC1');ylabel('PC2'); 
    hold on;
 end  
 
 
%3-D��ͼ
if pc_number==3
figure;
 i=1:a;
  plot3(p_c_a_m(i,1),p_c_a_m(i,2),p_c_a_m(i,3));
  grid on;
  hold on;
  title('Line in 3-D Space');
xlabel('PC1');ylabel('PC2');zlabel('PC3');
end

%��ά��ͼ.
if pc_number>3
fprintf('higher dimension is unproprietable for plot. \n')
end

fprintf('the lower dimention matrix is: \n')
disp(p_c_a_m)
