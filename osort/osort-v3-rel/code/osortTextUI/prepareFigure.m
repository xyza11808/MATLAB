%
%
%pos==1:upper half
%     2:lower half
%
function prepareFigure(nr,pos)

get(0,'screensize'); 
w=ans(3); 
h=ans(4);

x=ceil(w/2)+5; 
y=ceil(h/2)+2; 
ww=x-8; 
wh=y-76;

if pos==1
    screen = [0 , y, 2*ww,   wh]; 
end
if pos==2
    screen = [0 , 0, 2*ww,   wh];
end

figure(nr);
set(gcf, 'position',screen);

set(gcf,'paperorientation','landscape');
set(gcf,'paperunits','centimeters');