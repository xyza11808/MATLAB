function ViewerKeyPFun(src,events)
% this function will be used for figure key press function processing
fprintf('Currently pressed key was %s.\n',events.Key);
hGUIData = guidata(src);
if strcmpi(events.Key,'rightarrow')
    SessUsedInds = 1;
elseif strcmpi(events.Key,'leftarrow')
    SessUsedInds = 0;
else
    % no significant inds
    SessUsedInds = 2;
end
hGUIData.Output = SessUsedInds;
guidata(src, hGUIData);
