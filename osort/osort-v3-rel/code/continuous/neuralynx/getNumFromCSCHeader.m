%
% return the number after the string marked with 'key'
%
%urut/march09
function value = getNumFromCSCHeader(header, Key)
value=[];

for i=1:length(header)
    
    indFound=strfind( header{i}, Key );
    if ~isempty ( indFound )
       
        value = header{i}( indFound+length(Key): end );
        break;
    end
    
end