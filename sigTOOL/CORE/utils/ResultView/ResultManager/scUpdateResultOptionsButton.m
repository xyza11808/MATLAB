function scUpdateResultOptionsButton(rhandle, fcn)


result=getappdata(rhandle, 'sigTOOLResultData');


h=findobj(rhandle, 'Tag', 'ResultOptionsButton');
h=get(h,'UserData');
if ~isempty(h)
    if nargin<2 || isempty(fcn)
        % No function specified on input for plotsyle, use the one in the
        % result. 
        try
            CallBack=result.plotstyle{1}();
        catch
            % Not all functions currently provide an output
            CallBack=[];
        end
    else
        % Function specified on input
        try
            CallBack=fcn();
        catch %#ok<CTCH>
            % Failed. Do we have a custom object?
            if strcmpi(func2str(result.plotstyle{1}), 'plot')==1
                try
                    % Has plotoptions been defined for it?
                    CallBack=plotoptions(result.data{2,2});
                catch
                    % No
                    CallBack=[];
                end
            else
                % but again, not all functions currently provide support for
                % this
                CallBack=[];
            end
        end
    end
    
    % Update the button in the sigTOOL Result Manager
    if ~isempty(CallBack);
        h.setEnabled(true);
        h.MouseClickedCallback=CallBack;
    else
        h.setEnabled(false);
        h.MouseClickedCallback=[];
    end
end

return
end

