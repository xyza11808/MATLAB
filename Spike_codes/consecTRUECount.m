function ConsecVec = consecTRUECount(Vecs)
a0 = double(Vecs(:)); % input vector
ii = strfind(a0',[1 0]);
if isempty(ii)
    warning('There is no change of logical values within current vector');
    return;
end
a1 = cumsum(a0);
i1 = a1(ii);
if length(i1) == 1
    a0(ii+1) = -i1(1);
else
    a0(ii+1) = -[i1(1);diff(i1)];
end
ConsecVec = cumsum(a0); % output vector
