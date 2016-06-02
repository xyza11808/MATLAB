function hf=Popu_3d_Plot(varargin)
%this functin will be used for 3d plot of give data in a 2D space
%if no data is given, function will end, or give a demo later


if nargin<1
	disp('No input data, quit function.\n');
end

if nargin>1
	InputData=varargin{1};
	InputRank=varargin{2};
	if isempty(InputRank) || ~sum(InputRank)
		disp('No rank data is given. plot according to row sequence.\n');
		hf=Plot3dsurf(InputData,0);
	else
		disp('Plotting 3d line plot using given ranks value.\n');
		hf=Plot3dsurf(InputData,InputRank);
	end
end


function h=Plot3dsurf(Data,Rank)
%Rank length should be the same as data row number, or an 0 for non-rank plot
SizeData=size(Data);
RankColor=1;
if ~Rank
	Rank=1:SizeData(1);
	RankColor=0;
end
RankData=repmat(Rank,1,SizeData(2));
xdata=1:SizeData(2);

h=figure;
hold on;

if RankColor
	RankType=unique(Rank);
	cmap=jet;
    LengthC=size(cmap,1);
    LengthRank=length(RankType);
    
	RankC=zeros(length(RankType)+1,3);
	RankC(:,1)=interp1(1:LengthC,cmap(:,1),1:(LengthC-1)/LengthRank:LengthC);
    RankC(:,2)=interp1(1:LengthC,cmap(:,2),1:(LengthC-1)/LengthRank:LengthC);
    RankC(:,3)=interp1(1:LengthC,cmap(:,3),1:(LengthC-1)/LengthRank:LengthC);
    
%     linspace(cmap(1,1),cmap(end,1),length(RankType));
% 	RankC(:,2)=linspace(cmap(1,2),cmap(end,2),length(RankType));
% 	RankC(:,3)=linspace(cmap(1,3),cmap(end,3),length(RankType));
end

for ROWNum=1:SizeData(1)
	if ~RankColor
		plot3(xdata,RankData(ROWNum,:),Data(ROWNum,:),'color','r');
	else
		plot3(xdata,RankData(ROWNum,:),Data(ROWNum,:),'color',RankC(RankType==Rank(ROWNum),:));
	end
end
xlabel('BinTime');
zlabel('AUC value');
ylabel('Rank value');
% xlabel('x');
% ylabel('y');
% zlabel('z');
view(30,30);
grid on;
hold off;

