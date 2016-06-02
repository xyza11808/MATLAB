function scViewImageData()
% scViewImageData draws and image associated with a sigTOOL marker 
% 
% scViewImageData is called by scMarkerButtonDownFcn when a marker is
% selected with the mouse in the sigTOOL data view.
[button handle]=gcbo;


h=findobj(allchild(0),'Tag','Video Frame Viewer');
if isempty(h)
    h=figure('Tag','Video Frame Viewer');
end
figure(h(1));

% index contains the channel number and frame number in a 2 element vector
index=getappdata(button,'Data');
% get the channel data
channels=getappdata(handle,'channels');
% find the final index
nd=length(size(channels{index(1)}.adc));
% get the indices for the data
ix=repmat({':'},1,nd);
ix{nd}=index(2);
% get the data associated with this channel and marker
% cast back to disc class as adcarray will always cast to double
im=cast(channels{index(1)}.adc(ix{:}),channels{index(1)}.adc.Map.Format{1});
% draw the data
image(im);
set(h(1),'Name', sprintf('Frame %d', index(2)));
return
end
