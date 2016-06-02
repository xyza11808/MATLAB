function cvScroll(hObject, step, nloop, InLoopFcn, EndScrollFcn)
% cvScroll channel viewer scroll 
% 
% cvScroll(fhandle, step)
% cvScroll(hObject, step)
% scrolls the viewer for the specified figure or parent figure of the
% specified object. step is the size of the data shift in elements of the
% data array (negative to scroll back)
% 
% cvScroll(..., nloop)
% limits the number of updates to nloop iterations.
% 
% cvScroll(..., nloop, InLoopFcn, EndScrollFcn)
% specifies up to two function handles
%         InLoopFcn       will be called after each screen update
%         EndScrollFcn    will be called when the scrolling is complete
% Both functions take the form:
%                   function fcn(fhandle, [])
 


if nargin<4
    % Set empty if not declared
    InLoopFcn=[];
    EndScrollFcn=[];
end

try
    % Set flags
    dataend=false;
    datastart=false;
    % Get figure handle
    try
        % Called from callback
        fhandle=ancestor(hObject.hghandle, 'figure');
    catch
        % Called as function
        fhandle=hObject;
    end
    
    % Controls
    tf=get(findobj(fhandle, 'Tag', 'UserMessage'), 'UserData');
    v=get(findobj(fhandle, 'Tag', 'VerticalScroll'), 'UserData');
  
    current=getappdata(fhandle, 'ScrollStepSize');
    if (current==step)
        if (nargin<3)
        % May be double or multiple tap on same control - ignore it or we can end
        % up with a queue of calls to Scroll. Ignore this if nloop had been
        % defined on input
        % Where possible, avoid this condition with code in the calling function
        % to check the stack e.g. using isMultipleCall
        return
        end
    else
        setappdata(fhandle, 'ScrollStepSize', step);
    end
    
    % Get the data and line indices
    xdata=getappdata(fhandle, 'xdata');
    ydata=getappdata(fhandle, 'ydata');
    idx=getappdata(fhandle, 'LineIndices');
    % Set the offset between lines
    yrange=getappdata(fhandle, 'YRange');%abs(max(data(:,2))-min(data(:,2)));
    
    % Line handles
    lh=getappdata(fhandle, 'LineHandles');
    nl=numel(lh);
    

    v.setEnabled(false);
    % Set line update
    if step<0
        tr=nl:-1:1;
    else
        tr=1:nl;
    end
    
    if nargin<3
        nloop=size(xdata)/abs(step)+1;
    end
    
    for n=1:nloop
        % Clear the userdata property in existing lines
        set(lh, 'UserData', []);
        % Update the indices and save them
        idx(1:end-1)=idx(1:end-1)+step;
        setappdata(fhandle, 'LineIndices', idx);
        % Loop over each trace redrawing line
        for kk=1:numel(tr)
            k=tr(kk);
            try
                % Usual update
                yoffset=((k-1)*yrange);
                idx2=idx(k,1):idx(k,2);
                xl=xdata(idx2)-xdata(idx2(1));
                yl=ydata(idx2)-yoffset;
                %             fprintf('%d: %7.4f %7.4f = %7.4f || %7.4f %7.4f = %7.4f || length=%d %d %d\n',...
                %                 k, data(idx2(1),1), data(idx2(end),1), data(idx2(end),1)-data(idx2(1),1),...
                %                 xl(1), xl(end), xl(end)-xl(1), length(idx2), idx2(1), idx2(end));
                if wasInterrupted()
                    break
                end
                set(lh(k), 'XData', xl, 'YData', yl,...
                    'UserData', [k xdata(idx2(1),1) xdata(idx2(end), 1) idx2(1) idx2(end) yoffset]);
            catch
                % Check for expected and of data conditions
                if any(idx2<=0)
                    % Beyond start of data
                    idx2=idx2(idx2>0);
                    if isempty(idx2)
                        datastart=true;
                        break
                    end
                    xl=xdata(idx2);
                    yl=ydata(idx2)-yoffset;
                    XLim=get(gca, 'Xlim');
                    xoffset=XLim(2)-xl(end);
                    xl=xl+xoffset;
                    if wasInterrupted()
                        break
                    end
                    set(lh(k), 'XData', xl, 'YData', yl,...
                        'UserData', [k xdata(idx2(1),1) xdata(idx2(end),1) idx2(1) idx2(end) yoffset]);
                    if k<5
                        set(lh(1:k-1),'XData', [], 'YData', [],...
                            'UserData', []);
                    end
                    datastart=true;
                elseif any(idx2>size(xdata,1))
                    % Beyond end of data
                    idx2=idx2(idx2<size(xdata,1));
                    if isempty(idx2)
                        dataend=true;
                        break
                    end
                    xl=xdata(idx2,1)-xdata(idx2(1));
                    yl=ydata(idx2)-yoffset;
                    if wasInterrupted()
                        break
                    end
                    set(lh(k), 'XData', xl, 'YData', yl,...
                        'UserData', [k xdata(idx2(1),1) xdata(idx2(end), 1) idx2(1) idx2(end) yoffset]);
                    if k>1
                        set(lh(5:-1:k+1),'XData', [], 'YData', [],...
                            'UserData', []);
                    end
                    dataend=true;
                else
                    % Not start or end of data so should not have got here
                    error('Unexpected condition');
                end
                %             fprintf('%d: %7.4f %7.4f = %7.4f || %7.4f %7.4f = %7.4f || length=%d %d %d\n',...
                %                 k, data(idx2(1),1), data(idx2(end),1), data(idx2(end),1)-data(idx2(1),1),...
                %                 xl(1), xl(end), xl(end)-xl(1), length(idx2), idx2(1), idx2(end));
                
                % Set end of data flags as appropriate
                if (datastart && step<0) || (dataend && step>0)
                    break
                end
            end
            if ~isempty(InLoopFcn)
                InLoopFcn(fhandle, []);
            end
        end
        v.setValue(max(idx(1,1),1));
        drawnow();
        if wasInterrupted()
            break
        end
%         if (datastart) || (dataend)
            str=sprintf('Data range: %7.4f to %7.4f s',...
                xdata(max(idx(1,1),1),1),...
                xdata(min(idx(nl,2),size(xdata,1)),1));
            setappdata(fhandle, 'CurrentStartTime', xdata(max(idx(1,1),1),1));
%         else
%             str=sprintf('Data range: %7.3f to %7.3f s', data(idx(1,1),1), data(idx(nl,2),1));
%             setappdata(fhandle, 'CurrentStartTime', data(idx(1,1),1));
%         end
        setappdata(fhandle, 'CurrentStartIndex', max(idx(1,1),1));
        tf.setText(str);
        UpdateUitable(fhandle, max(idx(1,1),1), min(idx(nl,2),size(xdata,1)));
        if (datastart && step<0) || (dataend && step>0)% || kk<5
            break
        end
    end
    setappdata(fhandle, 'ScrollStepSize', 0);
                str=sprintf('Data range: %7.4f to %7.4f s',...
                xdata(max(idx(1,1),1),1),...
                xdata(min(idx(nl,2),size(xdata,1)),1));
            setappdata(fhandle, 'CurrentStartTime', xdata(max(idx(1,1),1),1));
            tf.setText(str);
    UpdateUitable(fhandle, max(idx(1,1),1), min(idx(nl,2),size(xdata,1)));
    v.setEnabled(true);
    if ~isempty(EndScrollFcn)
        EndScrollFcn(fhandle, []);
    end
catch
    if ~ishandle(fhandle)
        % User has closed figure
        return
    end
    tf.setText('Scroll encountered an error');
    v.setEnabled(true);
    rethrow(lasterror());
end


    function flag=wasInterrupted()
        % Have we returned from a subsequent call to scroll?
        % Set flag true if so
        ScrollStepSize=getappdata(fhandle, 'ScrollStepSize');
        if ScrollStepSize~=step
            flag=true;
        else
            flag=false;
        end
        return
    end

return
end



