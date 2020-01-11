function FieldEventOnlyDatas = EventOnlyTrace_fun(InputPath,fileName)
% used for generate event-only trace from raw data
% the baseline mean and std calculation was calculated based on 
%  Mark T. Harnett lab's 2019 Neuron paper 

InputPathMatFile = fullfile(InputPath,fileName);

InputMatDataStrc = load(InputPathMatFile);

NumFields = size(InputMatDataStrc.FieldDatas_AllCell,1);
FieldEventOnlyDatas = cell(NumFields,1);
for cField = 1 : NumFields
    % cField = 1;
    cFieldData = InputMatDataStrc.FieldDatas_AllCell{cField,1};
    cFieldEvents = InputMatDataStrc.FieldDatas_AllCell{cField,5};
    RearrangedData_2 = Raw2EventOnly_DataFun(cFieldData,cFieldEvents);
    
    FieldEventOnlyDatas{cField} = RearrangedData_2;
end

save(fullfile(InputPath,'EventOnlyDatas.mat'),'FieldEventOnlyDatas','-v7.3');
