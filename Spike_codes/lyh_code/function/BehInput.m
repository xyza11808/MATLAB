function [Octave_used,left_choice_used,inds_correct_used,inds_use,inds_rev] = BehInput(BehaviorData,RevFreqs)

if iscell(BehaviorData)
    inds_range = ones(length(BehaviorData),1);
%     inds_range(1:end) = 1;

    inds_miss = cellfun(@(x) x.Action_choice == 2, BehaviorData);
    freq = cellfun(@(x) x.Stim_toneFreq, BehaviorData);

    choice = cellfun(@(x) x.Action_choice, BehaviorData);
    choice_outcome = cellfun(@(x) x.Trial_Type, BehaviorData) ==cellfun(@(x) x.Action_choice, BehaviorData);
    inds_correct =  cellfun(@(x) x.Time_reward ~= 0, BehaviorData);

%     inds_rev = freq == 14000 | freq == 11061 | freq == 17598;
    inds_rev = ismember(freq,RevFreqs);
    
    inds_L = cellfun(@(x) x.Trial_Type == 0, BehaviorData);

    left_choice = false(length(BehaviorData),1);
else
    inds_range = ones(length(BehaviorData.Trial_Type),1);
    inds_miss = double(BehaviorData.Action_choice(:)) == 2;
    freq = double(BehaviorData.Stim_toneFreq(:));
    choice = double(BehaviorData.Action_choice(:));
    inds_correct = choice == BehaviorData.Trial_Type(:);
    inds_rev = ismember(freq,RevFreqs);
    inds_L = BehaviorData.Trial_Type(:) == 0;
    left_choice = false(size(inds_range));
    
end

left_choice(inds_correct == 1 & inds_L) = true;
left_choice(inds_correct == 0 & ~inds_L) = true;

Octave = log2(double(freq)/min(freq));
Octave_type = unique(Octave);
freq_type = unique(freq);
inds_use = inds_range & ~inds_miss;

Octave_used = Octave(inds_use);
inds_correct_used = inds_correct(inds_use);
inds_L_used = inds_L(inds_use);
choice_used = choice(inds_use);
left_choice_used = left_choice(inds_use);
end