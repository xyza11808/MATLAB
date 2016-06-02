function ROI_selection(data_left,data_right)
%this function is used for post analysis after the population sequence sort
%of the zscore data
%only to extract the responsibe ROIs data from the whole population and
%check out wthether these small groups can make the discrimination of
%different stimulus or some other information
%this function will be called by the zscore sequence sort function
%the input data can be either zscore data ot the fluorescence change trace
%data, which is not after sorted, following a sequence of ROI number
%sequence. it is a two dimensional data with ROI inds as row and time trace
%as columns

[ROI_inds_file,ROI_inds_path,~]=uigetfile({'*.xlsx';'*.xls'},'Select your ROI inds storage file','MultiSelect', 'on');
if iscell(ROI_inds_file)
    disp('Multiple files selected, importing all selected files.\n');
else
    disp('Single file selected, import selected data.\n');
    ROI_inds_file={ROI_inds_file};
end

    cd(ROI_inds_path);
    inds_struct=struct();
    for m=1:length(ROI_inds_file)
        disp(['loading  ROI inds data from ' ROI_inds_path filesep ROI_inds_file{m} '...']);
%         cd(ROI_inds_path);
        ROI_seq=readtable(ROI_inds_file{m},'ReadRowNames',false);
        table_names=ROI_seq.Properties.VariableNames;
        %     column_leh=length(table_names);
        ROI_inds_range=inputdlg(table_names,'Please input ROI selection range for each column');
        scale_range=zeros(length(ROI_inds_range),2);
        for n=1:length(ROI_inds_range)
            scale_range(n,:)=str2num(ROI_inds_range{n});
            if isempty(scale_range(n,1)) || isempty(scale_range(n,2))
                error('error input range for ROI inds selection.\n');
            end
            if scale_range(n,1)<=0
                scale_range(n,1) = 1;
            end
            if scale_range(n,2)>size(ROI_seq,1)
                scale_range(n,2) = size(ROI_seq,1);
            end
            all_ROIinds = ROI_seq.(table_names{1});
            inds_struct.([table_names{1} '_inds']) = all_ROIinds(scale_range(n,1):scale_range(n,2));
            if ~isempty(strfind(table_names{1},'left'))
                inds_struct.([table_names{1} '_data']) = data_left(all_ROIinds(scale_range(n,1):scale_range(n,2)),:);
            elseif ~isempty(strfind(table_names{1},'right'))
                inds_struct.([table_names{1} '_data']) = data_right(all_ROIinds(scale_range(n,1):scale_range(n,2)),:);
            end
        end
    end
    save selected_data.mat inds_struct -v7.3
    
    