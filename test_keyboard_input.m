function test_keyboard_input

Phase=0;
x=1:0.01:10;
y=sin(2*pi*x + Phase);
h=figure;
plot(x,y);
% set(f,'KeyPressFcn',@(phase));
% guidata(f);
while true
kb_input=get(gcf,'CurrentCharacter');
switch kb_input
    case 'rightarrow'
        Phase = Phase + pi*0.01;
        set(h,'YData',sin(2*pi*x + Phase));
%         plot(x,y)
    case 'leftarrow'
        Phase = Phase - pi*0.01;
        if Phase < 0
            Phase = 0;
        end
        set(h,'YData',sin(2*pi*x + Phase));
%         disp(num2str(Phase));
%         y=sin(2*pi*x + Phase);
%         plot(x,y)
    case 'q'
        close(gcf);
        break;
    otherwise
end
% refreshdata(h,'caller') 
pause(0.01);
end