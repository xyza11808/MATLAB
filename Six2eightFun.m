function NewMtx = Six2eightFun(InputMtx)
if size(InputMtx,2) == 8
    NewMtx = InputMtx;
else
    if islogical(InputMtx)
        NewMtx = false(size(InputMtx,1),8);
        NewMtx(1:3) = InputMtx(1:3);
        NewMtx(6:8) = InputMtx(4:6);
    else
        NewMtx = zeros(size(InputMtx,1),8);
        NewMtx(1:3) = InputMtx(1:3);
        NewMtx(6:8) = InputMtx(4:6);
    end
end