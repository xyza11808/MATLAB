function RespSummaryStrc = CellRespAna(RespCell)
% this function is used only for analysis detailed cell response type and
% given output result in a structure
% the fileds within a structure contains:
%      LeftType: 0 for not response, 1 for sound response, 2 for choice response, 3 for both response
%      RightType: the same as Left types

ROILength = length(RespCell);
RespSummaryStrc = struct('LeftResp',[],'RightResp',[]);
for nROI = 1 : ROILength
    cROIresp = RespCell{nROI};
    % most responsive condition, given string 'LSCRSC'
    if isempty(strfind(cROIresp,'L'))
        %only right responsive char inside current resp string
        respValue = CheckRespvalue(cROIresp);
%         if isempty(strfind(cROIresp,'S'))
%             respValue = respValue + 1;
%         end
%         if isempty(strfind(cROIresp,'C'))
%             respValue = respValue + 2;
%         end
        RespSummaryStrc.LeftResp(nROI) = 0;
        RespSummaryStrc.RightResp(nROI) = respValue;
    elseif isempty(strfind(cROIresp,'R'))
        % only left responsive char inside current resp string
        respValue = CheckRespvalue(cROIresp);
%         if isempty(strfind(cROIresp,'S'))
%             respValue = respValue + 1;
%         end
%         if isempty(strfind(cROIresp,'C'))
%             respValue = respValue + 2;
%         end
        RespSummaryStrc.LeftResp(nROI) = respValue;
        RespSummaryStrc.RightResp(nROI) = 0;
    else
        RightInds = strfind(cROIresp,'R');
        LeftInds = strfind(cROIresp,'L');
        CstrContain = strsplit(cROIresp,{'R','L'}); %this should be a three elements component
        if RightInds < LeftInds
            % Right resp string before left resp string
            RightRepString = CstrContain{2};
            LeftRespString = CstrContain{3};
        else
            RightRepString = CstrContain{3};
            LeftRespString = CstrContain{2};
        end
        RespSummaryStrc.LeftResp(nROI) = CheckRespvalue(LeftRespString);
        RespSummaryStrc.RightResp(nROI) = CheckRespvalue(RightRepString);
    end
end
        
        
function RespValues = CheckRespvalue(strings)
RespValues = 0;
if isempty(strfind(strings,'S'))
    RespValues = RespValues + 1;
end
if isempty(strfind(strings,'C'))
    RespValues = RespValues + 2;
end
