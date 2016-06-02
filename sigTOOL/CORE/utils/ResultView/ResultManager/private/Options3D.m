function tp=Options3D(tp)
Foreground=java.awt.Color(64/255,64/255,122/255);
Background=java.awt.Color(1,1,0.9);

p=uipanel('Parent', tp.Panel.uipanel,...
    'Units', 'normalized',...
    'Position',[0.05 0.62 0.85 0.1375]);

tp.Options3D.Panel=jcontrol(p, 'javax.swing.JPanel',...
    'Units', 'normalized',...
    'Position',[0 0 1 1],...
    'Foreground', Foreground,...
    'Background', Background,...
    'Border',javax.swing.BorderFactory.createTitledBorder('3D Options'));

tp.Options3D.mesh=jcontrol(tp.Options3D.Panel, 'javax.swing.JComboBox',...
    'Position',[0.1 0.475 0.8 0.175],...
    'Foreground', Foreground,...
    'Background', Background);
addLabel(tp.Options3D.mesh, 'Mesh Style');
tp.Options3D.mesh.addItem('both');
tp.Options3D.mesh.addItem('row');
tp.Options3D.mesh.addItem('column');
tp.Options3D.mesh.ActionPerformedCallback=@MeshStyleCallback;

tp.Options3D.colorbar=jcontrol(tp.Options3D.Panel, 'javax.swing.JCheckBox',...
    'Position',[0.1 0.2 0.8 0.175],...
    'Text','Show ColorBar',...
    'Foreground', Foreground,...
    'Background', Background);
fhandle=ancestor(tp.Panel,'figure');
h=findobj(fhandle,'Tag','Colorbar');
if isempty(h)
    tp.Options3D.colorbar.setSelected(0);
else
    tp.Options3D.colorbar.setSelected(1);
end
tp.Options3D.colorbar.ActionPerformedCallback=@ColorbarCallback;

return
end

function MeshStyleCallback(hObject, EventData)
fhandle=ancestor(handle(hObject.hghandle),'figure');
h=findobj(fhandle, 'Type', 'surface');
set(h, 'MeshStyle', char(hObject.getSelectedItem()));
return
end

function ColorbarCallback(hObject, EventData)
fhandle=ancestor(handle(hObject.hghandle),'figure');
TF=hObject.isSelected();
switch TF
    case 0
        h=findobj(fhandle,'Tag','Colorbar');
        for k=1:length(h)
            try
                colorbar(h(k),'delete');
            catch
                delete(h(k));
            end
        end
    case 1
        result=getappdata(fhandle,'sigTOOLResultData');
        h=findobj(fhandle, 'Type', 'axes');
        for k=1:length(h)
        hc=colorbar('Peer', h(k), 'Location', 'EastOutside');
        subs=getappdata(h(k),'AxesSubscript');
        if isempty(subs)
            set(hc, 'Visible','off');
            continue
        end
        ht=get(hc,'Title');
        data=result.data{subs(1), subs(2)};
        set(ht, 'String', data.rlabel);
        pos=get(ht, 'Position');
        mn=min(min(data.rdata));
        mx=max(max(data.rdata));
        if mn>=0
            csc=[0 mx];
        elseif mn<0 && mx<0
            csc=[mn 0];
        else
            csc=max(abs([mn,mx]));
            csc=[-csc csc]; %#ok<AGROW>
        end
        set(h(k), 'CLimMode', 'manual',...
             'Clim', csc);
        set(ht, 'Rotation', 90,...
            'Position', [-1 mean(csc) pos(3)]);
        end
end

return
end

