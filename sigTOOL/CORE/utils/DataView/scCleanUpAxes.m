function scCleanUpAxes(ah)


% Delete text
h=findobj(ah,'Type', 'hggroup', 'Tag', 'sigTOOL:MarkerValue');
delete(h);


 
return
end

% %-------------------------------------------------------------------------
% % Delete lines
% h=findobj(ah,'Type','line');
% %Exclude cursors
% h2=findobj(ah,'Tag','Cursor');
% h=setdiff(h,h2);
% delete(h);
% 
% % Delete text
% h=findobj(ah,'Type','text');
% h=setdiff(h,h2);
% delete(h); 
% return
% end