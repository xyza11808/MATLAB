
% test of Jaccard index calculation to measure the similarity between two
% graph
% Ref. https://en.wikipedia.org/wiki/Jaccard_index

Test01_NormWVector = AntiSquareform(Test01_corrs);
ZerosValues = abs(Test01_NormWVector) < 0.2;
Test01_NormWVector = Test01_NormWVector + 1;
Test01_NormWVector(ZerosValues) = 0;

Test02_NormWVector = AntiSquareform(Test02_corrs);
ZerosValues = abs(Test02_NormWVector) < 0.2;
Test02_NormWVector = double((Test02_NormWVector + 1));
Test02_NormWVector(ZerosValues) = 0;


Test03_NormWVector = AntiSquareform(Test03_corrs);
ZerosValues = abs(Test03_NormWVector) < 0.2;
Test03_NormWVector = double((Test03_NormWVector + 1));
Test03_NormWVector(ZerosValues) = 0;


Sim_1_2_data = [Test01_NormWVector, Test02_NormWVector];
Sim_1_2_Index = sum(min(Sim_1_2_data,[],2)) / sum(max(Sim_1_2_data,[],2))

Sim_1_3_data = [Test01_NormWVector, Test03_NormWVector];
Sim_1_3_Index = sum(min(Sim_1_3_data,[],2)) / sum(max(Sim_1_3_data,[],2))

Sim_2_3_data = [Test02_NormWVector, Test03_NormWVector];
Sim_2_3_Index = sum(min(Sim_2_3_data,[],2)) / sum(max(Sim_2_3_data,[],2))




