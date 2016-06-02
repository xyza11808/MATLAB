function platform=getPlatform()
% find platform OS - code from TMW ver
if ispc
   platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
elseif ismac
    [fail, input] = unix('sw_vers');
    if ~fail
        platform = strrep(input, 'ProductName:', '');
        platform = strrep(platform, sprintf('\t'), '');
        platform = strrep(platform, sprintf('\n'), ' ');
        platform = strrep(platform, 'ProductVersion:', ' Version: ');
        platform = strrep(platform, 'BuildVersion:', 'Build: ');
    else
        platform = system_dependent('getos');
    end
else    
   platform = system_dependent('getos');
end
return
end