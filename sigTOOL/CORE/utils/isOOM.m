function flag=isOOM()
% isOOM returns true if the last error was an Out of Memory error
% 
% Example:
% flag=isOOM();
% returns true if the last error was an Out of Memory error (false
% otherwise)
%
% isOOM is usually used in a catch block.

flag=false;
m=lasterror();
if strcmp(m.identifier, 'MATLAB:nomem') ||...
        strcmp(m.identifier, 'MATLAB:memmapfile:mapfile:cannotMap');
    flag=true;
end
return
end
