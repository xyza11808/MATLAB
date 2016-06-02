function aligned_data=sequence_align(data_time_trace,raw_time_point,alignment_length)

if length(raw_time_point)~=length(alignment_length)
    error('unequal matrix length, quit analysis.\n');
end
smooth_freq_response=smooth(data_time_trace);
freq_gaussian_fit = fit((1:length(data_time_trace))',smooth_freq_response,'gauss4');%use the fit result to generate new data point

aligned_data=zeros(1,length(alignment_length));
for n=1:length(alignment_length)
    if n==1
%        temp_time_trace=data_time_trace(1:raw_time_point(1));
       aligned_data(1:alignment_length(1))=feval(freq_gaussian_fit,linspace(1,raw_time_point(1),alignment_length(1)));
    else
%        part_time_trace=data_time_trace(raw_time_point(n-1):raw_time_point(n));
       aligned_data(alignment_length(n-1):alignment_length(n))=feval(freq_gaussian_fit,linspace(raw_time_point(n-1),raw_time_point(n),(alignment_length(n)-alignment_length(n-1))));
    end
end

        