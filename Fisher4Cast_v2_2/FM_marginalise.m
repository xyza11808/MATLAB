% ------------------------------------------------------------------------
% Copyright (C) 2008-2010
% Bruce Bassett Yabebal Fantaye  Renee Hlozek  Jacques Kotze
%
%
%
% This file is part of Fisher4Cast.
%
% Fisher4Cast is free software: you can redistribute it and/or modify
% it under the terms of the Berkeley Software Distribution (BSD) license.
%
% Fisher4Cast is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% BSD license for more details.
% ------------------------------------------------------------------------
%
%This function 'shuffles' the full fisher matrix around according 
% to the parameters the user wants to consider and calculates 
% the final fisher matrix. It takes no input, since it uses the summed
% fisher matrix that has been assigned to the output structre in FM_run.m
% It produced a marginalised Fisher matrix.

function marginalised_matrix = FM_marginalised;
double all;
global input output;
% Compute the new marginalised Fisher matrix


m = input.num_parameters; % take the parameters of interest from the input structure
fisher_mat = output.summed_matrix; % take the summed Fisher matrix from the output structure

length_F = length(fisher_mat); % determining the number of colums in the fisher matrix


%find the index of the parameters to be marginalized over
nonMembers_logi= ismember(1:length(fisher_mat), input.parameters_to_plot);
nonMembers_indx = find(nonMembers_logi==0);

%Shuffle row wise
fisher_mat_2beMarginal = fisher_mat(nonMembers_indx,:);
fisher_mat_WeWant = fisher_mat(input.parameters_to_plot,:);
fisher_mat = [fisher_mat_WeWant; fisher_mat_2beMarginal];

%Shuffle column wise
fisher_mat_2beMarginal = fisher_mat(:,nonMembers_indx);
fisher_mat_WeWant = fisher_mat(:,input.parameters_to_plot);
fisher_mat = [fisher_mat_WeWant fisher_mat_2beMarginal];
% Now fisher_mat is shuffled such that the rows and columns of
% input.parameters_to_plot are in the top-left corner. 

A = fisher_mat(1:m,1:m);
B = fisher_mat(1:m,m+1:length_F);
B';

C = fisher_mat(m+1:length_F,m+1:length_F);
marginalised_matrix = A - B*(C\B');

