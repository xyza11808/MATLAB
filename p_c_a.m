function p_c_a(mx);
%初始化操作
   %对输入的矩阵按照相关系数矩阵方法进行降维操作
cwsum=sum(mx,2);         %对列求和
[a,b]=size(mx);          %矩阵大小,a为行数,b为列数

% mean_mx=mean(mx,2);
% mx=mx-repmat(mean_mx,1,b); %对矩阵进行去均值话操作

for i=1:a
    for j=1:b
        std(i,j)= mx(i,j)/cwsum(j);  %按照每一行的顺序进行标准化操作
    end
end
coeff_give=corrcoef(std);  %相关系数矩阵求解
[vect,lamda]=eig(coeff_give);
%disp(vect)

lamda=diag(lamda);
[sort_lamda,list]=sort(lamda,'descend');
     %特征向量筛选完成
     %下面选取总贡献量超过90%的主成分
 rate=sort_lamda/sum(sort_lamda);
 sumrate=0;
 for k=length(sort_lamda):-1:1
    sumrate=sumrate+rate(length(sort_lamda)+1-k);
    new_list(length(sort_lamda)+1-k)=list(length(sort_lamda)+1-k);
    if sumrate>0.9 break;
    end  
end 
fprintf('主成分数：%g\n\n',length(new_list));

%计算载荷，这里我也不懂。。。反正影响不大～～～
fprintf('主成分载荷：\n')
pc_number=length(new_list);
for p=1:pc_number
    for q=1:length(sort_lamda)
        result(q,p)=sqrt(lamda(new_list(p)))*vect(q,new_list(p));
    end
end                    %计算载荷
disp(result)
fprintf('pc_number is: %d \n',pc_number)

project_m=[];
%筛选被选中的主成分，并且提取出对应的特征向量
for i=1:pc_number
    v=vect(:,new_list(i));
    project_m=cat(2,project_m,v);
end   
 fprintf('投影空间矩阵为：\n')
% project_m

%计算降维后的结果

p_c_a_m=mx*project_m

 %2-D做图
 if pc_number==2
    figure;
    i=1:a; 
    plot(p_c_a_m(i,1),p_c_a_m(i,2));
    title('Line in 2-D Space');
    xlabel('PC1');ylabel('PC2'); 
    hold on;
 end  
 
 
%3-D做图
if pc_number==3
figure;
 i=1:a;
  plot3(p_c_a_m(i,1),p_c_a_m(i,2),p_c_a_m(i,3));
  grid on;
  hold on;
  title('Line in 3-D Space');
xlabel('PC1');ylabel('PC2');zlabel('PC3');
end

%高维做图.
if pc_number>3
fprintf('higher dimension is unproprietable for plot. \n')
end

fprintf('the lower dimention matrix is: \n')
disp(p_c_a_m)
