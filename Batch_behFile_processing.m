if ispc
    GrandPath = 'T:\behaviorData\batch70';
    xpath = genpath(GrandPath);
    nameSplit = strsplit(xpath,';');
elseif ismac
    GrandPath = 'Z:\Lab_Members\LQX\group01\anm02\data';
%     GrandPath = '/Users/xinyu/Documents/dataAll/behavior/Temp';
    xpath = genpath(GrandPath);
    nameSplit = strsplit(xpath,':');
end

if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
nRandomPurePath = 1;
nNormalPTPath = 1;
nProbPath = 1;
RandomPTSession = {};
NorPTsession = {};
ProbSession = {};
ErrorFname = {};
ErrorNum = 0;

for n = 1 : DirLength
    cPATH = nameSplit{n};
%     if ispc
%             systemstr = ['ipython N:\Documents\Python\save_behavData_2_mat_batch.py ',cPATH];
%     elseif ismac
%         systemstr = ['python /Users/xinyu/Documents/extraCode/python_code/Python/save_behavData_2_mat_batch.py ',cPATH];
%     end
%     list = dir([cPATH,filesep,'*.beh']);
%     if isempty(list)
%         fprintf('Folder path %s have no .beh files indside.\n',cPATH);
%         continue;
%     end
%     
%     [status,~] = system(systemstr);
%     
%     if ~status && ispc % try to rerun the python code with base status
%         system('conda activate base');
%         [status,~] = system(systemstr);
%     end
        
    matlist = dir([cPATH,filesep,'*.mat']);
    matFileLength = length(matlist);
    cd(cPATH);
    for nfile = 1 : matFileLength
        cfilename = matlist(nfile).name;
%         try
            xxxx = load(cfilename);
            [~,SessionType] = behavScore_prob(xxxx.behavResults,xxxx.behavSettings,cfilename,0);
            if strcmpi(SessionType,'RandompuretoneProb') || strcmpi(SessionType,'Randompuretone')
                fprintf('Random puretone session exists, plot session data.\n');
                rand_plot(xxxx.behavResults,4,cfilename,1);
                RandomPTSession(nRandomPurePath) = {fullfile(cPATH,cfilename)};
                nRandomPurePath = nRandomPurePath + 1;
            elseif strcmpi(SessionType,'prob')
                ProbSession(nProbPath) = {fullfile(cPATH,cfilename)};
                nProbPath = nProbPath + 1;
            elseif strcmpi(SessionType,'puretone')
                NorPTsession(nNormalPTPath) = {fullfile(cPATH,cfilename)};
                nNormalPTPath = nNormalPTPath + 1;
            end
%         catch ME
%             ErrorNum = ErrorNum + 1;
%             cfPath = fullfile(cPATH,cfilename);
%             ErrorFname{ErrorNum} = cfPath;
%         end
    end
%     if status
%         fprintf('!!!!Folder path %s error exist!!!!\n',cPATH);
%     end
end

%%
% writing down current foders session types
cd(GrandPath);
save SessionTypePath.mat RandomPTSession ProbSession NorPTsession -v7.3
% writing random puretone session path
fprintf('Writing random puretone session path into file...\n');
fID1 = fopen('Random_puretone_path.txt','w+');
FormatSpec = '%s\r\n';
for nSession = 1 : (nRandomPurePath-1)
    fprintf(fID1,FormatSpec,RandomPTSession{nSession});
end
fclose(fID1);

% writing normal puretone session path
fprintf('Writing normal puretone session path into file...\n');
fID2 = fopen('Normal_puretone_path.txt','w+');
FormatSpec = '%s\r\n';
for nSession = 1 : (nNormalPTPath-1)
    fprintf(fID2,FormatSpec,NorPTsession{nSession});
end
fclose(fID2);

% writing Prob session path
fprintf('Writing Prob session path into file...\n');
fID3 = fopen('Prob_tone_path.txt','w+');
FormatSpec = '%s\r\n';
for nSession = 1 : (nProbPath-1)
    fprintf(fID3,FormatSpec,ProbSession{nSession});
end
fclose(fID3);
