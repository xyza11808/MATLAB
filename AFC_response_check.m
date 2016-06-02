function AFC_response_check(data,frame_rate,method,varargin)
%this function is used for check the number of responsive ROIs from 2afc data
%the input data should have been smoothed
%data can be the fluorenscence change according to the mide form or the baseline form
%two method can be used here, one is the event response, which will need more inputs 
%from varargin to get event time infomation
%the other one is not enevt based, only check whether there are significant response during each trial;

if nargin==2
	method='resp';
end

if strcmpi(method,'resp')
	disp('Performing trial response check, only peak response within a trial will be considered.\n');
elseif strcmpi(method,'enent')
	disp('Performing event response check.');  %maybe this analysis can be achieved by another function, but need to be modified
	event_time=varargin{1};
	time_scale=varargin{2};
	if isempty(time_scale)
		time_str=input('Please input the time scale that should be considered after event time.\n','s');
		if isempty(time_str)
			% time_str = '0,2.5';
			time_scale=[0,2.5];
		end
		frame_scale=floor(time_scale*frame_rate);
		if frame_scale(1)==0
			frame_scale(1)=1;
		end
end
resp_result=struct('ROI_num',[],'Active_ROIinds',[],'p_value',[],'Sig_num',[]);
resp_result.ROI_num = size_data(2);
size_data=size(data);
ROI_std = zeros(1,size_data(2));
sig_resp_check = zeros(size_data(1),size_data(2));
resp_value = zeros(1,size_data(2));
if strcmpi(method,'resp')
	for n=1:size_data(2)
		temp_data=squeeze(data(:,n,:));
		ROI_std(n)=std(temp_data(:));

		for m=1:size_data(1)
			sig_resp_check(m,n)=max(temp_data(m,:))>(3*ROI_std(n));
		end

		if (sum(sig_resp_check(:,n))/size_data(1))<0.1
			disp(['Too few significant response within analysis session for ROI' num2str(n) ', considering as inresponsive.\n']);
		else
			resp_value(n) = 1;
		end
	end
	resp_result.Active_ROIinds = find(resp_value);
end