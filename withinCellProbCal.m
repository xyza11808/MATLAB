function [p_ErrTrpredError,p_CorTrpredErro] = withinCellProbCal(DataMatrix)
% this function is specifically used to calculate the probability of
% predicted error probability within all behav error trials and behav
% correct trials
AnmChioce = DataMatrix(:,1);
PredChoice = DataMatrix(:,2);
TrOutcomes = DataMatrix(:,3);

ErrorInds = TrOutcomes == 0;
cErroAnmChoice = AnmChioce(ErrorInds);
cErroPredChoice = PredChoice(ErrorInds);
cAnmChoice = unique(cErroAnmChoice);
if ~isempty(cAnmChoice)
    if length(cAnmChoice) > 1
        warning('Current anmchoice within error trials have more than one animal choice');
        cAnmChoice = min(cAnmChoice);
    end
    p_ErrTrpredError = mean(cErroPredChoice == cAnmChoice);
    % fprintf('Probability of predicted choice is also error is %.4f.\n',p_ErrTrpredError);
else
    p_ErrTrpredError = 1;
    cCorrChoice = unique(AnmChioce);
end

cCorrAnmChoice = AnmChioce(~ErrorInds);
cCorrPredChoice = PredChoice(~ErrorInds);
if ~isempty(cAnmChoice)
    cCorrChoice = 1 - cAnmChoice;
end
p_CorTrpredErro = mean(cCorrPredChoice ~= cCorrChoice);
% fprintf('Probability of predicted choice of error within correct trials is %.4f.\n',p_CorTrpredCorr);