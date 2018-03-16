function Outb2r = blue2red_2(n, whiteness)
% Generate a colormap with red to white to blue color range
% With the middle color to be white or gray, depending on the input value whiteness
% E.g., if whiteness = 0.8, the middle color would be light gray.
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

% b2w = [linspace(0,1,n); linspace(0,1,n); linspace(1,1,n)];
% w2r = [linspace(1,1,n); linspace(1,0,n); linspace(0.2,0,n)];
% rwb = [linspace(0.2,1,n)' linspace(0.1,1,n)' linspace(1,1,n)'; ...
%     linspace(1,1,n)' linspace(1,.3,n)' linspace(1,0.3,n)'];

b2w = [linspace(0.1,whiteness,TypeNum)' linspace(0.1,whiteness,TypeNum)' linspace(1,whiteness,TypeNum)'];
w2r = [linspace(whiteness,1,TypeNum)' linspace(whiteness,0.1,TypeNum)' linspace(whiteness,0,TypeNum)'];

b2r = [b2w; w2r];
if mod(n,2)
   Outb2r = b2r;
   Outb2r(TypeNum+1,:) = [];
else
    UsedInds = [1:n/2,TypeNum*2-n/2+1:TypeNum*2];
    Outb2r = b2r(UsedInds,:);
end
