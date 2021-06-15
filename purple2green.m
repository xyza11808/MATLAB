function Outb2r = purple2green(n, whiteness)

if nargin < 1
    n = 64;
    whiteness = 1; % Pure white
elseif nargin <2
    whiteness = 1; % Pure white
end
% TypeNum = ceil(n/2);
if mod(n,2)
    TypeNum = ceil(n/2);
else
    TypeNum = 1+(n/2);
end

b2w = [linspace(0,whiteness,TypeNum)' linspace(1,whiteness,TypeNum)' linspace(0.1,whiteness,TypeNum)'];
w2r = [linspace(whiteness,0.9,TypeNum)' linspace(whiteness,0.5,TypeNum)' linspace(whiteness,0,TypeNum)'];

b2r = [b2w; w2r];
if mod(n,2)
   Outb2r = b2r;
   Outb2r(TypeNum+1,:) = [];
else
    UsedInds = [1:n/2,TypeNum*2-n/2+1:TypeNum*2];
    Outb2r = b2r(UsedInds,:);
end