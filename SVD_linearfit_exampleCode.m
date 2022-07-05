% Fake n-points in R3, n=4 in your case
n = 10;
a = randn(3,1);
b = randn(3,1);
t = rand(1,10);
xyz = a + b.*t;
xyz = xyz + 0.05*randn(size(xyz)); % size 3 x n
%% Engine  
xyz0 = mean(xyz,2);
A = xyz-xyz0;
[U,S,~] = svd(A);
d = U(:,1);
t = d'*A;
t1 = min(t);
t2 = max(t);
xzyl = xyz0 + [t1,t2].*d; % size 3x2
% Check
x = xyz(1,:);
y = xyz(2,:);
z = xyz(3,:);
xl = xzyl(1,:);
yl = xzyl(2,:);
zl = xzyl(3,:);
figure;
hold on
plot3(x,y,z,'o');
plot3(xl,yl,zl,'r');
axis equal
