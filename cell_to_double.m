function double_data=cell_to_double(cell_data)
%this is used for converting cell data into double, and return it back 
%temporarliy this function is only used for vector data trans

cell_size=size(cell_data);
if (cell_size(1)==1||cell_size(2)==1) && length(cell_size)<3
     raw_data=str2double(cell_data);
     double_data=raw_data(~isnan(raw_data));
end