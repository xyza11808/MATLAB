function [x,resnorm,residual,exitflag, FitDataCell] = Fit2DGauFun(InputData, ...
    Fun, ProposCenter, ProposeWid)
% function used for 2d gaussian data fitting

AmpInit = max(InputData(:)) - min(InputData(:));

switch Fun
    case 'Gau2D'
        % five parameters to fit, that is : [Amp,xo,wx,yo,wy]
        FitFun = @D2GaussFunction;
        x0 = [AmpInit, ProposCenter(1), ProposeWid(1), ProposCenter(2), ProposeWid(2)];
        lb = [0, 1, 0, 1, 0];
        ub = [realmax('double'), size(InputData, 2), ((size(InputData, 2))/2^2), ...
            size(InputData, 1), ((size(InputData, 1)/2)^2)];
    case 'RotGau2D'
        % six parameters to fit: [Amp,xo,wx,yo,wy,fi]. the last one used to
        % define rotation degree
        FitFun = @D2GaussFunctionRot;
        x0 = [AmpInit, ProposCenter(1), ProposeWid(1), ProposCenter(2), ProposeWid(2), 0];
        lb = [0, 1, 0, 1, 0, -pi/4];
        ub = [realmax('double'), size(InputData, 2), ((size(InputData, 2)/2)^2), ...
            size(InputData, 1), ((size(InputData, 1)/2)^2), pi/4];
    otherwise
        error('unknowed function type');
end

[X,Y] = meshgrid(1:size(InputData,2), 1:size(InputData,1));
xdata = zeros(size(X,1),size(Y,2),2);
xdata(:,:,1) = X;
xdata(:,:,2) = Y;

[x,resnorm,residual,exitflag] = lsqcurvefit(FitFun,x0,xdata,InputData,lb,ub);

[Xhr,Yhr] = meshgrid(1:0.2:size(InputData,2), 1:0.2:size(InputData,1)); % generate high res grid for plot
xdatahr = zeros(size(Xhr,1),size(Yhr,2),2);
xdatahr(:,:,1) = Xhr;
xdatahr(:,:,2) = Yhr;

FitData = D2GaussFunctionRot(x, xdatahr);

FitDataCell = {xdatahr, FitData};
        
