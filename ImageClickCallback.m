function ImageClickCallback ( objectHandle , eventData )
axesHandle  = get(objectHandle,'Parent');
coordinates = get(axesHandle,'CurrentPoint'); 
coordinates = coordinates(1,1:2);
message     = sprintf('x: %.1f , y: %.1f',coordinates (1) ,coordinates (2));
helpdlg(message);
end