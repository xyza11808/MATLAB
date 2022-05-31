function shiftedMatrix = ZerosPadShift(A, ShiftVector, shiftdims)
% zeros padding shift for a two-dimension matrix

% A = [10, 12, 14, 11;
%      8 , 10, 13, 10;
%      7 ,  8, 12,  8;
%      6 ,  7, 10,  7;
%      5 ,  6,  8,  6;
%      3 ,  5,  7,  5;
%      1 ,  3,  6,  3];
% ShiftVector = -[0,1,3,1];
if ~exist('shiftdims','var')
    shiftdims = 2; % by default, shiftments is performed to columns
end
[m,n]=size(A);
if ~issparse(A)
    if shiftdims == 1 % shift rows
        J=repmat((1:m)',1,n);
        Inew=(1:n) + ShiftVector(:);
        idx=(1<=Inew) & (Inew<=n);
        shiftedMatrix=accumarray([J(idx), Inew(idx)], A(idx),[m,n]);
    elseif shiftdims == 2
        J=repmat(1:n,m,1);
        Inew=(1:m).'+ (ShiftVector(:))';
        idx=(1<=Inew) & (Inew<=m);
        shiftedMatrix=accumarray([Inew(idx),J(idx)], A(idx),[m,n]);
    end
else
    if shiftdims == 1 % shift rows
        J=repmat((1:m)',1,n);
        Inew=(1:n) + ShiftVector(:);
        idx=(1<=Inew) & (Inew<=n);
%         shiftedMatrix=accumarray([J(idx), Inew(idx)], A(idx),[m,n]);
%         
        All_A_values = A(idx);
        UsedSparseData = abs(All_A_values) > 1e-10;
        A_usedDatas = All_A_values(UsedSparseData);
        Inew_label = Inew(idx);
        Inew_label = Inew_label(UsedSparseData);
        clearvars Inew
        J_label = J(idx);
        J_label = J_label(UsedSparseData);
        clearvars J
        shiftedMatrix = sparse(J_label,Inew_label,A_usedDatas,m,n);
        
    elseif shiftdims == 2
        J=repmat(1:n,m,1);
        Inew=(1:m).'+ (ShiftVector(:))';
        idx=(1<=Inew) & (Inew<=m);
        
        All_A_values = A(idx);
        UsedSparseData = abs(All_A_values) > 1e-10;
        A_usedDatas = All_A_values(UsedSparseData);
        Inew_label = Inew(idx);
        Inew_label = Inew_label(UsedSparseData);
        clearvars Inew
        J_label = J(idx);
        J_label = J_label(UsedSparseData);
        clearvars J
        
        shiftedMatrix = sparse(Inew_label,J_label,A_usedDatas,m,n);
    end
    
end
% if ~issparse(shiftedMatrix) && nnz(shiftedMatrix)/numel(shiftedMatrix) < 0.1
%     shiftedMatrix = sparse(shiftedMatrix);
% end
