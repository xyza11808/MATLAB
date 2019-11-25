
ant = NaN(num_percs,numruns,2);
post = NaN(num_percs,numruns,2);

for j = 1:num_percs
    for k = 1:numruns
        for i = 1:2
            ant(j,k,i) = sum(iscorrect_ant(tasks_ant(:,k,j)==i,k,j))/numel(iscorrect_ant(tasks_ant(:,k,j)==i,k,j));
            post(j,k,i) = sum(iscorrect_post(tasks_post(:,k,j)==i,k,j))/numel(iscorrect_post(tasks_post(:,k,j)==i,k,j));
        end
    end
end

figure;subplot(211);errorbar(percents'*ones(1,2),squeeze(mean(post,2)),squeeze(std(post,0,2)));legend('towers','detect'); title('posterior module');
subplot(212);errorbar(percents'*ones(1,2),squeeze(mean(ant,2)),squeeze(std(ant,0,2)));legend('towers','detect');title('anterior module');
