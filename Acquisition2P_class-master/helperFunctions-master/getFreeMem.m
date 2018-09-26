function [free, in_use, largest_block] = getFreeMem
%[free, in_use, largest_block] = getFreeMem grabs the memory usage from the
%feature('memstats') function and returns the free, in-us and largest
%contiguous block of memory. It is faster than the function MEMORY.

memtmp = regexp(evalc('feature(''memstats'')'),'(\w*) MB','match'); 
memtmp = sscanf([memtmp{:}],'%f MB');
in_use = memtmp(1);
free = memtmp(2);
largest_block = memtmp(10);
end