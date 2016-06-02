classdef DecodingAlgorithms
% DECODINGALGORITHMS A class that contains static functions for 
% decoding the hidden states of linear discrete stochastic systems or 
% hybrid linear discrete stochastic systems subject to gaussian noise. 
% The observations can come from either a gaussian observation model 
% or via a point process observation model.
%
% <a href="matlab: methods('DecodingAlgorithms')">methods</a>
% Reference page in Help browser
% <a href="matlab: doc('DecodingAlgorithms')">doc DecodingAlgorithms</a>


%
% nSTAT v1 Copyright (C) 2012 Masschusetts Institute of Technology
% Cajigas, I, Malik, WQ, Brown, EN
% This program is free software; you can redistribute it and/or 
% modify it under the terms of the GNU General Public License as published 
% by the Free Software Foundation; either version 2 of the License, or 
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details.
%  
% You should have received a copy of the GNU General Public License 
% along with this program; if not, write to the Free Software Foundation, 
% Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    properties
    end
    
    methods (Static)
          
        %% Point Process Adaptive Filter 
        %PPDecodeFilter takes an object of class CIF describing the
        %conditional intensity function. This routine is more generic since
        %all of the computations for the PPAF are done symbolically based
        %on the CIF object. However, it also means that this version is
        %must slower than the linear version below.
        function [x_p, W_p, x_u, W_u, x_uT,W_uT,x_pT, W_pT] = PPDecodeFilter(A, Q, Px0, dN,lambdaCIFColl,binwidth,x0,Pi0, yT,PiT,estimateTarget)  
            % A can be static or can be a different matrix for each time N

            [C,N]   = size(dN); % N time samples, C cells

            ns=size(A,1); % number of states


            if(nargin<12 || isempty(estimateTarget))
                estimateTarget=0;
            end

            if(nargin<11 || isempty(PiT))
                if(estimateTarget==1)
                    PiT = zeros(size(Q));
                else
                    PiT = 0*diag(ones(ns,1))*1e-6;
                end
            end
            if(nargin<9 || isempty(Pi0))
                Pi0 = zeros(ns,ns);
            end
            if(nargin<10 || isempty(yT))
                yT=[];
                Amat = A;
                Qmat = Q;
                ft   = zeros(size(Amat,2),N);
                PiT = zeros(size(Q));

            else


                PitT= zeros(ns,ns,N);  % Pi(t,T) in Srinivasan et al. 
                QT  = zeros(ns,ns,N);  % The noise covaraince given target observation (Q_t)
                if(estimateTarget==1)
                    PitT(:,:,N)=Q;   % Pi(T,T)=Pi_T + Q_T, setting PiT=0
                else
                    PitT(:,:,N)=PiT+Q;
                end
                PhitT = zeros(ns,ns,N);% phi(t,T) - transition matrix from time T to t
    %             PhiTt = zeros(ns,ns,N);% phi(T,t) - transition matrix from time t to T
                PhitT(:,:,N) = eye(ns,ns); % phi(T,T) = I
                B = zeros(ns,ns,N);    % See Equation 2.21 in Srinivasan et. al

                for n=N:-1:2
                    invA=eye(size(A))/A;
                    % state transition matrix
                    PhitT(:,:,n-1)= invA*PhitT(:,:,n);
    %                 PhiTt(:,:,n)= A^(N-n);

                    % Equation 2.16 in Srinivasan et al. Note there is a typo in the paper. 
                    % This is the correct expression. The term Q_t-1 does not
                    % need to be mulitplied by phi(t-1,t)

                    PitT(:,:,n-1) = invA*PitT(:,:,n)*invA'+Q;



                    if(n<=N)
                        B(:,:,n) = A-(Q/PitT(:,:,n))*A; %Equation 2.21 in Srinivasan et. al
                        QT(:,:,n) = Q-(Q/PitT(:,:,n))*Q';
                    end
                end
    %             PhiTt(:,:,1)= A^(N-1);
                B(:,:,1) = A-(Q/PitT(:,:,1))*A;
                QT(:,:,1) = Q-(Q/PitT(:,:,1))*Q';
                % See Equations 2.23 through 2.26 in Srinivasan et. al
                if(estimateTarget==1)
    %                 beta = [beta ;zeros(ns,C)];
                    for n=1:N
                       psi = B(:,:,n);
                       if(n==N)
                           gammaMat = eye(ns,ns);
                       else
                           gammaMat = (Q/PitT(:,:,n))*PhitT(:,:,n);
                       end
                       Amat(:,:,n) = [psi,gammaMat;
                                      zeros(ns,ns), eye(ns,ns)];
        %                if(n>1)
        %                 tUnc(:,:,n) = tUnc(:,:,n-1)+PhiTt(:,:,n)*Q*PhiTt(:,:,n)';
        %                else
        %                 tUnc(:,:,n) = PhiTt(:,:,n)*Q*PhiTt(:,:,n)';   
        %                end
                       Qmat(:,:,n) = [QT(:,:,n),   zeros(ns,ns);
                                      zeros(ns,ns) zeros(ns,ns)]; 
                    end
                else

                    Amat = B;
                    Qmat = QT;
                    for n=1:N
                        ft(:,n)   = (Q/PitT(:,:,n))*PhitT(:,:,n)*yT;
                    end

                end

            end

            if(nargin<8 || isempty(x0))
                x0=zeros(size(A,2),1);
            end

            if(nargin<7)
                binwidth = .001; % in seconds
            end

            %% 
            % Return values are
            % x_p: state estimates given the past x_k|k-1
            % W_p: error covariance estimates given the past
            % x_u: state updates given the data - x_k|k
            % W_u: error covariance updates given the data

            [C,N]   = size(dN); % N time samples, C cells

              %% Initialize the PPAF
            x_p     = zeros( size(Amat,2), N+1 );
            x_u     = zeros( size(Amat,2), N );
            W_p    = zeros( size(Amat,2),size(Amat,2), N+1 );
            W_u    = zeros( size(Amat,2),size(Amat,2), N );




            if(~isempty(yT))
                if(det(Pi0)==0) % Assume x0 is known exactly

                else %else
                    invPi0 = pinv(Pi0);
                    invPitT= pinv(PitT(:,:,1));
                    Pi0New = pinv(invPi0+invPitT);
                    Pi0New(isnan(Pi0New))=0;
                    x0New  = Pi0New*(invPi0*x0+invPitT*PhitT(:,:,1)*yT);
                    x0=x0New; Pi0 = Pi0New;
                end
            end
            if(~isempty(yT) && estimateTarget==1)
                    x0= [x0;yT]; %simultaneous estimation of target requires state augmentation

            end


            if((estimateTarget==1 && ~isempty(yT)) || isempty(yT))
                x_p(:,1)= Amat(:,:,1)*x0;

            else
                invPitT  = pinv(PitT(:,:,1));
    %             invPhitT = pinv(PhitT(:,:,1));
                invA     = pinv(A);
                invPhi0T = pinv(invA*PhitT(:,:,1));
                ut(:,1) = (Q*invPitT)*PhitT(:,:,1)*(yT-invPhi0T*x0);
                [x_p(:,1), W_p(:,:,1)] = DecodingAlgorithms.PPDecode_predict(x0, Pi0, Amat(:,:,min(size(Amat,3),n)), Qmat(:,:,min(size(Qmat,3))));
                x_p(:,1) = x_p(:,1)+ut(:,1);
                W_p(:,:,1) = W_p(:,:,1) + (Q*invPitT)*A*Pi0*A'*(Q*invPitT)';

    %             x_p(:,1)= Amat(:,:,1)*x0 + ft(:,1);


            end
            if(estimateTarget==1 && ~isempty(yT))
               Pi0New = [Pi0, zeros(ns,ns);
                         zeros(ns,ns)  , zeros(ns,ns)];
               W_p(:,:,1) = Amat(:,:,1)*Pi0New*Amat(:,:,1)'+Qmat(:,:,1);      
            elseif(estimateTarget==0 && isempty(yT))

               W_p(:,:,1) = Amat(:,:,1)*Pi0*Amat(:,:,1)'+Qmat(:,:,1);
            end %Otherwise we computed it above.


            for n=1:N
                [x_u(:,n),   W_u(:,:,n)]   = DecodingAlgorithms.PPDecode_update( x_p(:,n), W_p(:,:,n), dN(:,1:n),lambdaCIFColl, binwidth,n);
    %             [x_p(:,n+1), W_p(:,:,n+1)] = DecodingAlgorithms.PPDecode_predict(x_u(:,n), W_u(:,:,n), Amat(:,:,min(size(A,3),n)), Qmat(:,:,min(size(Qmat,3))));

                if((estimateTarget==1 && ~isempty(yT)) || isempty(yT))
                    [x_p(:,n+1), W_p(:,:,n+1)] = DecodingAlgorithms.PPDecode_predict(x_u(:,n), W_u(:,:,n), Amat(:,:,min(size(A,3),n)), Qmat(:,:,min(size(Qmat,3))));
                else
                    %ut= Q_{t}\Pi(t,T)^{-1}\phi(t,T)(y_{T}-phi(T,t-1)x_{t-1}
                    if(n<N)
                        ut(:,n+1) = (Q*pinv(PitT(:,:,n+1)))*PhitT(:,:,n+1)*(yT-pinv(PhitT(:,:,n))*x_u(:,n));
        %                 ut(:,n+1) = ut(:,n+1)*delta;
                        [x_p(:,n+1), W_p(:,:,n+1)] = DecodingAlgorithms.PPDecode_predict(x_u(:,n), W_u(:,:,n), Amat(:,:,min(size(A,3),n)), Qmat(:,:,min(size(Qmat,3))));
                        x_p(:,n+1) = x_p(:,n+1)+ut(:,n+1);
                        W_p(:,:,n+1) = W_p(:,:,n+1) + (Q*pinv(PitT(:,:,n+1)))*A*W_u(:,:,n)*A'*(Q*pinv(PitT(:,:,n+1)))';
                    end
                end

            end
            if(~isempty(yT) && estimateTarget==1)
               %decompose the augmented state space into estimates of the state
               %vector and the target position
               x_uT = x_u(ns+1:2*ns,:);
               W_uT = W_u(ns+1:2*ns,ns+1:2*ns,:);
               x_pT = x_p(ns+1:2*ns,:);
               W_pT = W_p(ns+1:2*ns,ns+1:2*ns,:);

               x_u = x_u(1:ns,:);
               W_u = W_u(1:ns,1:ns,:);
               x_p = x_p(1:ns,:);
               W_p = W_p(1:ns,1:ns,:);

            else
               x_uT = [];
               W_uT = [];
               x_pT = [];
               W_pT = [];

            end


        end
        %PPDecodeFilterLinear takes in a linear representation of the
        %conditional intensity terms. These are the terms that are inside
        %the exponential in a Poisson or Binomial description of the CIF.
        %If such a representation is available, use of this routine is
        %recommended because it is much faster.
        function [x_p, W_p, x_u, W_u, x_uT,W_uT,x_pT, W_pT] = PPDecodeFilterLinear(A, Q, dN,mu,beta,fitType,delta,gamma,windowTimes,x0, Pi0, yT,PiT,estimateTarget)
        % [x_p, W_p, x_u, W_u] = PPDecodeFilterLinear(CIFType,A, Q, dN,beta,gamma,x0, xT)
        % Point process adaptive filter with the assumption of linear
        % expresion for the conditional intensity functions (see below). If
        % the terms in the conditional intensity function include
        % polynomial powers of a variable for example, these expressions do
        % not hold. Use the PPDecodeFilter instead since it will compute
        % these expressions symbolically. However, because of the matlab
        % symbolic toolbox, it runs much slower than this version.
        %
        % If a final value for xT is given then the approach of Srinivasan
        % et. al (2006) is used for concurrent estimate of the state and
        % the target. This involves state augmentation of the original
        % state space model. If a final value is not specified then the
        % standard Point Process Adaptive Filter of Eden et al (2004) is
        % used instead.
        % 
        % Assumes in both cases that 
        %   x_t = A*x_{t-1} + w_{t}     w_{t} ~ Normal with zero me and
        %                                       covariance Q
        %
        %
        % Paramerters:
        %  
        % A:        The state transition matrix from the x_{t-1} to x_{t}
        %
        % Q:        The covariance of the process noise w_t
        %
        % dN:       A C x N matrix of ones and zeros corresponding to the
        %           observed spike trains. N is the number of time steps in
        %           my code. C is the number of cells
        %
        % mu:       Cx1 vector of baseline firing rates for each cell. In
        %           the CIF expression in 'fitType' description 
        %           mu_c=mu(c);
        %
        % beta:     nsxC matrix of coefficients for the conditional
        %           intensity function. ns is the number of states in x_t 
        %           In the conditional intesity function description below
        %           beta_c = beta(:,c)';
        %
        % fitType: 'poisson' or 'binomial'. Determines how the beta and
        %           gamma coefficients are used to compute the conditional
        %           intensity function.
        %           For the cth cell:
        %           If poisson: lambda*delta = exp(mu_c+beta_c*x + gamma_c*hist_c)
        %           If binomial: logit(lambda*delta) = mu_c+beta_c*x + gamma_c*hist_c
        %
        % delta:    The number of seconds per time step. This is used to compute
        %           th history effect for each spike train using the input
        %           windowTimes and gamma
        %
        % gamma:    length(windowTimes)-1 x C matrix of the history
        %           coefficients for each window in windowTimes. In the 'fitType'
        %           expression above:
        %           gamma_c = gamma(:,c)';
        %           If gamma is a length(windowTimes)-1x1 vector, then the
        %           same history coefficients are used for each cell.
        %
        % windowTimes: Defines the distinct windows of time (in seconds)
        %           that will be computed for each spike train.
        %
        % xT:       Target Position
        %
        % PiT:      Target Uncertainty
        %
        % estimateTarget: By default (==0), it is assumed that that the 
        %                 initial target information is fixed. Set to 1 in order to 
        %                 simultaneously estimate the target location via 
        %                 state augmentation
        %
        %
        %
        % Code for reaching to final target adapted from:
        % L. Srinivasan, U. T. Eden, A. S. Willsky, and E. N. Brown, 
        % "A state-space analysis for reconstruction of goal-directed
        % movements using neural signals.,"
        % Neural computation, vol. 18, no. 10, pp. 2465?2494, Oct. 2006.
        %
        % Point Process Adaptive Filter from 
        % U. T. Eden, L. M. Frank, R. Barbieri, V. Solo, and E. N. Brown, 
        % "Dynamic analysis of neural encoding by point process adaptive
        % filtering.,"
        % Neural computation, vol. 16, no. 5, pp. 971?998, May. 2004.
        
        [C,N]   = size(dN); % N time samples, C cells
        ns=size(A,1); % number of states
        
        if(nargin<14 || isempty(estimateTarget))
            estimateTarget=0;
        end
        if(nargin<10 || isempty(x0))
           x0=zeros(ns,1);
           
        end
        if(nargin<9 || isempty(windowTimes))
           windowTimes=[]; 
        end
        if(nargin<8 || isempty(gamma))
            gamma=0;
        end
        if(nargin<7 || isempty(delta))
            delta = .001;
        end
        
        if(nargin<13 || isempty(PiT))
            if(estimateTarget==1)
                PiT = zeros(size(Q));
            else
                PiT = 0*diag(ones(ns,1))*1e-6;
            end
        end
        if(nargin<11 || isempty(Pi0))
            Pi0 = zeros(ns,ns);
        end
        if(nargin<12 || isempty(yT))
            yT=[];
            Amat = A;
            Qmat = Q;
            ft   = zeros(size(Amat,2),N);
            PiT = zeros(size(Q));
            
        else
            
            
            PitT= zeros(ns,ns,N);  % Pi(t,T) in Srinivasan et al. 
            QT  = zeros(ns,ns,N);  % The noise covaraince given target observation (Q_t)
            QN =Q(:,:,min(size(Q,3),N));
            if(estimateTarget==1)
                
                PitT(:,:,N)=QN;   % Pi(T,T)=Pi_T + Q_T, setting PiT=0
            else
                PitT(:,:,N)=PiT+QN;
            end
            PhitT = zeros(ns,ns,N);% phi(t,T) - transition matrix from time T to t
%             PhiTt = zeros(ns,ns,N);% phi(T,t) - transition matrix from time t to T
            PhitT(:,:,N) = eye(ns,ns); % phi(T,T) = I
            B = zeros(ns,ns,N);    % See Equation 2.21 in Srinivasan et. al
            
            for n=N:-1:2
                An =A(:,:,min(size(A,3),n));
                Qn =Q(:,:,min(size(Q,3),n));
                
                invA=pinv(An);
                % state transition matrix
                PhitT(:,:,n-1)= invA*PhitT(:,:,n);
%                 PhiTt(:,:,n)= A^(N-n);

                % Equation 2.16 in Srinivasan et al. Note there is a typo in the paper. 
                % This is the correct expression. The term Q_t-1 does not
                % need to be mulitplied by phi(t-1,t)
                
                PitT(:,:,n-1) = invA*PitT(:,:,n)*invA'+Qn;

             

                if(n<=N)
                    
                    B(:,:,n) = An-(Qn*pinv(PitT(:,:,n)))*An; %Equation 2.21 in Srinivasan et. al
                    QT(:,:,n) = Qn-(Qn*pinv(PitT(:,:,n)))*Qn';
                end
            end
            A1=A(:,:,min(size(A,3),1));
            Q1=Q(:,:,min(size(Q,3),1));
            B(:,:,1) = A1-(Q1*pinv(PitT(:,:,1)))*A1;
            QT(:,:,1) = Q1-(Q1*pinv(PitT(:,:,1)))*Q1';

            % See Equations 2.23 through 2.26 in Srinivasan et. al
            if(estimateTarget==1)
                beta = [beta ;zeros(ns,C)];
                for n=1:N
                    An =A(:,:,min(size(A,3),n));
                    Qn =Q(:,:,min(size(Q,3),n));
                    psi = B(:,:,n);
                    if(n==N)
                       gammaMat = eye(ns,ns);
                    else
                       gammaMat = (Qn*pinv(PitT(:,:,n)))*PhitT(:,:,n);
                    end
                    Amat(:,:,n) = [psi,gammaMat;
                                  zeros(ns,ns), eye(ns,ns)];
                    Qmat(:,:,n) = [QT(:,:,n),   zeros(ns,ns);
                                  zeros(ns,ns) zeros(ns,ns)]; 
                end
            else
                
                Amat = B;
                Qmat = QT;
                for n=1:N
                    An =A(:,:,min(size(A,3),n));
                    Qn =Q(:,:,min(size(Q,3),n));
                    ft(:,n)   = (Qn*pinv(PitT(:,:,n)))*PhitT(:,:,n)*yT;
                end

            end

        end
         
        
        minTime=0;
        maxTime=(size(dN,2)-1)*delta;
        
        C=size(dN,1);
        if(~isempty(windowTimes))
            histObj = History(windowTimes,minTime,maxTime);
            for c=1:C
                nst{c} = nspikeTrain( (find(dN(c,:)==1)-1)*delta);
                nst{c}.setMinTime(minTime);
                nst{c}.setMaxTime(maxTime);
                HkAll{c} = histObj.computeHistory(nst{c}).dataToMatrix;
            end
            if(size(gamma,2)==1 && C>1) % if more than 1 cell but only 1 gamma
                gammaNew(:,c) = gamma;
            else
                gammaNew=gamma;
            end
            gamma = gammaNew;
                
        else
            for c=1:C
                HkAll{c} = zeros(N,1);
                gammaNew(c)=0;
            end
            gamma=gammaNew;
            
        end
        

        
        %% Initialize the PPAF
        x_p     = zeros( size(Amat,2), N+1 );
        x_u     = zeros( size(Amat,2), N );
        W_p    = zeros( size(Amat,2),size(Amat,2), N+1 );
        W_u    = zeros( size(Amat,2),size(Amat,2), N );
        
        


        if(~isempty(yT))
            if(det(Pi0)==0) % Assume x0 is known exactly
                
            else %else
                invPi0 = pinv(Pi0);
                invPitT= pinv(PitT(:,:,1));
                Pi0New = pinv(invPi0+invPitT);
                Pi0New(isnan(Pi0New))=0;
                x0New  = Pi0New*(invPi0*x0+invPitT*PhitT(:,:,1)*yT);
                x0=x0New; Pi0 = Pi0New;
            end
        end
        if(~isempty(yT) && estimateTarget==1)
                x0= [x0;yT]; %simultaneous estimation of target requires state augmentation
            
        end
        
        
        if((estimateTarget==1 && ~isempty(yT)) || isempty(yT))
            x_p(:,1)= Amat(:,:,1)*x0;
           
        else
            invPitT  = pinv(PitT(:,:,1));
%             invPhitT = pinv(PhitT(:,:,1));
            A1 = A(:,:,min(size(A,3),1));
            Q1 = Q(:,:,min(size(Q,3),1));
            invA     = pinv(A1);
            invPhi0T = pinv(invA*PhitT(:,:,1));
            ut(:,1) = (Q1*invPitT)*PhitT(:,:,1)*(yT-invPhi0T*x0);
            [x_p(:,1), W_p(:,:,1)] = DecodingAlgorithms.PPDecode_predict(x0, Pi0, Amat(:,:,min(size(Amat,3),n)), Qmat(:,:,min(size(Qmat,3))));
            x_p(:,1) = x_p(:,1)+ut(:,1);
            W_p(:,:,1) = W_p(:,:,1) + (Q1*invPitT)*A1*Pi0*A1'*(Q1*invPitT)';
                    
%             x_p(:,1)= Amat(:,:,1)*x0 + ft(:,1);

            
        end
        if(estimateTarget==1 && ~isempty(yT))
           Pi0New = [Pi0, zeros(ns,ns);
                     zeros(ns,ns)  , zeros(ns,ns)];
           W_p(:,:,1) = Amat(:,:,1)*Pi0New*Amat(:,:,1)'+Qmat(:,:,1);      
        elseif(estimateTarget==0 && isempty(yT))
            
           W_p(:,:,1) = Amat(:,:,1)*Pi0*Amat(:,:,1)'+Qmat(:,:,1);
        end %Otherwise we computed it above.
        
        for n=1:N


            [x_u(:,n), W_u(:,:,n)] = DecodingAlgorithms.PPDecode_updateLinear(x_p(:,n), W_p(:,:,n), dN,mu,beta,fitType,gamma,HkAll,n);
            % The prediction step is identical to the symbolic implementation since
            % it is independent of the CIF

            if((estimateTarget==1 && ~isempty(yT)) || isempty(yT))
                [x_p(:,n+1), W_p(:,:,n+1)] = DecodingAlgorithms.PPDecode_predict(x_u(:,n), W_u(:,:,n), Amat(:,:,min(size(Amat,3),n)), Qmat(:,:,min(size(Qmat,3))));
            else
                %ut= Q_{t}\Pi(t,T)^{-1}\phi(t,T)(y_{T}-phi(T,t-1)x_{t-1}
                if(n<N)
                    An = A(:,:,min(size(A,3),n));
                    Qn = Q(:,:,min(size(Q,3),n));
                    invPitT  = pinv(PitT(:,:,n+1));
                    invPhitm1T = pinv(PhitT(:,:,n));
                    ut(:,n+1) = (Qn*invPitT)*PhitT(:,:,n+1)*(yT-invPhitm1T*x_u(:,n));
    %                 ut(:,n+1) = ut(:,n+1)*delta;
                    [x_p(:,n+1), W_p(:,:,n+1)] = DecodingAlgorithms.PPDecode_predict(x_u(:,n), W_u(:,:,n), Amat(:,:,min(size(A,3),n)), Qmat(:,:,min(size(Qmat,3))));
                    x_p(:,n+1) = x_p(:,n+1)+ut(:,n+1);
                    W_p(:,:,n+1) = W_p(:,:,n+1) + (Qn*invPitT)*An*W_u(:,:,n)*An'*(Qn*invPitT)';
                end
            end
        end
        if(~isempty(yT) && estimateTarget==1)
           %decompose the augmented state space into estimates of the state
           %vector and the target position
           x_uT = x_u(ns+1:2*ns,:);
           W_uT = W_u(ns+1:2*ns,ns+1:2*ns,:);
           x_pT = x_p(ns+1:2*ns,:);
           W_pT = W_p(ns+1:2*ns,ns+1:2*ns,:);

           x_u = x_u(1:ns,:);
           W_u = W_u(1:ns,1:ns,:);
           x_p = x_p(1:ns,:);
           W_p = W_p(1:ns,1:ns,:);

        else
           x_uT = [];
           W_uT = [];
           x_pT = [];
           W_pT = [];

        end
        end
      

        % PPAF Prediction Step 
        function [x_p, W_p] = PPDecode_predict(x_u, W_u, A, Q)
                % The PPDecode prediction step 
                    x_p     = A * x_u;

                    W_p    = A * W_u * A' + Q;

                    if(rcond(W_p)<1000*eps)
                        W_p=W_u; % See Srinivasan et al. 2007 pg. 529
                    end
                    W_p = 0.5*(W_p+W_p');
    %                 if(or(any(isnan(W_p)),any(isnan(W_u))))
    %                     
    %                     pause;
    %                 end
    %                 if(rcond(W_p)<=eps(W_p))
    %                     W_p=W_u;
    %                 end
        end
        % PPAF Update Step 
        %PPDecode_update takes in an object of class CIF
        function [x_u, W_u,lambdaDeltaMat] = PPDecode_update(x_p, W_p, dN,lambdaIn,binwidth,time_index)
                % The PPDecode update step that finds the state estimate based on new
                % data

                %Original Code
                   clear lambda; 
                if(isa(lambdaIn,'cell'))
                    lambda = lambdaIn;
                elseif(isa(lambdaIn,'CIF'))
                    lambda{1} = lambdaIn;
                else
                    error('Lambda must be a cell of CIFs or a CIF');
                end

                clear gradientMat lambdaDeltaMat;
                sumValVec=zeros(size(W_p,1),1);
                sumValMat=zeros(size(W_p,2),size(W_p,2));
                lambdaDeltaMat = zeros(length(lambda),1);
                for C=1:length(lambda)

                   if(isempty(lambda{C}.historyMat))
                        spikeTimes =(find(dN(C,:)==1)-1)*binwidth;
                        nst = nspikeTrain(spikeTimes);
                        nst.resample(1/binwidth);
                        lambdaDeltaMat(C,1) = lambda{C}.evalLambdaDelta(x_p,time_index,nst);
                        sumValVec = sumValVec+dN(C,end)*lambda{C}.evalGradientLog(x_p,time_index,nst)'-lambda{C}.evalGradient(x_p,time_index,nst)';
                        sumValMat = sumValMat-dN(C,end)*lambda{C}.evalJacobianLog(x_p,time_index,nst)'+lambda{C}.evalJacobian(x_p,time_index,nst)';
                   else % we already have computed the history effect and can just use it - much faster
                        lambdaDeltaMat(C,1) = lambda{C}.evalLambdaDelta(x_p,time_index); 
                        sumValVec = sumValVec+dN(C,end)*lambda{C}.evalGradientLog(x_p,time_index)'-lambda{C}.evalGradient(x_p,time_index)';
                        sumValMat = sumValMat-dN(C,end)*lambda{C}.evalJacobianLog(x_p,time_index)'+lambda{C}.evalJacobian(x_p,time_index)';
                   end


                end


                % Use pinv so that we do a SVD and ignore the zero singular values
                % Sometimes because of the state space model definition and how information
                % is integrated from distinct CIFs the sumValMat is very sparse. This
                % allows us to prevent inverting singular matrices
                invWp = pinv(W_p);
                invWu = invWp + sumValMat;
                invWu = 0.5*(invWu+invWu');
                Wu = pinv(invWu);

                % Make sure that the update covariate is positive definite.
                [vec,val]=eig(Wu); val(val<=0)=eps;
                W_u=vec*val*vec';
                W_u=0.5*(W_u+W_u');
                if(or(rcond(W_u)<1000*eps, any(isnan(W_u)))) %If ill-conditioned then recompute 
                % Recompute Wu based on Srinivasan et al March 2007
                    sumValVec=zeros(size(W_p,1),1);
                    sumValMat=zeros(size(W_p,2),size(W_p,2));
                    lambdaDeltaMat = zeros(length(lambda),1);
                    for C=1:length(lambda)

                       if(isempty(lambda{C}.historyMat))
                            spikeTimes =(find(dN(C,:)==1)-1)*binwidth;
                            nst = nspikeTrain(spikeTimes);
                            nst.resample(1/binwidth);
                            lambdaDeltaMat(C,1) = lambda{C}.evalLambdaDelta(x_p,time_index,nst);
                            sumValVec = sumValVec+lambda{C}.evalGradientLog(x_p,time_index,nst)'*(dN(C,end)-lambdaDeltaMat(C,1));
                            sumValMat = sumValMat+lambda{C}.evalGradientLog(x_p,time_index,nst)'*(lambdaDeltaMat(C,1))*lambda{C}.evalGradientLog(x_p,time_index,nst);
                       else % we already have computed the history effect and can just use it - much faster
                            lambdaDeltaMat(C,1) = lambda{C}.evalLambdaDelta(x_p,time_index,nst); 
                            sumValVec = sumValVec+lambda{C}.evalGradientLog(x_p,time_index)'*(dN(C,end)-lambdaDeltaMat(C,1));
                            sumValMat = sumValMat+lambda{C}.evalGradientLog(x_p,time_index)'*(lambdaDeltaMat(C,1))*lambda{C}.evalGradientLog(x_p,time_index);
                       end


                    end
                    invWp = pinv(W_p);
                    invWu = invWp + sumValMat;
                    invWu = 0.5*(invWu+invWu');
                    Wu = pinv(invWu);

                    % Make sure that the update covariate is positive definite.
                    [vec,val]=eig(Wu); val(val<=0)=eps;
                    W_u=vec*val*vec';
                    W_u=0.5*(W_u+W_u');
                end
                % Need to add symbolic code in case of ill-conditioned W_u

                x_u     = x_p + W_u*(sumValVec);


        end       
        %PPDecode_updateLinear takes in a linear representation of the CIF
        %(much faster)
        function [x_u, W_u,lambdaDeltaMat] = PPDecode_updateLinear(x_p, W_p, dN,mu,beta,fitType,gamma,HkAll,time_index)
            [C,N]   = size(dN); % N time samples, C cells
            if(nargin<9 || isempty(time_index))
                time_index=1;
            end
            if(nargin<8 || isempty(HkAll))
                HkAll=cell(C,1);
                for c=1:C
                    HkAll{c}=0;
                end
            end
            if(nargin<7 || isempty(gamma))
                gamma=zeros(1,C);
            end
            if(nargin<6 || isempty(fitType))
                fitType = 'poisson';
            end


            sumValVec=zeros(size(W_p,1),1);
            sumValMat=zeros(size(W_p,2),size(W_p,2));
            lambdaDeltaMat = zeros(C,1);
            if(strcmp(fitType,'binomial'))
                for c=1:C
                    
                    if(numel(gamma)==1)
                        gammaC=gamma;
                    else 
                        gammaC=gamma(:,c);
                    end
                    linTerm = mu(c)+beta(:,c)'*x_p + gammaC'*HkAll{c}(time_index,:)';
                    lambdaDeltaMat(c,1) = exp(linTerm)./(1+exp(linTerm));
                    if(isnan(lambdaDeltaMat(c,1)))
                        if(linTerm>1e2)
                            lambdaDeltaMat(c,1)=1;
                        else
                            lambdaDeltaMat(c,1)=0;
                        end
                    end
                    sumValVec = sumValVec+(dN(c,time_index)-lambdaDeltaMat(c,1))*(1-lambdaDeltaMat(c,1))*beta(:,c);
                    sumValMat = sumValMat+(dN(c,time_index)+(1-2*(lambdaDeltaMat(c,1)))).*(1-(lambdaDeltaMat(c,1))).*(lambdaDeltaMat(c,1))*beta(:,c)*beta(:,c)';
                end
            elseif(strcmp(fitType,'poisson'))
                for c=1:C                   
                    if(numel(gamma)==1)
                        gammaC=gamma;
                    else 
                        gammaC=gamma(:,c);
                    end
                    linTerm = mu(c)+beta(:,c)'*x_p + gammaC'*HkAll{c}(time_index,:)';
                    lambdaDeltaMat(c,1) = exp(linTerm);
                    if(isnan(lambdaDeltaMat(c,1)))
                        if(linTerm>1e2)
                            lambdaDeltaMat(c,1)=1;
                        else
                            lambdaDeltaMat(c,1)=0;
                        end
                    end

                    sumValVec = sumValVec+(dN(c,time_index)-lambdaDeltaMat(c,1))*beta(:,c);
                    sumValMat = sumValMat+(lambdaDeltaMat(c,1))*beta(:,c)*beta(:,c)';
                end
            end
    % 
            usePInv=1;
            if(usePInv==1)
                % Use pinv so that we do a SVD and ignore the zero singular values
                % Sometimes because of the state space model definition and how information
                % is integrated from distinct CIFs the sumValMat is very sparse. This
                % allows us to prevent inverting singular matrices
                invWp = pinv(W_p);
                invWu = invWp + sumValMat;
                invWu(isnan(invWu))=0; %invWu(isinf(invWu))=0;
                invWu = 0.5*(invWu+invWu');
                Wu = pinv(invWu);

            else
                invWp = eye(size(W_p))/W_p;
                invWu = invWp + sumValMat;
                invWu = 0.5*(invWu+invWu');
                Wu = eye(size(W_p))/invWu;
            end 
           % Make sure that the update covariance is positive definite.
            [vec,val]=eig(Wu); val(val<=0)=eps;
            W_u=vec*val*vec';
            W_u=real(W_u);
            W_u(isnan(W_u))=0;
            W_u=0.5*(W_u+W_u');
            if(or(rcond(W_u)<1000*eps, any(isnan(W_u)))) %If ill-conditioned then recompute 
                % Recompute Wu based on Srinivasan et al March 2007
                 sumValVec=zeros(size(W_p,1),1);
                 sumValMat=zeros(size(W_p,2),size(W_p,2));
                 if(strcmp(fitType,'binomial'))
                    for c=1:C    
                        linTerm = mu(c)+beta(:,c)'*x_p + gamma(:,c)'*HkAll{c}(time_index,:)';
                        lambdaDeltaMat(c,1) = exp(linTerm)./(1+exp(linTerm));
                        if(isnan(lambdaDeltaMat(c,1)))
                            if(linTerm>1e2)
                                lambdaDeltaMat(c,1)=1;
                            else
                                lambdaDeltaMat(c,1)=0;
                            end
                        end
                        sumValVec = sumValVec+(dN(c,time_index)-lambdaDeltaMat(c,1))*(1-lambdaDeltaMat(c,1))*beta(:,c);
                        sumValMat = sumValMat+((1-lambdaDeltaMat(c,1))^2).*(lambdaDeltaMat(c,1))*beta(:,c)*beta(:,c)';
                    end
                elseif(strcmp(fitType,'poisson'))
                    for c=1:C    
                        linTerm = mu(c)+beta(:,c)'*x_p + gamma(:,c)'*HkAll{c}(time_index,:)';
                        lambdaDeltaMat(c,1) = exp(linTerm);
                        if(isnan(lambdaDeltaMat(c,1)))
                            if(linTerm>1e2)
                                lambdaDeltaMat(c,1)=1;
                            else
                                lambdaDeltaMat(c,1)=0;
                            end
                        end

                        sumValVec = sumValVec+(dN(c,time_index)-lambdaDeltaMat(c,1))*beta(:,c);
                        sumValMat = sumValMat+(lambdaDeltaMat(c,1))*beta(:,c)*beta(:,c)';
                    end
                end
                invWp = pinv(W_p);
                invWu = invWp + sumValMat;
                invWu(isnan(invWu))=0; %invWu(isinf(invWu))=0;
                Wu = pinv(invWu);
                % Make sure that the update covariate is positive definite.
                [vec,val]=eig(Wu); val(val<=0)=eps;
                W_u=vec*val*vec';
                W_u=real(W_u);
                W_u(isnan(W_u))=0;
                W_u=0.5*(W_u+W_u');
            end
            x_u     = x_p + W_u*(sumValVec);


        end


        %% Point Process Hybrid Filter
        function [S_est, X, W, MU_u, X_s, W_s,pNGivenS]= PPHybridFilterLinear(A, Q, p_ij,Mu0, dN,mu,beta,fitType,binwidth,gamma,windowTimes,x0,Pi0, yT,PiT,estimateTarget,MinClassificationError)

            % General-purpose filter design for neural prosthetic devices.
            % Srinivasan L, Eden UT, Mitter SK, Brown EN.
            % J Neurophysiol. 2007 Oct;98(4):2456-75. Epub 2007 May 23.

            [C,N]   = size(dN); % N time samples, C cells
            nmodels = length(A);
            for s=1:nmodels
                ns(s)=size(A{s},1); % number of states
            end
            nsMax = max(ns);
            if(nargin<17 || isempty(MinClassificationError))
                MinClassificationError=0; %0: chooses the most probable discrete state estimate and take the
                                          %   probability weighted average
                                          %   of the continous states. This
                                          %   is the approximate MMSE
                                          %   filter.
                                          %1: takes the most likely discrete state estimate and also the 
                                          %   continuous states
                                          %   corresponding to the most
                                          %   likely discrete state model.
                                          %   This is approximately the
                                          %   Maximum Likelihood Filter
            end
            if(nargin<16 || isempty(estimateTarget))
                estimateTarget=0;
            end

            if(nargin<15 || isempty(PiT))
                for s=1:nmodels
                    if(estimateTarget==1)
                        PiT{s} = zeros(size(Q{s}));
                    else
                        PiT{s} = 0*diag(ones(ns(s),1))*1e-6;
                    end
                end
            end
            if(nargin<13 || isempty(Pi0))
                for s=1:nmodels
                    Pi0{s}(:,:) = zeros(ns(s),ns(s));
                end
            end
            if(nargin<14 || isempty(yT))
                for s=1:nmodels
                    yT{s}=[];
                    Amat{s} = A{s};
                    Qmat{s} = Q{s};
                    ft{s}   = zeros(size(Amat{s},2),N);
                    PiT{s} = zeros(size(Q{s}));
                    betaNew{s} = beta;
                end
                beta = betaNew;
            else
                Pi0new=cell(1,nmodels);
                for s=1:nmodels

                    PitT{s}= zeros(ns(s),ns(s),N);  % Pi(t,T) in Srinivasan et al. 
                    QT{s}  = zeros(ns(s),ns(s),N);  % The noise covaraince given target observation (Q_t)
                    if(estimateTarget==1)
                        PitT{s}(:,:,N)=Q{s};   % Pi(T,T)=Pi_T + Q_T, setting PiT=0
                    else
                        PitT{s}(:,:,N)=PiT{s}+Q{s};
                    end
                    PhitT{s} = zeros(ns(s),ns(s),N);% phi(t,T) - transition matrix from time T to t
        %             PhiTt = zeros(ns,ns,N);% phi(T,t) - transition matrix from time t to T
                    PhitT{s}(:,:,N) = eye(ns(s),ns(s)); % phi(T,T) = I
                    B{s} = zeros(ns(s),ns(s),N);    % See Equation 2.21 in Srinivasan et. al

                    for n=N:-1:2
                        if(rcond(A{s})<1000*eps)
                            invA=pinv(A{s});
                        else
                            invA=eye(size(A{s}))/A{s};
                        end
                        % state transition matrix
                        PhitT{s}(:,:,n-1)= invA*PhitT{s}(:,:,n);
        %                 PhiTt(:,:,n)= A^(N-n);

                        % Equation 2.16 in Srinivasan et al. Note there is a typo in the paper. 
                        % This is the correct expression. The term Q_t-1 does not
                        % need to be mulitplied by phi(t-1,t)

                        PitT{s}(:,:,n-1) = invA*PitT{s}(:,:,n)*invA'+Q{s};


                        if(n<=N)
                            B{s}(:,:,n) = A{s}-(Q{s}*pinv(PitT{s}(:,:,n)))*A{s}; %Equation 2.21 in Srinivasan et. al
                            QT{s}(:,:,n) = Q{s}-(Q{s}*pinv(PitT{s}(:,:,n)))*Q{s}';
                        end
                    end
        %             PhiTt(:,:,1)= A^(N-1);
                    B{s}(:,:,1) = A{s}-(Q{s}*pinv(PitT{s}(:,:,1)))*A{s};
                    QT{s}(:,:,1) = Q{s}-(Q{s}*pinv(PitT{s}(:,:,1)))*Q{s}';
                    betaNew{s} = beta;
                    % See Equations 2.23 through 2.26 in Srinivasan et. al
                    if(estimateTarget==1)

                        betaNew{s} = [beta ;zeros(ns(s),C)];
                        for n=1:N
                           psi = B{s}(:,:,n);
                           if(n==N)
                               gammaMat = eye(ns(s),ns(s));
                           else
                               gammaMat = (Q{s}*pinv(PitT{s}(:,:,n)))*PhitT{s}(:,:,n);
                           end
                           Amat{s}(:,:,n) = [psi,gammaMat;
                                          zeros(ns(s),ns(s)), eye(ns(s),ns(s))];
            %                if(n>1)
            %                 tUnc(:,:,n) = tUnc(:,:,n-1)+PhiTt(:,:,n)*Q*PhiTt(:,:,n)';
            %                else
            %                 tUnc(:,:,n) = PhiTt(:,:,n)*Q*PhiTt(:,:,n)';   
            %                end
                           Qmat{s}(:,:,n) = [QT{s}(:,:,n),   zeros(ns(s),ns(s));
                                          zeros(ns(s),ns(s)) zeros(ns(s),ns(s))]; 



                        end

                       Pi0new{s} = [Pi0{s},  zeros(ns(s),ns(s));
                                    zeros(ns(s),ns(s)) zeros(ns(s),ns(s))]; 

                    else

                        Amat{s} = B{s};
                        Qmat{s} = QT{s};
                        for n=1:N
                            ft{s}(:,n)   = (Q{s}*pinv(PitT{s}(:,:,n)))*PhitT{s}(:,:,n)*yT{s};
                        end

                    end

                end
                if(estimateTarget==1)
                    Pi0 = Pi0new;

                end
                beta = betaNew;
            end

            if(nargin<12 || isempty(x0))
                for s=1:nmodels
                    x0{s}=zeros(size(Amat{s},2),1);
                end
            end

            if(nargin<9)
                binwidth=0.001; %1 msec
            end

            if(isa(A,'cell'))
                dimMat = zeros(1,length(Amat));
                X_u = cell(1,length(Amat));
                W_u = cell(1,length(Amat));
                X_p = cell(1,length(Amat));
                W_p = cell(1,length(Amat));
                ind = cell(1,length(Amat));
                ut = cell(1,length(Amat));

                for i=1:length(Amat)
                    lambdaDeltaMat{i} = zeros(size(dN));
                    X_u{i} = zeros(size(Amat{i},1), size(dN,2));
                    X_p{i} = zeros(size(Amat{i},1), size(dN,2)+1);
                    W_u{i} = zeros(size(Amat{i},1), size(Amat{i},1), size(dN,2));
                    W_p{i} = zeros(size(Amat{i},1), size(Amat{i},1), size(dN,2)+1);
                    dimMat(i) = size(Amat{i},2);
                    W_u{i}(:,:,1) =Pi0{i};
                    ind{i} = 1:dimMat(i);
                    ut{i} = zeros(size(Amat{i},1), size(dN,2));
                end
            end

            maxDim = max(dimMat);
    %         nmodels = length(Amat);
    %         lambdaCIFColl = CIFColl(lambda);

            minTime=0;
            maxTime=(size(dN,2)-1)*binwidth;

            C=size(dN,1);

            if(nargin<11 || isempty(windowTimes))
                 for c=1:C
                    HkAll{c} = zeros(N,1);
                    gammaNew(c)=0;
                end
                gamma=gammaNew;
            else
                histObj = History(windowTimes,minTime,maxTime);
                for c=1:C
                    nst{c} = nspikeTrain( (find(dN(c,:)==1)-1)*binwidth);
                    nst{c}.setMinTime(minTime);
                    nst{c}.setMaxTime(maxTime);
                    HkAll{c} = histObj.computeHistory(nst{c}).dataToMatrix;
                end
                if(size(gamma,2)==1 && C>1) % if more than 1 cell but only 1 gamma
                    gammaNew(:,c) = gamma;
                end
                gamma = gammaNew;

            end
            % Overall estimates of Hybrid filter
            X = zeros(maxDim, size(dN,2));         % Estimated Trajectories
            W = zeros(maxDim, maxDim, size(dN,2)); % Covariance of estimate
            % Individual Model Estimates
            for i=1:nmodels
                X_s{i} = X;    % Individual Model Estimates
                W_s{i} = W;    % Individual Model Covariances
            end
            % Model probabilities 
            MU_u = zeros(nmodels,size(dN,2));   % P(s_k | H_k+1) % updated state probabilities
            MU_p  = zeros(nmodels,size(dN,2));   % P(s_k | H_k)  % prediction state probabilities
            pNGivenS = zeros(nmodels,size(dN,2));


            %mu_0|1 = mu_0|0;
            if(isempty(Mu0))
                Mu0 = ones(nmodels,1)*1/nmodels;
            elseif(size(Mu0,1)==nmodels && size(Mu0,2)==1)
                Mu0 = Mu0;
            elseif(size(Mu0,1)==1 && size(Mu0,2)==nmodels)
                Mu0 = Mu0';
            else
                error('Mu0 must be a column or row vector with the same number of dimensions as the number of states');
            end
            for s=1:nmodels
                [X_p{s}(ind{s},1),W_p{s}(ind{s},ind{s},1)] = DecodingAlgorithms.PPDecode_predict(x0{s}(ind{s}), Pi0{s}(ind{s},ind{s}), Amat{s}(ind{s},ind{s},min(size(Amat{s},3),1)), Qmat{s}(:,:,min(size(Qmat{s},3))));
              
                if((estimateTarget==0 && ~isempty(yT{s})))               
                    invA= pinv(Amat{s}(:,:,min(size(Amat,3),1)));
                    ut{s}(:,1) = (Q{s}*pinv(PitT{s}(:,:,1)))*PhitT{s}(:,:,1)*(yT{s}-pinv(invA*PhitT{s}(:,:,1))*x0{s});
                    X_p{s}(ind{s},1) = X_p{s}(ind{s},1)+ut{s}(:,1);
                    W_p{s}(ind{s},ind{s},1) =W_p{s}(ind{s},ind{s},1) + (Q{s}*pinv(PitT{s}(:,:,1)))*A{s}*Pi0{s}*A{s}'*(Q{s}*pinv(PitT{s}(:,:,1)))';
                end
            end

    %            [~, S_est(1)] = max(MU_p(:,1)); %Most likely current state

                %State transition Probabilities must integrate to 1
                sumVal = sum(p_ij,2);
                if(any(sumVal~=1))
                    error('State Transition probability matrix must sum to 1 along each row');
                end
            %% 9 Steps
            % Filtering steps.
            for k = 1:(size(dN,2))

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 1 - p(s_k | H_k) = Sum(p(s_k|s_k-1)*p(s_k-1|H_k))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %MU(:,k)_p= [ p(s_k=1 | H_k)] is a vector of the probabilities
                %           [ p(s_k=2 | H_k)]
                %               .
                %               .
                %               .
                %           [ p(s_k=N | H_k)]
                % thus it is an prediction of the discrete state at time k given all
                % of the neural firing up to k-1 as summarized in H_k
                %
                % Whereas 
                % MU_u(:,k)=[ p(s_k=1 | H_k+1)] is a vector of the probabilities
                %           [ p(s_k=2 | H_k+1)]
                %               .
                %               .
                %               .
                %           [ p(s_k=N | H_k+1)]
                % The s suffix indicates that this is a "smoothed" estimate of
                % the state given the firing up to time k summarized in H_k+1
                if k==1
                    MU_p(:,k) = p_ij'*Mu0;          %state probability prediction equation
                else
                    MU_p(:,k) = p_ij'*MU_u(:,k-1);  
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 2 - p(s_k-1 | s_k, H_k)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % This is a matrix with i,j entry indicating the probability that 
                % s_k-1 = j given than s_k = i
                %
                % MU_p is the normalization factor. The first column of the
                % matrix of probabilities is:
                %
                % P(s_k-1=1 | s_k=1,H_k) ~ P(s_k=1|s_k-1=1,H_k)*P(s_k-1=1|H_k)
                % P(s_k-1=1 | s_k=2,H_k) ~ P(s_k=2|s_k-1=1,H_k)*P(s_k-1=1|H_k)
                % 
                % And the second columns ... etc
                %
                % 
                % P(s_k-1=2 | s_k=1,H_k) ~ P(s_k=1|s_k-1=2,H_k)*P(s_k-1=1|H_k)
                % P(s_k-1=2 | s_k=2,H_k) ~ P(s_k=2|s_k-1=2,H_k)*P(s_k-1=1|H_k)

                if(k==1)
                    p_ij_s= p_ij.*(Mu0*ones(1,nmodels));%.*(ones(nmodels,1)*(1./MU_p(:,k))');
                else
                    p_ij_s= p_ij.*(MU_u(:,k-1)*ones(1,nmodels));%.*(ones(nmodels,1)*(1./MU_p(:,k))');
                end
    %          
                 % To avoid any numerical issues with roundoff, we normalize to
                 % 1 again
                 normFact = repmat(sum(p_ij_s,1),[nmodels 1]); %Every column must sum to 1

                 p_ij_s = p_ij_s./normFact;
    %              for i=1:length(normFact)
    %                  if(normFact(i)~=0)
    %                     p_ij_s(:,i) = p_ij_s(:,i)./normFact(i);
    %                  else %reset all the states to be equally likely (each row must sum to 1)
    %                     p_ij_s(:,i) = 1/nmodels*ones(nmodels,1);
    %                  end
    %              end         
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 3 - Approximate p(x_k-1 | s_k, H_k) with Gaussian 
                % approximation to Mixtures of Gaussians
                % Calculate the mixed state mean for each filter
                % This will be the initial states for the update step of the
                % Point Process Adaptive Filter
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                    for j = 1:nmodels
                        for i = 1:nmodels
                            if(k>1)
                                X_s{j}(ind{i},k) = X_s{j}(ind{i},k) + X_u{i}(ind{i},k-1)*p_ij_s(i,j);
                            else
                                X_s{j}(ind{i},k) = X_s{j}(ind{i},k) + x0{i}(ind{i})*p_ij_s(i,j); 
                            end
                        end
                    end

                        % Calculate the mixed state covariance for each filter

                    for j = 1:nmodels
                        for i = 1:nmodels
                            if(k>1)
                                W_s{j}(ind{i},ind{i},k) = W_s{j}(ind{i},ind{i},k) + (W_u{i}(ind{i},ind{i},k-1) + (X_u{i}(ind{i},k-1)-X_s{j}(ind{i},k))*(X_u{i}(ind{i},k-1)-X_s{j}(ind{i},k))')*p_ij_s(i,j);
                            else
                                W_s{j}(ind{i},ind{i},k) = W_s{j}(ind{i},ind{i},k) + (Pi0{i}(ind{i},ind{i})+ (x0{i}(ind{i})-X_s{j}(ind{i},k))*(x0{i}(ind{i})-X_s{j}(ind{i},k))')*p_ij_s(i,j);
                            end
                        end
                    end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Step 4 - Approximate p(x_k+1 |s_k+1,n_k+1,H_k+1)
               % Uses a bank of nmodel point process filters
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            k
               for s=1:nmodels

                   % Prediction Step
                   [X_p{s}(ind{s},k),W_p{s}(ind{s},ind{s},k)] = DecodingAlgorithms.PPDecode_predict(X_s{s}(ind{s},k), W_s{s}(ind{s},ind{s},k), Amat{s}(:,:,min(size(Amat,3),k)), Qmat{s}(:,:,min(size(Qmat{s},3))));

                   if(estimateTarget==0 && ~isempty(yT{s}))
                       if(k>1)
                            ut{s}(:,k) = (Q{s}*pinv(PitT{s}(:,:,k)))*PhitT{s}(:,:,k)*(yT{s}-pinv(PhitT{s}(:,:,k-1))*X_s{s}(ind{s},k));
                       else
                           invA = pinv(A{s}(:,:,min(size(A{s},3),1)));
                           ut{s}(:,k) = (Q{s}*pinv(PitT{s}(:,:,1)))*PhitT{s}(:,:,1)*(yT{s}-pinv(invA*PhitT{s}(:,:,1))*X_s{s}(ind{s},k));
                       end
                       X_p{s}(ind{s},k) = X_p{s}(ind{s},k)+ut{s}(:,k);
                       W_p{s}(ind{s},ind{s},k) =W_p{s}(ind{s},ind{s},k) + (Q{s}*pinv(PitT{s}(:,:,k)))*A{s}*W_s{s}(ind{s},ind{s},k)*A{s}'*(Q{s}*pinv(PitT{s}(:,:,k)))';

                    end

                   % Update Step
                   % Fold in the neural firing in the current time step
                   [X_u{s}(ind{s},k),W_u{s}(ind{s},ind{s},k),lambdaDeltaMat{s}(:,k)] = DecodingAlgorithms.PPDecode_updateLinear(X_p{s}(ind{s},k),squeeze(W_p{s}(ind{s},ind{s},k)),dN,mu,beta{s}(ind{s},:),fitType,gamma,HkAll,k);


               end
    %            pause;
    %            close all; plot(lambdaDeltaMat{1}(:,k),'k.'); hold on; plot(lambdaDeltaMat{2}(:,k),'b*');
    %            
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Step 5 - p(n_k | s_k, H_k) using Laplace approximation
               % See General-purpose filter design for neural prosthetic devices.
               % Srinivasan L, Eden UT, Mitter SK, Brown EN.
               % J Neurophysiol. 2007 Oct;98(4):2456-75. Epub 2007 May 23.
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


               for s=1:nmodels

                 tempPdf = sqrt(det(W_u{s}(:,:,k)))./sqrt(det(W_p{s}(:,:,k)))*prod(exp(dN(:,k).*log(lambdaDeltaMat{s}(:,k))-lambdaDeltaMat{s}(:,k)));
                 pNGivenS(s,k) = tempPdf;
               end
               tempData = pNGivenS(:,k);
               tempData(isinf(tempData))=0;
               pNGivenS(:,k) = tempData;

               normFact = sum(pNGivenS(:,k));
               if(normFact~=0 && ~isnan(normFact))
                pNGivenS(:,k)=pNGivenS(:,k)./sum(pNGivenS(:,k));
               else

                   if(k>1)
                       pNGivenS(:,k) = pNGivenS(:,k-1);
                   else
                       pNGivenS(:,k) = .5*ones(nmodels,1);
                   end
               end
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Step 6 - Calculate p(s_k | n_k, H_k) = p(s_k | H_k+1)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               pSGivenN(:,k) = MU_p(:,k).*pNGivenS(:,k);



               %Normalization Factor
               normFact = sum(pSGivenN(:,k));
               if(normFact~=0 && ~isnan(normFact))
                pSGivenN(:,k) = pSGivenN(:,k)./sum(pSGivenN(:,k));
               else
                   if(k>1)
                        pSGivenN(:,k) = pSGivenN(:,k-1);
                   else
                        pSGivenN(:,k) = Mu0;
                   end

               end


               MU_u(:,k) = pSGivenN(:,k); %estimate of s_k given data up to k


               [~, S_est(k)] = max(MU_u(:,k)); %Most likely current state

               if(MinClassificationError==1)

                   s= S_est(k);
                   X(ind{s},k) = X_u{s}(ind{s},k);
                   W(ind{s},ind{s},k) = W_u{s}(ind{s},ind{s},k);

               else %Minimize the mean squared error

                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   % Step 7 - Calculate p(x_k | n_k, H_k) - using gaussian
                   % approximation to mixture of gaussians 
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   for s=1:nmodels
                       X(ind{s},k) = X(ind{s},k)+MU_u(s,k)*X_u{s}(ind{s},k); 
                   end
                   for s=1:nmodels
                       W(ind{s},ind{s},k) =  W(ind{s},ind{s},k) +MU_u(s,k)*(W_u{s}(ind{s},ind{s},k) + (X_u{s}(ind{s},k)-X(ind{s},k))*(X_u{s}(ind{s},k)-X(ind{s},k))');
                   end
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               end
            end


            %Solution to the known target problem. Run the Hybrid Filter
            %Forward to determine the most likely states.... this is the
            %sequence of the A dynamics matrices to use in the computation of
            %the Target Reach Model of Srinivasan et al. Compute PiT

         end   
        function [S_est, X, W, MU_s, X_s, W_s,pNGivenS]  = PPHybridFilter(A, Q, p_ij,Mu0,dN,lambdaCIFColl,binwidth,x0,Pi0, yT,PiT,estimateTarget,MinClassificationError)


            % General-purpose filter design for neural prosthetic devices.
            % Srinivasan L, Eden UT, Mitter SK, Brown EN.
            % J Neurophysiol. 2007 Oct;98(4):2456-75. Epub 2007 May 23.

            [C,N]   = size(dN); % N time samples, C cells
            nmodels = length(A);
            for s=1:nmodels
                ns(s)=size(A{s},1); % number of states
            end
            nsMax = max(ns);
            if(nargin<13 || isempty(MinClassificationError))
                MinClassificationError=0; %Minimum mean square error state estimate. By default do maximum likelihood
            end
            if(nargin<12 || isempty(estimateTarget))
                estimateTarget=0;
            end

            if(nargin<11 || isempty(PiT))
                for s=1:nmodels
                    if(estimateTarget==1)
                        PiT{s} = zeros(size(Q{s}));
                    else
                        PiT{s} = 0*diag(ones(ns(s),1))*1e-6;
                    end
                end
            end
            if(nargin<9 || isempty(Pi0))
                for s=1:nmodels
                    Pi0{s}(:,:) = zeros(ns(s),ns(s));
                end
            end
            if(nargin<10 || isempty(yT))
                for s=1:nmodels
                    yT{s}=[];
                    Amat{s} = A{s};
                    Qmat{s} = Q{s};
                    ft{s}   = zeros(size(Amat{s},2),N);
                    PiT{s} = zeros(size(Q{s}));
                end
         
            else
                Pi0new=cell(1,nmodels);
                for s=1:nmodels

                    PitT{s}= zeros(ns(s),ns(s),N);  % Pi(t,T) in Srinivasan et al. 
                    QT{s}  = zeros(ns(s),ns(s),N);  % The noise covaraince given target observation (Q_t)
                    if(estimateTarget==1)
                        PitT{s}(:,:,N)=Q{s};   % Pi(T,T)=Pi_T + Q_T, setting PiT=0
                    else
                        PitT{s}(:,:,N)=PiT{s}+Q{s};
                    end
                    PhitT{s} = zeros(ns(s),ns(s),N);% phi(t,T) - transition matrix from time T to t
        %             PhiTt = zeros(ns,ns,N);% phi(T,t) - transition matrix from time t to T
                    PhitT{s}(:,:,N) = eye(ns(s),ns(s)); % phi(T,T) = I
                    B{s} = zeros(ns(s),ns(s),N);    % See Equation 2.21 in Srinivasan et. al

                    for n=N:-1:2
                        if(rcond(A{s})<1000*eps)
                            invA=pinv(A{s});
                        else
                            invA=eye(size(A{s}))/A{s};
                        end
                        % state transition matrix
                        PhitT{s}(:,:,n-1)= invA*PhitT{s}(:,:,n);
        %                 PhiTt(:,:,n)= A^(N-n);

                        % Equation 2.16 in Srinivasan et al. Note there is a typo in the paper. 
                        % This is the correct expression. The term Q_t-1 does not
                        % need to be mulitplied by phi(t-1,t)

                        PitT{s}(:,:,n-1) = invA*PitT{s}(:,:,n)*invA'+Q{s};


                        if(n<=N)
                            B{s}(:,:,n) = A{s}-(Q{s}*pinv(PitT{s}(:,:,n)))*A{s}; %Equation 2.21 in Srinivasan et. al
                            QT{s}(:,:,n) = Q{s}-(Q{s}*pinv(PitT{s}(:,:,n)))*Q{s}';
                        end
                    end
        %             PhiTt(:,:,1)= A^(N-1);
                    B{s}(:,:,1) = A{s}-(Q{s}*pinv(PitT{s}(:,:,1)))*A{s};
                    QT{s}(:,:,1) = Q{s}-(Q{s}*pinv(PitT{s}(:,:,1)))*Q{s}';
                    % See Equations 2.23 through 2.26 in Srinivasan et. al
                    if(estimateTarget==1)

                   
                        for n=1:N
                           psi = B{s}(:,:,n);
                           if(n==N)
                               gammaMat = eye(ns(s),ns(s));
                           else
                               gammaMat = (Q{s}*pinv(PitT{s}(:,:,n)))*PhitT{s}(:,:,n);
                           end
                           Amat{s}(:,:,n) = [psi,gammaMat;
                                          zeros(ns(s),ns(s)), eye(ns(s),ns(s))];
          
                           Qmat{s}(:,:,n) = [QT{s}(:,:,n),   zeros(ns(s),ns(s));
                                          zeros(ns(s),ns(s)) zeros(ns(s),ns(s))]; 


                        end

                       Pi0new{s} = [Pi0{s},  zeros(ns(s),ns(s));
                                    zeros(ns(s),ns(s)) zeros(ns(s),ns(s))]; 

                    else

                        Amat{s} = B{s};
                        Qmat{s} = QT{s};
                        for n=1:N
                            ft{s}(:,n)   = (Q{s}*pinv(PitT{s}(:,:,n)))*PhitT{s}(:,:,n)*yT{s};
                        end

                    end

                end
                if(estimateTarget==1)
                    Pi0 = Pi0new;

                end
            end

            if(nargin<8 || isempty(x0))
                for s=1:nmodels
                    x0{s}=zeros(size(Amat{s},2),1);
                end
            end

            if(nargin<7)
                binwidth=0.001; %1 msec
            end

            if(isa(A,'cell'))
                dimMat = zeros(1,length(Amat));
                X_u = cell(1,length(Amat));
                W_u = cell(1,length(Amat));
                X_p = cell(1,length(Amat));
                W_p = cell(1,length(Amat));
                ind = cell(1,length(Amat));
                ut = cell(1,length(Amat));

                for i=1:length(Amat)
                    lambdaDeltaMat{i} = zeros(size(dN));
                    X_u{i} = zeros(size(Amat{i},1), size(dN,2));
                    X_p{i} = zeros(size(Amat{i},1), size(dN,2)+1);
                    W_u{i} = zeros(size(Amat{i},1), size(Amat{i},1), size(dN,2));
                    W_p{i} = zeros(size(Amat{i},1), size(Amat{i},1), size(dN,2)+1);
                    dimMat(i) = size(Amat{i},2);
                    W_u{i}(:,:,1) =Pi0{i};
                    ind{i} = 1:dimMat(i);
                    ut{i} = zeros(size(Amat{i},1), size(dN,2));
                end
            end

            maxDim = max(dimMat);
    %         nmodels = length(Amat);
    %         lambdaCIFColl = CIFColl(lambda);

            minTime=0;
            maxTime=(size(dN,2)-1)*binwidth;

            C=size(dN,1);

            % Overall estimates of Hybrid filter
            X = zeros(maxDim, size(dN,2));         % Estimated Trajectories
            W = zeros(maxDim, maxDim, size(dN,2)); % Covariance of estimate
            % Individual Model Estimates
            for i=1:nmodels
                X_s{i} = X;    % Individual Model Estimates
                W_s{i} = W;    % Individual Model Covariances
            end
            % Model probabilities 
            MU_u = zeros(nmodels,size(dN,2));   % P(s_k | H_k+1) % updated state probabilities
            MU_p  = zeros(nmodels,size(dN,2));   % P(s_k | H_k)  % prediction state probabilities
            pNGivenS = zeros(nmodels,size(dN,2));


            %mu_0|1 = mu_0|0;
            if(isempty(Mu0))
                Mu0 = ones(nmodels,1)*1/nmodels;
            elseif(size(Mu0,1)==nmodels && size(Mu0,2)==1)
                Mu0 = Mu0;
            elseif(size(Mu0,1)==1 && size(Mu0,2)==nmodels)
                Mu0 = Mu0';
            else
                error('Mu0 must be a column or row vector with the same number of dimensions as the number of states');
            end
            for s=1:nmodels
                 [X_p{s}(ind{s},1),W_p{s}(ind{s},ind{s},1)] = DecodingAlgorithms.PPDecode_predict(x0{s}(ind{s}), Pi0{s}(ind{s},ind{s}), Amat{s}(ind{s},ind{s},min(size(Amat{s},3),1)), Qmat{s}(:,:,min(size(Qmat{s},3))));
              
                if((estimateTarget==0 && ~isempty(yT{s})))               
                    invA= pinv(Amat{s}(:,:,min(size(Amat,3),1)));
                    ut{s}(:,1) = (Q{s}*pinv(PitT{s}(:,:,1)))*PhitT{s}(:,:,1)*(yT{s}-pinv(invA*PhitT{s}(:,:,1))*x0{s});
                    X_p{s}(ind{s},1) = X_p{s}(ind{s},1)+ut{s}(:,1);
                    W_p{s}(ind{s},ind{s},1) =W_p{s}(ind{s},ind{s},1) + (Q{s}*pinv(PitT{s}(:,:,1)))*A{s}*Pi0{s}*A{s}'*(Q{s}*pinv(PitT{s}(:,:,1)))';
                end
            end

    %            [~, S_est(1)] = max(MU_p(:,1)); %Most likely current state

                %State transition Probabilities must integrate to 1
                sumVal = sum(p_ij,2);
                if(any(sumVal~=1))
                    error('State Transition probability matrix must sum to 1 along each row');
                end
            %% 9 Steps
            % Filtering steps.
            for k = 1:(size(dN,2))

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 1 - p(s_k | H_k) = Sum(p(s_k|s_k-1)*p(s_k-1|H_k))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %MU(:,k)_p= [ p(s_k=1 | H_k)] is a vector of the probabilities
                %           [ p(s_k=2 | H_k)]
                %               .
                %               .
                %               .
                %           [ p(s_k=N | H_k)]
                % thus it is an prediction of the discrete state at time k given all
                % of the neural firing up to k-1 as summarized in H_k
                %
                % Whereas 
                % MU_u(:,k)=[ p(s_k=1 | H_k+1)] is a vector of the probabilities
                %           [ p(s_k=2 | H_k+1)]
                %               .
                %               .
                %               .
                %           [ p(s_k=N | H_k+1)]
                % The s suffix indicates that this is a "smoothed" estimate of
                % the state given the firing up to time k summarized in H_k+1
                if k==1
                    MU_p(:,k) = p_ij'*Mu0;          %state probability prediction equation
                else
                    MU_p(:,k) = p_ij'*MU_u(:,k-1);  
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 2 - p(s_k-1 | s_k, H_k)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % This is a matrix with i,j entry indicating the probability that 
                % s_k-1 = j given than s_k = i
                %
                % MU_p is the normalization factor. The first column of the
                % matrix of probabilities is:
                %
                % P(s_k-1=1 | s_k=1,H_k) ~ P(s_k=1|s_k-1=1,H_k)*P(s_k-1=1|H_k)
                % P(s_k-1=1 | s_k=2,H_k) ~ P(s_k=2|s_k-1=1,H_k)*P(s_k-1=1|H_k)
                % 
                % And the second columns ... etc
                %
                % 
                % P(s_k-1=2 | s_k=1,H_k) ~ P(s_k=1|s_k-1=2,H_k)*P(s_k-1=1|H_k)
                % P(s_k-1=2 | s_k=2,H_k) ~ P(s_k=2|s_k-1=2,H_k)*P(s_k-1=1|H_k)

                if(k==1)
                    p_ij_s= p_ij.*(Mu0*ones(1,nmodels));%.*(ones(nmodels,1)*(1./MU_p(:,k))');
                else
                    p_ij_s= p_ij.*(MU_u(:,k-1)*ones(1,nmodels));%.*(ones(nmodels,1)*(1./MU_p(:,k))');
                end
    %          
                 % To avoid any numerical issues with roundoff, we normalize to
                 % 1 again
                 normFact = repmat(sum(p_ij_s,1),[nmodels 1]); %Every column must sum to 1

                 p_ij_s = p_ij_s./normFact;
    %              for i=1:length(normFact)
    %                  if(normFact(i)~=0)
    %                     p_ij_s(:,i) = p_ij_s(:,i)./normFact(i);
    %                  else %reset all the states to be equally likely (each row must sum to 1)
    %                     p_ij_s(:,i) = 1/nmodels*ones(nmodels,1);
    %                  end
    %              end         
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 3 - Approximate p(x_k-1 | s_k, H_k) with Gaussian 
                % approximation to Mixtures of Gaussians
                % Calculate the mixed state mean for each filter
                % This will be the initial states for the update step of the
                % Point Process Adaptive Filter
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                    for j = 1:nmodels
                        for i = 1:nmodels
                            if(k>1)
                                X_s{j}(ind{i},k) = X_s{j}(ind{i},k) + X_u{i}(ind{i},k-1)*p_ij_s(i,j);
                            else
                                X_s{j}(ind{i},k) = X_s{j}(ind{i},k) + x0{i}(ind{i})*p_ij_s(i,j); 
                            end
                        end
                    end

                        % Calculate the mixed state covariance for each filter

                    for j = 1:nmodels
                        for i = 1:nmodels
                            if(k>1)
                                W_s{j}(ind{i},ind{i},k) = W_s{j}(ind{i},ind{i},k) + (W_u{i}(ind{i},ind{i},k-1) + (X_u{i}(ind{i},k-1)-X_s{j}(ind{i},k))*(X_u{i}(ind{i},k-1)-X_s{j}(ind{i},k))')*p_ij_s(i,j);
                            else
                                W_s{j}(ind{i},ind{i},k) = W_s{j}(ind{i},ind{i},k) + (Pi0{i}(ind{i},ind{i})+ (x0{i}(ind{i})-X_s{j}(ind{i},k))*(x0{i}(ind{i})-X_s{j}(ind{i},k))')*p_ij_s(i,j);
                            end
                        end
                    end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Step 4 - Approximate p(x_k+1 |s_k+1,n_k+1,H_k+1)
               % Uses a bank of nmodel point process filters
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            k
               for s=1:nmodels

                   % Prediction Step
                   [X_p{s}(ind{s},k),W_p{s}(ind{s},ind{s},k)] = DecodingAlgorithms.PPDecode_predict(X_s{s}(ind{s},k), W_s{s}(ind{s},ind{s},k), Amat{s}(:,:,min(size(Amat,3),k)), Qmat{s}(:,:,min(size(Qmat{s},3))));

                   if(estimateTarget==0 && ~isempty(yT{s}))
                       if(k>1)
                            ut{s}(:,k) = (Q{s}*pinv(PitT{s}(:,:,k)))*PhitT{s}(:,:,k)*(yT{s}-pinv(PhitT{s}(:,:,k-1))*X_s{s}(ind{s},k));
                       else
                           invA = pinv(A{s}(:,:,min(size(A{s},3),1)));
                           ut{s}(:,k) = (Q{s}*pinv(PitT{s}(:,:,1)))*PhitT{s}(:,:,1)*(yT{s}-pinv(invA*PhitT{s}(:,:,1))*X_s{s}(ind{s},k));
                       end
                       X_p{s}(ind{s},k) = X_p{s}(ind{s},k)+ut{s}(:,k);
                       W_p{s}(ind{s},ind{s},k) =W_p{s}(ind{s},ind{s},k) + (Q{s}*pinv(PitT{s}(:,:,k)))*A{s}*W_s{s}(ind{s},ind{s},k)*A{s}'*(Q{s}*pinv(PitT{s}(:,:,k)))';

                    end

                   % Update Step
                   % Fold in the neural firing in the current time step
                   [X_u{s}(ind{s},k),W_u{s}(ind{s},ind{s},k),lambdaDeltaMat{s}(:,k)] = DecodingAlgorithms.PPDecode_update(X_p{s}(ind{s},k),squeeze(W_p{s}(ind{s},ind{s},k)),dN(:,1:k),lambdaCIFColl,binwidth,k);


               end

    %            
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Step 5 - p(n_k | s_k, H_k) using Laplace approximation
               % See General-purpose filter design for neural prosthetic devices.
               % Srinivasan L, Eden UT, Mitter SK, Brown EN.
               % J Neurophysiol. 2007 Oct;98(4):2456-75. Epub 2007 May 23.
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


               for s=1:nmodels

                 tempPdf = sqrt(det(W_u{s}(:,:,k)))./sqrt(det(W_p{s}(:,:,k)))*prod(exp(dN(:,k).*log(lambdaDeltaMat{s}(:,k))-lambdaDeltaMat{s}(:,k)));
                 pNGivenS(s,k) = tempPdf;
               end
               tempData = pNGivenS(:,k);
               tempData(isinf(tempData))=0;
               pNGivenS(:,k) = tempData;

               normFact = sum(pNGivenS(:,k));
               if(normFact~=0 && ~isnan(normFact))
                pNGivenS(:,k)=pNGivenS(:,k)./sum(pNGivenS(:,k));
               else

                   if(k>1)
                       pNGivenS(:,k) = pNGivenS(:,k-1);
                   else
                       pNGivenS(:,k) = .5*ones(nmodels,1);
                   end
               end
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Step 6 - Calculate p(s_k | n_k, H_k) = p(s_k | H_k+1)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               pSGivenN(:,k) = MU_p(:,k).*pNGivenS(:,k);



               %Normalization Factor
               normFact = sum(pSGivenN(:,k));
               if(normFact~=0 && ~isnan(normFact))
                pSGivenN(:,k) = pSGivenN(:,k)./sum(pSGivenN(:,k));
               else
                   if(k>1)
                        pSGivenN(:,k) = pSGivenN(:,k-1);
                   else
                        pSGivenN(:,k) = Mu0;
                   end

               end


               MU_u(:,k) = pSGivenN(:,k); %estimate of s_k given data up to k


               [~, S_est(k)] = max(MU_u(:,k)); %Most likely current state

               if(MinClassificationError==1)

                   s= S_est(k);
                   X(ind{s},k) = X_u{s}(ind{s},k);
                   W(ind{s},ind{s},k) = W_u{s}(ind{s},ind{s},k);

               else %Minimize the mean squared error

                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   % Step 7 - Calculate p(x_k | n_k, H_k) - using gaussian
                   % approximation to mixture of gaussians 
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   for s=1:nmodels
                       X(ind{s},k) = X(ind{s},k)+MU_u(s,k)*X_u{s}(ind{s},k); 
                   end
                   for s=1:nmodels
                       W(ind{s},ind{s},k) =  W(ind{s},ind{s},k) +MU_u(s,k)*(W_u{s}(ind{s},ind{s},k) + (X_u{s}(ind{s},k)-X(ind{s},k))*(X_u{s}(ind{s},k)-X(ind{s},k))');
                   end
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               end
            end



         end   
        %% Kalman Filter 
        function [x_p, Pe_p, x_u, Pe_u,Gn] = kalman_filter(A, C, Pv, Pw, Px0, x0,y)
            %% DT Kalman Filter
            % This implements the DT Kalman filter for the system described by
            %
            % x(:,n+1) = A(:,:,n)x(:,n) + v(:,n)
            % y(:,n) = C(:,:,n)x(:,n) + w(:,n)
            %
            % where Pv(:,:,n), Pw(:,:,n) are the covariances of v(:,n) and w(:,n)
            % and Px0 is the initial state covariance.
            %
            % v(:,n), w(:,n), x(:,1) are assumed to be zero-mean.
            %
            % Return values are
            % x_p: state estimates given the past
            % Pe_p: error covariance estimates given the past
            % x_u: state updates given the data
            % Pe_u: error covariance updates given the data

            N       = size(y,2); % number of time samples in the data
            x_p     = zeros( size(A,2), N+1 );
            x_u     = zeros( size(A,2), N );
            Pe_p    = zeros( size(A,2), size(A,2), N+1 );
            Gn      = zeros( size(A,2), size(A,2), N );
            Pe_u    = zeros( size(A,2), size(A,2), N );
            
            A1=A(:,:,min(size(A,3),1));
            x_p(:,1)= A1*x0;
            Pv1=Pv(:,:,min(size(Pv,3),1));
            Pe_p(:,:,1) = A1*Px0*A1'+Pv1;

            for n=1:N
            [x_u(:,n),   Pe_u(:,:,n)]   = kalman_update( x_p(:,n), Pe_p(:,:,n), C(:,:,min(size(C,3),n)), Pw(:,:,min(size(Pw,3),n)), y(:,n));
            [x_p(:,n+1), Pe_p(:,:,n+1)] = kalman_predict(x_u(:,n), Pe_u(:,:,n), A(:,:,min(size(A,3),n)), Pv(:,:,min(size(Pv,3),n)));
            end



            %% Kalman Filter Update Equation
                function [x_u, Pe_u, G] = kalman_update(x_p, Pe_p, C, Pw, y)
                % The Kalman update step that finds the state estimate based on new
                % data
                    G       = Pe_p * C' * pinv(C * Pe_p * C' + Pw);
                    x_u     = x_p + G * (y - C * x_p);
                    Pe_u    = Pe_p - G * C * Pe_p;
                    Pe_u    = 0.5*(Pe_u + Pe_u');
                end
            %% Kalman Filter Prediction Step
                function [x_p, Pe_p] = kalman_predict(x_u, Pe_u, A, Pv)
                % The Kalman prediction step that implements the tracking system
                    x_p     = A * x_u;
                    Pe_p    = A * Pe_u * A' + Pv;
                    Pe_p    = 0.5*(Pe_p + Pe_p');
                end
        end
            
        %% Kalman Smoother
        function [x_N, P_N,Ln] = kalman_smootherFromFiltered(A, x_p, Pe_p, x_u, Pe_u)
            N=size(x_u,2);

            x_N=zeros(size(x_u));
            P_N=zeros(size(Pe_u));
            Ln = zeros(size(P_N));
            j=fliplr(1:N-1);
            x_N(:,N) = x_u(:,N);
            P_N(:,:,N) = Pe_u(:,:,N);
            for n=j

                Ln(:,:,n)=Pe_u(:,:,n)*A(:,:,min(size(A,3),n))'/Pe_p(:,:,n+1);
                x_N(:,n) = x_u(:,n)+Ln(:,:,n)*(x_N(:,n+1)-x_p(:,n+1));
                P_N(:,:,n)=Pe_u(:,:,n)+Ln(:,:,n)*(P_N(:,:,n+1)-Pe_p(:,:,n+1))*Ln(:,:,n)';
                P_N(:,:,n) = 0.5*(P_N(:,:,n)+P_N(:,:,n)');
            end    


         end
        function [x_N, P_N,Ln,x_p, Pe_p, x_u, Pe_u] = kalman_smoother(A, C, Pv, Pw, Px0, x0, y)
            %% kalman smoother
            N=size(y,2);
            [x_p, Pe_p, x_u, Pe_u] = kalman_filter(A, C, Pv, Pw, Px0, x0, y);

            x_N=zeros(size(x_u));
            P_N=zeros(size(Pe_u));
            Ln = zeros(size(P_N));
            j=fliplr(1:N-1);
            x_N(:,N) = x_u(:,N);
            P_N(:,:,N) = Pe_u(:,:,N);
            for n=j
                Ln(:,:,n)=Pe_u(:,:,n)*A(:,:,min(size(A,3),n))'/Pe_p(:,:,n+1);
                x_N(:,n) = x_u(:,n)+Ln(:,:,n)*(x_N(:,n+1)-x_p(:,n+1));
                P_N(:,:,n)=Pe_u(:,:,n)+Ln(:,:,n)*(P_N(:,:,n+1)-Pe_p(:,:,n+1))*Ln(:,:,n)';
            end
        end

        %% Functions for Point Process State Space Expectation Maximization 
        % PPSS_EMFB implements a forward and backward PPSS_EM. Because the way that the algorithm is setup,
        % we can analyze the data from the first trial to the last (forward) and from
        % the last trial to the first (backward). This approach yields
        % better estimates of the underlying firing rates
        function [xKFinal,WKFinal, WkuFinal,Qhat,gammahat,fitResults,stimulus,stimCIs,logll,QhatAll,gammahatAll,nIter]=PPSS_EMFB(A,Q0,x0,dN,fitType,delta,gamma0,windowTimes, numBasis,neuronName)
    %         if(nargin<10 || isempty(neuronName))
    %             neuronName = 1;
    %         end
            dLikelihood(1)=inf;
            if(numel(Q0)==length(Q0)^2)
                Q0=diag(Q0); %turn Q into a vector
            end

            Qhat=Q0;
            gammahat=gamma0;
            xK0=x0;
            cnt=1; tol=1e-2; maxIter=2e3;
            tolAbs = 1e-3;
            tolRel = 1e-3;
            llTol  = 1e-3;
            stoppingCriteria=0;

            minTime=0;
            maxTime=(size(dN,2)-1)*delta;

            K=size(dN,1);
            if(~isempty(windowTimes))
                histObj = History(windowTimes,minTime,maxTime);
                for k=1:K
                    nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
                    nst{k}.setMinTime(minTime);
                    nst{k}.setMaxTime(maxTime);
                    HkAll{k} = histObj.computeHistory(nst{k}).dataToMatrix;
                end
            else
                for k=1:K
                    HkAll{k} = 0;
                end
                gammahat=0;
            end


            HkAllR=HkAll(end:-1:1);
    %         if(~isempty(windowTimes))
    %             histObj = History(windowTimes,minTime,maxTime);
    %             for k=K:-11:1
    %                 nstr{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
    %                 nstr{k}.setMinTime(minTime);
    %                 nstr{k}.setMaxTime(maxTime);
    %                 HkAllR{k} = histObj.computeHistory(nstr{k}).dataToMatrix;
    %             end
    %         else
    %             for k=1:K
    %                 HkAllR{k} = 0;
    %             end
    %             gammahat=0;
    %         end

            while(stoppingCriteria~=1 && cnt<maxIter)
                display('EMFB: Forward EM');
                [xK,WK, Wku,Qhat(:,cnt+1),gammahat(cnt+1,:),logll(cnt),~,~,nIter1,negLL]=DecodingAlgorithms.PPSS_EM(A,Qhat(:,cnt),xK0,dN,fitType,delta,gammahat(cnt,:),windowTimes, numBasis,HkAll);    
                if(~negLL)
                    display('EMFB: Backward EM');
                    [xKR,~, ~,QhatR(:,cnt+1),gammahatR(cnt+1,:),logllR(cnt),~,~,nIter2,negLL]=DecodingAlgorithms.PPSS_EM(A,Qhat(:,cnt+1),xK(:,end),flipud(dN),fitType,delta,gammahat(cnt+1,:),windowTimes, numBasis,HkAllR);
                    if(~negLL)
                        display('EMFB: Forward EM');

                        [xK2,WK2, Wku2,Qhat2,gammahat2,logll2,~,~,nIter3,negLL2]=DecodingAlgorithms.PPSS_EM(A,QhatR(:,cnt+1),xKR(:,end),dN,fitType,delta,gammahatR(cnt+1,:),windowTimes, numBasis,HkAll);
                        if(~negLL2)
                            xK=xK2;
                            WK=WK2;
                            Wku=Wku2;
                            Qhat(:,cnt+1) = Qhat2;
                            gammahat(cnt+1,:) = gammahat2;
                            logll(cnt) = logll2;

                        end
                    end
                end


                xK0=xK(:,1);
                if(cnt==1)
                    dLikelihood(cnt+1)=inf;
                else
                    dLikelihood(cnt+1)=(logll(cnt)-logll(cnt-1));%./abs(logll(cnt-1));
                end
                cnt=cnt+1;

    %             figure(1)
    %         
    %             subplot(1,2,1); surf(xK);
    %             subplot(1,2,2); plot(logll); ylabel('Log Likelihood');

                dQvals = abs(sqrt(Qhat(:,cnt))-sqrt(Qhat(:,cnt-1)));
                dGamma = abs(gammahat(cnt,:)-gammahat(cnt-1,:));
                dMax = max([dQvals',dGamma]);

                dQRel = max(abs(dQvals./sqrt(Qhat(:,cnt-1))));
                dGammaRel = max(abs(dGamma./gammahat(cnt-1,:)));
                dMaxRel = max([dQRel,dGammaRel]);
    %             dMax
    %             dMaxRel
                if(dMax<tolAbs && dMaxRel<tolRel)
                    stoppingCriteria=1;
                    display(['EMFB converged at iteration:' num2str(cnt) ' b/c change in params was within criteria']);
                end
                if(abs(dLikelihood(cnt))<llTol  || dLikelihood(cnt)<0)
                    stoppingCriteria=1;
                    display(['EMFB stopped at iteration:' num2str(cnt) ' b/c change in likelihood was negative']);
                end

            end

            maxLLIndex = find(logll == max(logll),1,'first');
            if(maxLLIndex==1)
                maxLLIndex=cnt-1;
            elseif(isempty(maxLLIndex))
               maxLLIndex = 1; 
            end

            xKFinal = xK;
            x0Final=xK(:,1);
            WKFinal = WK;
            WkuFinal = Wku;
            QhatAll =Qhat(:,1:maxLLIndex+1);
            Qhat = Qhat(:,maxLLIndex+1);
            gammahatAll =gammahat(1:maxLLIndex+1);
            gammahat = gammahat(maxLLIndex+1,:);
            logll = logll(maxLLIndex);

            K=size(dN,1);
            SumXkTermsFinal = diag(Qhat(:,:,end))*K;
            logllFinal=logll(end);
            McInfo=100;
            McCI = 3000;

            nIter = [];%[nIter1,nIter2,nIter3];
  
            
            K   = size(dN,1); 
            R=size(xK,1);
            logllobs = logll+R*K*log(2*pi)+K/2*log(det(diag(Qhat)))+ 1/2*trace(diag(Qhat)\SumXkTermsFinal);

            InfoMat = DecodingAlgorithms.estimateInfoMat(fitType,dN,HkAll,A,x0Final,xKFinal,WKFinal,WkuFinal,Qhat,gammahat,windowTimes,SumXkTermsFinal,delta,McInfo);
            fitResults = DecodingAlgorithms.prepareEMResults(fitType,neuronName,dN,HkAll,xKFinal,WKFinal,Qhat,gammahat,windowTimes,delta,InfoMat,logllobs);
            [stimCIs, stimulus] = DecodingAlgorithms.ComputeStimulusCIs(fitType,xKFinal,WkuFinal,delta,McCI);
    %             

        end
        function [xKFinal,WKFinal, WkuFinal,Qhat,gammahat,logll,QhatAll,gammahatAll,nIter,negLL]=PPSS_EM(A,Q0,x0,dN,fitType,delta,gamma0,windowTimes, numBasis,Hk)
            if(nargin<9 || isempty(numBasis))
                numBasis = 20;
            end
            if(nargin<8 || isempty(windowTimes))
                if(isempty(gamma0))
                    windowTimes =[];
                else
    %                 numWindows =length(gamma0)+1; 
                    windowTimes = 0:delta:(length(gamma0)+1)*delta;
                end
            end
            if(nargin<7)
                gamma0=[];
            end
            if(nargin<6 || isempty(delta))
                delta = .001;
            end
            if(nargin<5)
                fitType = 'poisson';
            end


            minTime=0;
            maxTime=(size(dN,2)-1)*delta;
            K=size(dN,1);




    %         tol = 1e-3; %absolute change;
            tolAbs = 1e-3;
            tolRel = 1e-3;
            llTol  = 1e-3;
            cnt=1;

            maxIter = 100;

            if(numel(Q0)==length(Q0)^2)
                Q0=diag(Q0); %turn Q into a vector
            end
               numToKeep=10;
            Qhat = zeros(length(Q0),numToKeep);
            Qhat(:,1)=Q0;
            gammahat=zeros(numToKeep,length(gamma0));
            gammahat(1,:)=gamma0;
%             QhatNew=Q0;
%             gammahatNew(1,:)=gamma0;
            cnt=1;
            dLikelihood(1)=inf;
    %         logll(1)=-inf;
            x0hat = x0;
            negLL=0;
         
            %Forward EM
            stoppingCriteria =0;
%             logllNew= -inf;
            while(stoppingCriteria~=1 && cnt<=maxIter)
                 storeInd = mod(cnt-1,numToKeep)+1; %make zero-based then mod, then add 1
                 storeIndP1= mod(cnt,numToKeep)+1;
                 storeIndM1= mod(cnt-2,numToKeep)+1;
                [xK{storeInd},WK{storeInd},Wku{storeInd},logll(cnt),SumXkTerms,sumPPll]= ...
                    DecodingAlgorithms.PPSS_EStep(A,Qhat(:,storeInd),x0hat,dN,Hk,fitType,delta,gammahat(storeInd,:),numBasis);
             
                [Qhat(:,storeIndP1),gammahat(storeIndP1,:)] = DecodingAlgorithms.PPSS_MStep(dN,Hk,fitType,xK{storeInd},WK{storeInd},gammahat(storeInd,:),delta,SumXkTerms,windowTimes);
                if(cnt==1)
                    dLikelihood(cnt+1)=inf;
                else
                    dLikelihood(cnt+1)=(logll(cnt)-logll(cnt-1));%./abs(logll(cnt-1));
                end

                if(mod(cnt,25)==0)
                    figure(1);
                    subplot(1,2,1); surf(xK{storeInd});
                    subplot(1,2,2); plot(logll); ylabel('Log Likelihood');
                end
                cnt=(cnt+1);
                dQvals = abs(sqrt(Qhat(:,storeInd))-sqrt(Qhat(:,storeIndM1)));
                dGamma = abs(gammahat(storeInd,:)-gammahat(storeIndM1,:));
                dMax = max([dQvals',dGamma]);

                dQRel = max(abs(dQvals./sqrt(Qhat(:,storeIndM1))));
                dGammaRel = max(abs(dGamma./gammahat(storeIndM1,:)));
                dMaxRel = max([dQRel,dGammaRel]);

             
                
                if(dMax<tolAbs && dMaxRel<tolRel)
                    stoppingCriteria=1;
                    display(['         EM converged at iteration# ' num2str(cnt) ' b/c change in params was within criteria']);
                    negLL=0;
                end
                if(abs(dLikelihood(cnt))<llTol  || dLikelihood(cnt)<0)
                    stoppingCriteria=1;
                    display(['         EM stopped at iteration# ' num2str(cnt) ' b/c change in likelihood was negative']);
                    negLL=1;
                end
                

            end


            maxLLIndex  = find(logll == max(logll),1,'first');
            maxLLIndMod =  mod(maxLLIndex-1,numToKeep)+1;
            if(maxLLIndex==1)
%                 maxLLIndex=cnt-1;
                maxLLIndex =1;
                maxLLIndMod = 1;
            elseif(isempty(maxLLIndex))
               maxLLIndex = 1; 
               maxLLIndMod = 1;
%             else
%                maxLLIndMod = mod(maxLLIndex,numToKeep); 
               
            end
            nIter   = cnt-1;  
%             maxLLIndMod
            xKFinal = xK{maxLLIndMod};
            WKFinal = WK{maxLLIndMod};
            WkuFinal = Wku{maxLLIndMod};
            QhatAll =Qhat(:,1:maxLLIndMod);
            Qhat = Qhat(:,maxLLIndMod);
            gammahatAll =gammahat(1:maxLLIndMod);
            gammahat = gammahat(maxLLIndMod,:);
            logll = logll(maxLLIndex);
           
        end
        
        % Subroutines for the PPSS_EM algorithm
        function [x_K,W_K,Wku,logll,sumXkTerms,sumPPll]=PPSS_EStep(A,Q,x0,dN,HkAll,fitType,delta,gamma,numBasis)


             minTime=0;
             maxTime=(size(dN,2)-1)*delta;


             if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
             end
            if(numel(Q)==length(Q))
                Q=diag(Q); %turn Q into a diagonal matrix
            end
            [K,N]   = size(dN); 
            R=size(basisMat,2);

            x_p     = zeros( size(A,2), K );
            x_u     = zeros( size(A,2), K );
            W_p    = zeros( size(A,2),size(A,2), K);
            W_u    = zeros( size(A,2),size(A,2), K );



            for k=1:K

                if(k==1)
                    x_p(:,k)     = A * x0;
                    W_p(:,:,k)   = Q;
                else
                    x_p(:,k)     = A * x_u(:,k-1);
                    W_p(:,:,k)   = A * W_u(:,:,k-1) * A' + Q;
                end

                 sumValVec=zeros(size(W_p,1),1);
                 sumValMat=zeros(size(W_p,2),size(W_p,2));



                if(strcmp(fitType,'poisson'))
                    Hk=HkAll{k};
                    Wk = basisMat*diag(W_p(:,:,k));
                    stimK=basisMat*x_p(:,k);

                    histEffect=exp(gamma*Hk')';
                    stimEffect=exp(stimK);
                    lambdaDelta =stimEffect.*histEffect;
                    GradLogLD =basisMat;
                    JacobianLogLD = zeros(R,R);
                    GradLD = basisMat.*repmat(lambdaDelta,[1 R]);

                    sumValVec = GradLogLD'*dN(k,:)' - diag(GradLD'*basisMat);
                    sumValMat = GradLD'*basisMat;


                elseif(strcmp(fitType,'binomial'))
                    Hk=HkAll{k};
                    Wk = basisMat*diag(W_p(:,:,k));
                    stimK=basisMat*x_p(:,k);

                    lambdaDelta=exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));  
                    GradLogLD =basisMat.*(repmat(1-lambdaDelta,[1 R]));
                    JacobianLogLD = basisMat.*repmat(lambdaDelta.*(-1+lambdaDelta),[1 R]);
                    GradLD = basisMat.*(repmat(lambdaDelta.*(1-lambdaDelta),[1 R]));
                    JacobianLD = basisMat.*(repmat(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta.^2),[1 R]));

                    sumValVec = GradLogLD'*dN(k,:)' - diag(GradLD'*basisMat);
                    sumValMat = -diag(JacobianLogLD'*dN(k,:)')+ JacobianLD'*basisMat;

                end  


%                  invW_u             = pinv(W_p(:,:,k))+ sumValMat;
%                  W_u(:,:,k)       = pinv(invW_u);% +100*diag(eps*rand(size(W_p,1),1));
%                  
                 

                 invW_u             = eye(size(W_p(:,:,k)))/W_p(:,:,k)+ sumValMat;
                 W_u(:,:,k)       = eye(size(invW_u))/invW_u;% +100*diag(eps*rand(size(W_p,1),1));


                 % Maintain Positive Definiteness
                % Make sure eigenvalues are positive
                [vec,val]=eig(W_u(:,:,k) ); val(val<=0)=eps;
                W_u(:,:,k) =vec*val*vec';
                x_u(:,k)      = x_p(:,k)  + W_u(:,:,k)*(sumValVec);

            end

            [x_K, W_K,Lk] = DecodingAlgorithms.kalman_smootherFromFiltered(A, x_p, W_p, x_u, W_u);


            Wku=zeros(R,R,K,K);
            Tk = zeros(R,R,K-1);
            for k=1:K
                Wku(:,:,k,k)=W_K(:,:,k);
            end

            for u=K:-1:2
                for k=(u-1):-1:1
                    Tk(:,:,k)=A;
%                     Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'*pinv(W_p(:,:,k)); %From deJong and MacKinnon 1988
                     Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'/(W_p(:,:,k+1)); %From deJong and MacKinnon 1988
                    Wku(:,:,k,u)=Dk(:,:,k)*Wku(:,:,k+1,u);
                    Wku(:,:,u,k)=Wku(:,:,k,u);
                end
            end
   

            %All terms
            Sxkxkp1 = zeros(R,R);
            Sxkp1xkp1 = zeros(R,R);
            Sxkxk = zeros(R,R);
            for k=1:K-1
%                Sxkxkp1 = Sxkxkp1+x_u(:,k)*x_K(:,k+1)'+ ...
%                    Lk(:,:,k)*(W_K(:,:,k+1)+(x_K(:,k+1)-x_p(:,k+1))*x_K(:,k+1)');
               Sxkxkp1 = Sxkxkp1+Wku(:,:,k,k+1)+x_K(:,k)*x_K(:,k+1)';
               Sxkp1xkp1 = Sxkp1xkp1+W_K(:,:,k+1)+x_K(:,k+1)*x_K(:,k+1)';
               Sxkxk = Sxkxk+W_K(:,:,k)+x_K(:,k)*x_K(:,k)';

            end

            sumXkTerms =  Sxkp1xkp1-A*Sxkxkp1-Sxkxkp1'*A'+A*Sxkxk*A'+ ...
                          W_K(:,:,1)+x_K(:,1)*x_K(:,1)' + ... %expected value of xK(1)^2
                          -A*x0*x_K(:,1)' -x_K(:,1)*x0'*A' +A*(x0*x0')*A';


            if(strcmp(fitType,'poisson'))
                sumPPll=0;
                for k=1:K
                    Hk=HkAll{k};
                    Wk = basisMat*diag(W_K(:,:,k));
                    stimK=basisMat*x_K(:,k);
                    histEffect=exp(gamma*Hk')';
                    stimEffect=exp(stimK)+exp(stimK)/2.*Wk;
        %             stimEffect=exp(stimK  + Wk*0.5);
                    ExplambdaDelta =stimEffect.*histEffect;
                    ExplogLD = (stimK + (gamma*Hk')');
                    sumPPll=sum(dN(k,:)'.*ExplogLD - ExplambdaDelta);

                end
            elseif(strcmp(fitType,'binomial'))

                sumPPll=0;
                for k=1:K
                    Hk=HkAll{k};
                    Wk = basisMat*diag(W_K(:,:,k));
                    stimK=basisMat*x_K(:,k);
                    lambdaDelta = exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));
                    ExplambdaDelta=lambdaDelta+Wk.*(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta))/2;  
            %       logLD = stimK+(gamma*Hk')' - log(1+lambdaDelta)
                    ExplogLD = stimK+(gamma*Hk')' - log(1+exp(stimK+(gamma*Hk')')) -Wk.*(lambdaDelta).*(1-lambdaDelta)*.5;
                    %E(f(x)]=f(x_hat) + 1/2sigma_x^2 * d^2/dx*f(x_hat)
                    %This is applied to log(1+exp(x_K))
            %         
                    sumPPll=sum(dN(k,:)'.*ExplogLD - ExplambdaDelta);
                end

            end
            R=numBasis;

            logll = -R*K*log(2*pi)-K/2*log(det(Q))  + sumPPll - 1/2*trace(pinv(Q)*sumXkTerms);


        end
        function [Qhat,gamma_new] = PPSS_MStep(dN,HkAll,fitType,x_K,W_K,gamma, delta,sumXkTerms,windowTimes)
             K=size(dN,1);
             N=size(dN,2);


             sumQ =  diag(diag(sumXkTerms));
             Qhat = sumQ*(1/K);

             [vec,val]=eig(Qhat); val(val<=0)=0.00000001;
             Qhat =vec*val*vec';
             Qhat = (diag(Qhat));


             minTime=0;
             maxTime=(size(dN,2)-1)*delta;

             numBasis = size(x_K,1);
             if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
             end




            gamma_new = gamma;

            if(~isempty(windowTimes) && all(gamma_new~=0))
                converged=0;
                iter = 1;
                maxIter=300;
                while(~converged && iter<maxIter)
        %         disp(['      - Newton-Raphson alg. iter #',num2str(iter)])
                    if(strcmp(fitType,'poisson'))

                            gradQ=zeros(size(gamma_new,2),1);
                            jacQ =zeros(size(gamma_new,2),size(gamma_new,2));
                        for k=1:K
                            Hk=HkAll{k};

                            Wk = basisMat*diag(W_K(:,:,k));
                            stimK=basisMat*(x_K(:,k));
                            histEffect=exp(gamma_new*Hk')';
                            stimEffect=exp(stimK)+exp(stimK)/2.*Wk;
    %                         stimEffect=exp(stimK+Wk*0.5);
                            lambdaDelta = stimEffect.*histEffect;

                            gradQ = gradQ + Hk'*dN(k,:)' - Hk'*lambdaDelta;
    %                         jacQ  = jacQ  - diag(diag((Hk.*repmat(lambdaDelta,[1 size(Hk,2)]))'*Hk));
                            jacQ  = jacQ  - (Hk.*repmat(lambdaDelta,[1 size(Hk,2)]))'*Hk;
                        end



                    elseif(strcmp(fitType,'binomial'))
                            gradQ=zeros(size(gamma_new,2),1);
                            jacQ =zeros(size(gamma_new,2),size(gamma_new,2));
                         for k=1:K
                            Hk=HkAll{k};

                            Wk = basisMat*diag(W_K(:,:,k));
                            stimK=basisMat*(x_K(:,k));

                            histEffect=exp(gamma_new*Hk')';
                            stimEffect=exp(stimK);
    %                         stimEffect=exp(stimK+Wk*0.5);
                            C = stimEffect.*histEffect;
                            M = 1./C;
                            lambdaDelta = exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));
                            ExpLambdaDelta = lambdaDelta+Wk.*(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta))/2;
                            ExpLDSquaredTimesInvExp = (lambdaDelta).^2.*1./C;
                            ExpLDCubedTimesInvExpSquared = (lambdaDelta).^3.*M.^2 +Wk/2.*(3.*M.^4.*lambdaDelta.^3+12.*lambdaDelta.^3.*M.^3-12.*M.^4.*lambdaDelta.^4);

    %                         ExpLambdaDeltaTimesExp = C.*lambdaDelta + (2.*C.*lambdaDelta-3*C.*lambdaDelta.*lambdaDelta).*Wk/2;
    %                         ExpLambdaDeltaTimesExpSquared = C.^2.*lambdaDelta + (7.*C.^2.*lambdaDelta-5*C.^2.*lambdaDelta.*lambdaDelta).*Wk/2;

    %                         lambdaDelta = C./(1+C);

    %                         gradQ = gradQ + (Hk.*repmat(1-lambdaDelta,[1,size(Hk,2)]))'*dN(k,:)' ...
    %                                       - (Hk.*repmat(C,[1,size(Hk,2)]))'*lambdaDelta;
    %                         jacQ  = jacQ  - (Hk.*repmat(C.*lambdaDelta.*dN(k,:)',[1,size(Hk,2)]))'*Hk ...
    %                                       - (Hk.*repmat(lambdaDelta,[1,size(Hk,2)]))'*Hk ...
    %                                       - (Hk.*repmat(C.^2.*lambdaDelta,[1,size(Hk,2)]))'*Hk;
                            gradQ = gradQ + (Hk.*repmat(1-ExpLambdaDelta,[1,size(Hk,2)]))'*dN(k,:)' ...
                                          - (Hk.*repmat(ExpLDSquaredTimesInvExp./lambdaDelta,[1,size(Hk,2)]))'*lambdaDelta;
                            jacQ  = jacQ  - (Hk.*repmat(ExpLDSquaredTimesInvExp.*dN(k,:)',[1,size(Hk,2)]))'*Hk ...
                                          - (Hk.*repmat(ExpLDSquaredTimesInvExp,[1,size(Hk,2)]))'*Hk ...
                                          - (Hk.*repmat(2*ExpLDCubedTimesInvExpSquared,[1,size(Hk,2)]))'*Hk;

                         end


                    end

                    gamma_newTemp = (gamma_new'-pinv(jacQ)*gradQ)';
                    if(any(isnan(gamma_newTemp)))
                        gamma_newTemp = gamma_new;
    %                     gradQ=max(gradQ,-10);
    %                     gradQ=min(gradQ,10);
    %                     gamma_newTemp = (gamma_new' - jacQ\gradQ)';
    %                     if(any(isnan(gamma_newTemp)))
    %                         if(isinf(gamma_new))
    %                             gamma_newTemp(isinf(gamma_new))=-5;
    %                         else
    %                             gamma_newTemp=gamma_new;    
    %                         end
    %                         
    %                     end
    %                 elseif(abs(gamma_newTemp)>1e1)
    %                     gamma_newTemp = sign(gamma_newTemp)*1e1;
                    end
                    mabsDiff = max(abs(gamma_newTemp - gamma_new));
                    if(mabsDiff<10^-2)
                        converged=1;
                    end
                    gamma_new=gamma_newTemp;
                    iter=iter+1;
                end
                %Keep gamma from getting too large since this effect is
                %exponentiated
                gamma_new(gamma_new>1e2)=1e1;
                gamma_new(gamma_new<-1e2)=-1e1;
            end

    %          pause;
        end
        function fitResults=prepareEMResults(fitType,neuronNumber,dN,HkAll,xK,WK,Q,gamma,windowTimes,delta,informationMatrix,logll)


            [numBasis, K] =size(xK);
            SE = sqrt(abs(diag(inv(informationMatrix))));
            xKbeta = reshape(xK,[numel(xK) 1]);
            seXK=[];
            for k=1:K
                seXK   = [seXK; sqrt(diag(WK(:,:,k)))];
            end
            statsStruct.beta=[xKbeta;(Q(:,end));gamma(end,:)'];
            statsStruct.se  =[seXK;SE];
            covarianceLabels = cell(1,numBasis);
            for r=1:numBasis
                if(r<10)
                    covarianceLabels{r} =  ['Q0' num2str(r)];
                else
                    covarianceLabels{r} =  ['Q' num2str(r)];
                end
            end

            minTime=0;
            maxTime=(size(dN,2)-1)*delta;
            if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
            end

            nst = cell(1,K);
            if(~isempty(windowTimes))
                histObj{1} = History(windowTimes,minTime,maxTime);
            else
                histObj{1} = [];
            end

            if(isnumeric(neuronNumber))
                name=num2str(neuronNumber);
                if(neuronNumber>0 && neuronNumber<10)
                    name = strcat(num2str(0),name);
                end
                name = ['N' name];  
            else
                name = neuronNumber;
            end

            for k=1:K
                nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta,name);
                nst{k}.setMinTime(minTime);
                nst{k}.setMaxTime(maxTime);

            end

            nCopy = nstColl(nst);
            nCopy = nCopy.toSpikeTrain;
            lambdaData=[];
            cnt=1;

            for k=1:K
                Hk=HkAll{k};
                stimK=basisMat*xK(:,k);


                if(strcmp(fitType,'poisson'))
                    histEffect=exp(gamma(end,:)*Hk')';
                    stimEffect=exp(stimK);
                    lambdaDelta = histEffect.*stimEffect;
                    lambdaData = [lambdaData;lambdaDelta/delta];
                elseif(strcmp(fitType,'binomial'))
                    histEffect=exp(gamma(end,:)*Hk')';
                    stimEffect=exp(stimK);
                    lambdaDelta = histEffect.*stimEffect;
                    lambdaDelta = lambdaDelta./(1+lambdaDelta);
                    lambdaData = [lambdaData;lambdaDelta/delta];
                end


                for r=1:numBasis
                        if(r<10)
                            otherLabels{cnt} = ['b0' num2str(r) '_{' num2str(k) '}']; 
                        else
                            otherLabels{cnt} = ['b' num2str(r) '_{' num2str(k) '}'];
                        end
                        cnt=cnt+1;
                end
            end

            lambdaTime = minTime:delta:(length(lambdaData)-1)*delta;
            nCopy.setMaxTime(max(lambdaTime));
            nCopy.setMinTime(min(lambdaTime));

            numLabels = length(otherLabels);
            if(~isempty(windowTimes))
                histLabels  = histObj{1}.computeHistory(nst{1}).getCovLabelsFromMask;
            else
                histLabels = [];
            end
            otherLabels((numLabels+1):(numLabels+length(covarianceLabels)))=covarianceLabels;
            numLabels = length(otherLabels);

            tc{1} = TrialConfig(otherLabels,sampleRate,histObj,[]); 
            numBasisStr=num2str(numBasis);
            numHistStr = num2str(length(windowTimes)-1);
            if(~isempty(histObj))
                tc{1}.setName(['SSGLM(N_{b}=', numBasisStr,')+Hist(N_{h}=' ,numHistStr,')']);
            else
                tc{1}.setName(['SSGLM(N_{b}=', numBasisStr,')']);
            end
            configColl= ConfigColl(tc);


            otherLabels((numLabels+1):(numLabels+length(histLabels)))=histLabels;




            labels{1}  = otherLabels; % Labels change depending on presence/absense of History or ensCovHist
            if(~isempty(windowTimes))
                numHist{1} = length(histObj{1}.windowTimes)-1;
            else 
                numHist{1}=[];
            end

            ensHistObj{1} = [];
            lambdaIndexStr=1;
            lambda=Covariate(lambdaTime,lambdaData,...
                           '\Lambda(t)','time',...
                           's','Hz',strcat('\lambda_{',lambdaIndexStr,'}'));


            AIC = 2*length(otherLabels)-2*logll;
            BIC = -2*logll+length(otherLabels)*log(length(lambdaData));

            dev=-2*logll;
            b{1} = statsStruct.beta;
            stats{1} = statsStruct;

            distrib{1} =fitType;
            currSpikes=nst;%nspikeColl.getNST(tObj.getNeuronIndFromName(neuronNames));
            for n=1:length(currSpikes)
                currSpikes{n} = currSpikes{n}.nstCopy;
                currSpikes{n}.setName(nCopy.name);
            end
            XvalData{1} = [];
            XvalTime{1} = [];
            spikeTraining = currSpikes;


            fitResults=FitResult(spikeTraining,labels,numHist,histObj,ensHistObj,lambda,b, dev, stats,AIC,BIC,configColl,XvalData,XvalTime,distrib);
            DTCorrection=1;
            makePlot=0;
            Analysis.KSPlot(fitResults,DTCorrection,makePlot);
            Analysis.plotInvGausTrans(fitResults,makePlot);
            Analysis.plotFitResidual(fitResults,[],makePlot); 
        end
        function [CIs, stimulus]  = ComputeStimulusCIs(fitType,xK,Wku,delta,Mc,alphaVal)
            if(nargin<6 ||isempty(alphaVal))
                alphaVal =.05;
            end
            if(nargin<5 ||isempty(Mc))
                Mc=3000;
            end
            [numBasis,K]=size(xK);


           for r=1:numBasis  
                WkuTemp=squeeze(Wku(r,r,:,:));
    %             [vec,val]=eig(Wku ); val(val<=0)=eps;
    %             Wku =vec*val*vec';
                [chol_m,p]=chol(WkuTemp);
                if(numel(chol_m)==1)
                    chol_m = diag(repmat(chol_m,[K 1]));
                end
                for c=1:Mc % for r-th step function simulate the path of size K
                    z=zeros(K,1);
                    z=normrnd(0,1,K,1);
                    xKDraw(r,:,c)=xK(r,:)+(chol_m'*z)';
    %                 stimulusDraw(r,:,c) = exp(xKDraw(r,:,c))/delta;
                    if(strcmp(fitType,'poisson'))
                        stimulusDraw(r,:,c) =  exp(xKDraw(r,:,c))/delta;
                    elseif(strcmp(fitType,'binomial'))
                        stimulusDraw(r,:,c) = exp(xKDraw(r,:,c))./(1+exp(xKDraw(r,:,c)))/delta;
                    end
                end
           end

           CIs = zeros(size(xK,1),size(xK,2),2);
           for r=1:numBasis
               for k=1:K
                   [f,x] = ecdf(squeeze(stimulusDraw(r,k,:)));
                    CIs(r,k,1) = x(find(f<alphaVal/2,1,'last'));
                    CIs(r,k,2) = x(find(f>(1-(alphaVal/2)),1,'first'));
               end
           end

           if(nargout==2)
               if(strcmp(fitType,'poisson'))
                    stimulus =  exp(xK)/delta;
               elseif(strcmp(fitType,'binomial'))
                    stimulus = exp(xK)./(1+exp(xK))/delta;
               end
           end


        end
        function InfoMatrix=estimateInfoMat(fitType,dN,HkAll,A,x0,xK,WK,Wku,Q,gamma,windowTimes,SumXkTerms,delta,Mc)
            if(nargin<14)
                Mc=500;
            end

            [K,N]=size(dN);
            if(~isempty(windowTimes))
                J=max(size(gamma(end,:)));
            else
                J=0;
            end

            R=size(Q,1);
            numBasis = R;

            % The complete data information matrix
            Ic=zeros(J+R,J+R);
            Q=(diag(Q)); % Make sure Q is diagonal matrix


            X=((SumXkTerms));
            Ic(1:R,1:R) = K/2*eye(size(Q))/Q^2 +X'/Q^3;


            % Compute information of history terms
            minTime=0;
            maxTime=(size(dN,2)-1)*delta;
    %         nst = cell(1,K);
    %         if(~isempty(windowTimes))
    %             histObj = History(windowTimes,minTime,maxTime);
    %             for k=1:K
    %                 nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
    %                 nst{k}.setMinTime(minTime);
    %                 nst{k}.setMaxTime(maxTime);
    %                 Hn{k} = histObj.computeHistory(nst{k}).dataToMatrix;
    %             end
    %         else
    %             for k=1:K
    %                 Hn{k} = 0;
    %             end
    %             gamma=0;
    %         end

             if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
             end

            jacQ =zeros(size(gamma,2),size(gamma,2));
            if(strcmp(fitType,'poisson'))
                for k=1:K
                    Hk=HkAll{k};

                    Wk = basisMat*diag(WK(:,:,k));
                    stimK=basisMat*(xK(:,k));
                    histEffect=exp(gamma*Hk')';
                    stimEffect=exp(stimK)+exp(stimK)/2.*Wk;
                    lambdaDelta = stimEffect.*histEffect;

                    jacQ  = jacQ  - (Hk.*repmat(lambdaDelta,[1 size(Hk,2)]))'*Hk;
                end

             elseif(strcmp(fitType,'binomial'))
                 for k=1:K
                    Hk=HkAll{k};
                    Wk = basisMat*diag(WK(:,:,k));
                    stimK=basisMat*(xK(:,k));

                    histEffect=exp(gamma*Hk')';
                    stimEffect=exp(stimK);
                    C = stimEffect.*histEffect;
                    M = 1./C;
                    lambdaDelta = exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));
                    ExpLambdaDelta = lambdaDelta+Wk.*(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta))/2;
                    ExpLDSquaredTimesInvExp = (lambdaDelta).^2.*1./C;
                    ExpLDCubedTimesInvExpSquared = (lambdaDelta).^3.*M.^2 +Wk/2.*(3.*M.^4.*lambdaDelta.^3+12.*lambdaDelta.^3.*M.^3-12.*M.^4.*lambdaDelta.^4);

                    jacQ  = jacQ  - (Hk.*repmat(ExpLDSquaredTimesInvExp.*dN(k,:)',[1,size(Hk,2)]))'*Hk ...
                                  - (Hk.*repmat(ExpLDSquaredTimesInvExp,[1,size(Hk,2)]))'*Hk ...
                                  - (Hk.*repmat(2*ExpLDCubedTimesInvExpSquared,[1,size(Hk,2)]))'*Hk;

                 end


            end           

            Ic(1:R,1:R)=K*eye(size(Q))/(2*(Q)^2)+(eye(size(Q))/((Q)^3))*SumXkTerms;

            if(~isempty(windowTimes))
                Ic((R+1):(R+J),(R+1):(R+J)) = -jacQ;
            end
            xKDraw = zeros(numBasis,K,Mc);
            for r=1:numBasis  
                WkuTemp=squeeze(Wku(r,r,:,:));
    %             [vec,val]=eig(Wku ); val(val<=0)=eps;
    %             Wku =vec*val*vec';
                [chol_m,p]=chol(WkuTemp);
                if(numel(chol_m)==1)
                    chol_m = diag(repmat(chol_m,[K 1]));
                end
                for c=1:Mc % for r-th step function simulate the path of size K
                    z=zeros(K,1);
                    z=normrnd(0,1,K,1);
                    xKDraw(r,:,c)=xK(r,:)+(chol_m'*z)';
                end
            end



            Im=zeros(J+R,J+R);
            ImMC=zeros(J+R,J+R);

            for c=1:Mc

                gradQGammahat=zeros(size(gamma,2),1);
                gradQQhat=zeros(1,R);        
                if(strcmp(fitType,'poisson'))
                    for k=1:K
                        Hk=HkAll{k};
                        stimK=basisMat*(xKDraw(:,k,c));
                        histEffect=exp(gamma*Hk')';
                        stimEffect=exp(stimK);
                        lambdaDelta = stimEffect.*histEffect;
                        gradQGammahat = gradQGammahat + Hk'*dN(k,:)' - Hk'*lambdaDelta;
                        if(k==1)
                            gradQQhat = ((xKDraw(:,k,c)-A*x0).*(xKDraw(:,k,c)-A*x0));
                        else
                            gradQQhat = gradQQhat+((xKDraw(:,k,c)-A*xKDraw(:,k-1,c)).*(xKDraw(:,k,c)-A*xKDraw(:,k-1,c)));
                        end

                    end
                elseif(strcmp(fitType,'binomial'))
                     for k=1:K
                        Hk=HkAll{k};
                        Wk = basisMat*diag(WK(:,:,k));
                        stimK=basisMat*(xKDraw(:,k,c));

                        histEffect=exp(gamma*Hk')';
                        stimEffect=exp(stimK);
    %                   
                        C = stimEffect.*histEffect;
                        M = 1./C;
                        lambdaDelta = exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));
                        ExpLambdaDelta = lambdaDelta+Wk.*(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta))/2;
                        ExpLDSquaredTimesInvExp = (lambdaDelta).^2.*1./C;
                        ExpLDCubedTimesInvExpSquared = (lambdaDelta).^3.*M.^2 +Wk/2.*(3.*M.^4.*lambdaDelta.^3+12.*lambdaDelta.^3.*M.^3-12.*M.^4.*lambdaDelta.^4);


                        gradQGammahat = gradQGammahat + (Hk.*repmat(1-ExpLambdaDelta,[1,size(Hk,2)]))'*dN(k,:)' ...
                                          - (Hk.*repmat(ExpLDSquaredTimesInvExp./lambdaDelta,[1,size(Hk,2)]))'*lambdaDelta;
                        if(k==1)
                            gradQQhat = ((xKDraw(:,k,c)-A*x0).*(xKDraw(:,k,c)-A*x0));
                        else
                            gradQQhat = gradQQhat+((xKDraw(:,k,c)-A*xKDraw(:,k-1,c)).*(xKDraw(:,k,c)-A*xKDraw(:,k-1,c)));
                        end
                     end


                end

                gradQQhat = .5*eye(size(Q))/Q*gradQQhat - diag(K/2*eye(size(Q))/Q^2);
                ImMC(1:R,1:R)=ImMC(1:R,1:R)+gradQQhat*gradQQhat';
                if(~isempty(windowTimes))
                    ImMC((R+1):(R+J),(R+1):(R+J)) = ImMC((R+1):(R+J),(R+1):(R+J))+diag(diag(gradQGammahat*gradQGammahat'));
                end
            end
            Im=ImMC/Mc;

            InfoMatrix=Ic-Im; % Observed information matrix



        end
        function [spikeRateSig, ProbMat,sigMat]=computeSpikeRateCIs(xK,Wku,dN,t0,tf,fitType,delta,gamma,windowTimes,Mc,alphaVal)
             if(nargin<11 ||isempty(alphaVal))
                alphaVal =.05;
            end
            if(nargin<10 ||isempty(Mc))
                Mc=500;
            end

            [numBasis,K]=size(xK);

            minTime=0;
            maxTime=(size(dN,2)-1)*delta;

            if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
            end


    %         K=size(dN,1);
            if(~isempty(windowTimes))
                histObj = History(windowTimes,minTime,maxTime);
                for k=1:K
                    nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
                    nst{k}.setMinTime(minTime);
                    nst{k}.setMaxTime(maxTime);
                    Hk{k} = histObj.computeHistory(nst{k}).dataToMatrix;
                end
            else
                for k=1:K
                    Hk{k} = 0;
                end
                gamma=0;
            end

           for r=1:numBasis  
                WkuTemp=squeeze(Wku(r,r,:,:));
    %             [vec,val]=eig(Wku ); val(val<=0)=eps;
    %             Wku =vec*val*vec';
                [chol_m,p]=chol(WkuTemp);
                if(numel(chol_m)==1)
                    chol_m = diag(repmat(chol_m,[K 1]));
                end
                for c=1:Mc % for r-th step function simulate the path of size K
                    z=zeros(K,1);
                    z=normrnd(0,1,K,1);
                    xKDraw(r,:,c)=xK(r,:)+(chol_m'*z)';
                end
           end

           time=minTime:delta:maxTime;
           for c=1:Mc
               for k=1:K

                   if(strcmp(fitType,'poisson'))
                        stimK=basisMat*xKDraw(:,k,c);
                        histEffect=exp(gamma*Hk{k}')';
                        stimEffect=exp(stimK);
                        lambdaDelta(:,k,c) =stimEffect.*histEffect;
                   elseif(strcmp(fitType,'binomial'))
                        stimK=basisMat*xKDraw(:,k,c);
                        lambdaDelta(:,k,c)=exp(stimK+(gamma*Hk{k}')')./(1+exp(stimK+(gamma*Hk{k}')'));  
                   end  


               end
               lambdaC=Covariate(time,lambdaDelta(:,:,c)/delta,'\Lambda(t)');
               lambdaCInt= lambdaC.integral;
               spikeRate(c,:) = (1/(tf-t0))*(lambdaCInt.getValueAt(tf)-lambdaCInt.getValueAt(t0));

           end

           CIs = zeros(K,2);
           for k=1:K
               [f,x] = ecdf(spikeRate(:,k));
                CIs(k,1) = x(find(f<alphaVal,1,'last'));
                CIs(k,2) = x(find(f>(1-(alphaVal)),1,'first'));
           end
           spikeRateSig = Covariate(1:K, mean(spikeRate),['(' num2str(tf) '-' num2str(t0) ')^-1 * \Lambda(' num2str(tf) '-' num2str(t0) ')'],'Trial','k','Hz');
           ciSpikeRate = ConfidenceInterval(1:K,CIs,'CI_{spikeRate}','Trial','k','Hz');
           spikeRateSig.setConfInterval(ciSpikeRate);


           if(nargout>1)
               ProbMat = zeros(K,K);
               for k=1:K
                   for m=(k+1):K

                       ProbMat(k,m)=sum(spikeRate(:,m)>spikeRate(:,k))./Mc;
                   end
               end
           end


           if(nargout>2)
                sigMat= double(ProbMat>(1-alphaVal));
           end


        end
        function [spikeRateSig, ProbMat,sigMat]=computeSpikeRateDiffCIs(xK,Wku,dN,time1,time2,fitType,delta,gamma,windowTimes,Mc,alphaVal)
             if(nargin<11 ||isempty(alphaVal))
                alphaVal =.05;
            end
            if(nargin<10 ||isempty(Mc))
                Mc=500;
            end

            [numBasis,K]=size(xK);

            minTime=0;
            maxTime=(size(dN,2)-1)*delta;

            if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
            end


    %         K=size(dN,1);
            if(~isempty(windowTimes))
                histObj = History(windowTimes,minTime,maxTime);
                for k=1:K
                    nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
                    nst{k}.setMinTime(minTime);
                    nst{k}.setMaxTime(maxTime);
                    Hk{k} = histObj.computeHistory(nst{k}).dataToMatrix;
                end
            else
                for k=1:K
                    Hk{k} = 0;
                end
                gamma=0;
            end

           for r=1:numBasis  
                WkuTemp=squeeze(Wku(r,r,:,:));
    %             [vec,val]=eig(Wku ); val(val<=0)=eps;
    %             Wku =vec*val*vec';
                [chol_m,p]=chol(WkuTemp);
                if(numel(chol_m)==1)
                    chol_m = diag(repmat(chol_m,[K 1]));
                end
                for c=1:Mc % for r-th step function simulate the path of size K
                    z=zeros(K,1);
                    z=normrnd(0,1,K,1);
                    xKDraw(r,:,c)=xK(r,:)+(chol_m'*z)';
                end
           end

           timeWindow=minTime:delta:maxTime;
           for c=1:Mc
               for k=1:K

                   if(strcmp(fitType,'poisson'))
                        stimK=basisMat*xKDraw(:,k,c);
                        histEffect=exp(gamma*Hk{k}')';
                        stimEffect=exp(stimK);
                        lambdaDelta(:,k,c) =stimEffect.*histEffect;
                   elseif(strcmp(fitType,'binomial'))
                        stimK=basisMat*xKDraw(:,k,c);
                        lambdaDelta(:,k,c)=exp(stimK+(gamma*Hk{k}')')./(1+exp(stimK+(gamma*Hk{k}')'));  
                   end  


               end
               lambdaC=Covariate(timeWindow,lambdaDelta(:,:,c)/delta,'\Lambda(t)');
               lambdaCInt= lambdaC.integral;
               spikeRate(c,:) = (1/(max(time1)-min(time1)))*(lambdaCInt.getValueAt(max(time1))-lambdaCInt.getValueAt(min(time1))) ...
                                - (1/(max(time2)-min(time2)))*(lambdaCInt.getValueAt(max(time2))-lambdaCInt.getValueAt(min(time2)));


           end

           CIs = zeros(K,2);
           for k=1:K
               [f,x] = ecdf(spikeRate(:,k));
                CIs(k,1) = x(find(f<alphaVal,1,'last')); %not alpha/2 since this is a once sided comparison
                CIs(k,2) = x(find(f>(1-(alphaVal)),1,'first'));
           end
           spikeRateSig = Covariate(1:K, mean(spikeRate),['(t_{1f}-t_{1o})^-1 * \Lambda(t_{1f}-t_{1o}) - (t_{2f}-t_{2o})^-1 * \Lambda(t_{2f}-t_{2o}) '],'Trial','k','Hz');
           ciSpikeRate = ConfidenceInterval(1:K,CIs,'CI_{spikeRate}','Trial','k','Hz');
           spikeRateSig.setConfInterval(ciSpikeRate);


           if(nargout>1)
               ProbMat = zeros(K,K);
               for k=1:K
                   for m=(k+1):K

                       ProbMat(k,m)=sum(spikeRate(:,m)>spikeRate(:,k))./Mc;
                   end
               end
           end


           if(nargout>2)
                sigMat= double(ProbMat>(1-alphaVal));
           end


        end    

        %% Mixed Point Process and Continuous Observation (mPPCO)
        function [x_p, W_p, x_u, W_u] = mPPCODecodeLinear(A, Q, C, R, y, alpha, dN,mu,beta,fitType,delta,gamma,windowTimes,x0,Px0,HkAll)
        % [x_p, W_p, x_u, W_u] = mPPCODecodeLinear(A, Q, C, R, y, dN, mu, beta,fitType, delta, gamma,windowTimes, x0)
        % Point process adaptive filter with the assumption of linear
        % expresion for the conditional intensity functions (see below). If
        % the terms in the conditional intensity function include
        % polynomial powers of a variable for example, these expressions do
        % not hold. Use the PPDecodeFilter instead since it will compute
        % these expressions symbolically. However, because of the matlab
        % symbolic toolbox, it runs much slower than this version.
        % 
        % Assumes in both cases that 
        %   x_t = A*x_{t-1} + v_{t}     w_{t} ~ Normal with zero me and
        %                                       covariance Q
        %
        %   y_t = C*x_{t} + w_{t}     w_{t} ~ Normal with zero me and
        %                                       covariance R
        %
        % Paramerters:
        %  
        % A:        The state transition matrix from the x_{t-1} to x_{t}
        %
        % Q:        The covariance of the process noise v_t
        %
        % C:        The observation matrix
        %
        % R:        The covariance of the observation noise w_t
        %
        % y:        The continuous observations
        %
        % alpha:    Offset for the observations
        %
        % dN:       A C x N matrix of ones and zeros corresponding to the
        %           observed spike trains. N is the number of time steps in
        %           my code. C is the number of cells
        %
        % mu:       Cx1 vector of baseline firing rates for each cell. In
        %           the CIF expression in 'fitType' description 
        %           mu_c=mu(c);
        %
        % beta:     nsxC matrix of coefficients for the conditional
        %           intensity function. ns is the number of states in x_t 
        %           In the conditional intesity function description below
        %           beta_c = beta(:,c)';
        %
        % fitType: 'poisson' or 'binomial'. Determines how the beta and
        %           gamma coefficients are used to compute the conditional
        %           intensity function.
        %           For the cth cell:
        %           If poisson: lambda*delta = exp(mu_c+beta_c*x + gamma_c*hist_c)
        %           If binomial: logit(lambda*delta) = mu_c+beta_c*x + gamma_c*hist_c
        %
        % delta:    The number of seconds per time step. This is used to compute
        %           th history effect for each spike train using the input
        %           windowTimes and gamma
        %
        % gamma:    length(windowTimes)-1 x C matrix of the history
        %           coefficients for each window in windowTimes. In the 'fitType'
        %           expression above:
        %           gamma_c = gamma(:,c)';
        %           If gamma is a length(windowTimes)-1x1 vector, then the
        %           same history coefficients are used for each cell.
        %
        % windowTimes: Defines the distinct windows of time (in seconds)
        %           that will be computed for each spike train.
        %
        % x0:       The initial state
        %
        % Px0:      The initial state covariance
        
        
        
        [numCells,N]   = size(dN); % N time samples, C cells
        ns=size(A,1); % number of states
        if(nargin<16 || isempty(HkAll))
            HkAll=[];
        end
        if(nargin<15 || isempty(Px0))
           Px0=zeros(ns,ns);
        end
        if(nargin<14 || isempty(x0))
           x0=zeros(ns,1);
           
        end
        if(nargin<13 || isempty(windowTimes))
           windowTimes=[]; 
        end
        if(nargin<12 || isempty(gamma))
            gamma=0;
        end
        if(nargin<11 || isempty(delta))
            delta = .001;
        end
        
        
        minTime=0;
        maxTime=(size(dN,2)-1)*delta;
        
%         numCells=size(dN,1);
        if(~isempty(HkAll))
            if(~isempty(windowTimes))
                histObj = History(windowTimes,minTime,maxTime);
                for c=1:numCells
                    nst{c} = nspikeTrain( (find(dN(c,:)==1)-1)*delta);
                    nst{c}.setMinTime(minTime);
                    nst{c}.setMaxTime(maxTime);
                    HkAll{c} = histObj.computeHistory(nst{c}).dataToMatrix;
                end
                if(size(gamma,2)==1 && numCells>1) % if more than 1 cell but only 1 gamma
                    gammaNew(:,c) = gamma;
                else
                    gammaNew = gamma;
                end
                gamma = gammaNew;
            end

        else
            for c=1:numCells
                HkAll{c} = zeros(N,1);
                gammaNew(c)=0;
            end
            gamma=gammaNew;

        end
        

        
        %% Initialize the numCells
        x_p     = zeros( size(A,2), N+1 );
        x_u     = zeros( size(A,2), N );
        W_p    = zeros( size(A,2),size(A,2), N+1 );
        W_u    = zeros( size(A,2),size(A,2), N );
        
        x_p(:,1) = A*x0;
        W_p(:,:,1) = A * Px0 * A' + Q;
        for n=1:N
            [x_u(:,n), W_u(:,:,n)] = DecodingAlgorithms.mPPCODecode_update(x_p(:,n), W_p(:,:,n),  C, R, y(:,n), alpha(:,min(size(alpha,3),n)),dN,mu,beta,fitType,gamma,HkAll,n);
            if(n<N)
                [x_p(:,n+1), W_p(:,:,n+1)] = DecodingAlgorithms.mPPCODecode_predict(x_u(:,n), W_u(:,:,n), A(:,:,min(size(A,3),n)), Q(:,:,min(size(Q,3))));
            end
        end
      
        
        end

        % mPPCO Prediction Step 
        function [x_p, W_p] = mPPCODecode_predict(x_u, W_u, A, Q)
            x_p     = A * x_u;
            W_p    = A * W_u * A' + Q;
            if(rcond(W_p)<1000*eps)
                W_p=W_u; % See Srinivasan et al. 2007 pg. 529
            end
            W_p = .5*(W_p + W_p'); %To help with symmetry of matrix;

        end 
        function [x_u, W_u,lambdaDeltaMat] = mPPCODecode_update(x_p, W_p, C, R, y, alpha, dN,mu,beta,fitType,gamma,HkAll,time_index)
                    [numCells,N]   = size(dN); % N time samples, C cells
                    if(nargin<12 || isempty(time_index))
                        time_index=1;
                    end
                    if(nargin<11 || isempty(HkAll))
                        HkAll=cell(numCells,1);
                        for c=1:numCells
                            HkAll{c}=0;
                        end
                    end
                    if(nargin<10 || isempty(gamma))
                        gamma=zeros(1,numCells);
                    end
                    if(nargin<9 || isempty(fitType))
                        fitType = 'poisson';
                    end


                    sumValVec=zeros(size(W_p,1),1);
                    sumValMat=zeros(size(W_p,2),size(W_p,2));
                    lambdaDeltaMat = zeros(numCells,1);
                    if(strcmp(fitType,'binomial'))
                        for c=1:numCells
                            if(numel(gamma)==1)
                                gammaC=gamma;
                            else 
                                gammaC=gamma(:,c);
                            end
                            linTerm = mu(c)+beta(:,c)'*x_p + gammaC'*HkAll{c}(time_index,:)';
                            lambdaDeltaMat(c,1) = exp(linTerm)./(1+exp(linTerm));
                            if(isnan(lambdaDeltaMat(c,1)))
                                if(linTerm>1e2)
                                    lambdaDeltaMat(c,1)=1;
                                else
                                    lambdaDeltaMat(c,1)=0;
                                end
                            end
                            sumValVec = sumValVec+(dN(c,time_index)-lambdaDeltaMat(c,1))*(1-lambdaDeltaMat(c,1))*beta(:,c);
                            sumValMat = sumValMat+(dN(c,time_index)+(1-2*(lambdaDeltaMat(c,1)))).*(1-(lambdaDeltaMat(c,1))).*(lambdaDeltaMat(c,1))*beta(:,c)*beta(:,c)';
                        end
                    elseif(strcmp(fitType,'poisson'))
                        for c=1:numCells
                            if(numel(gamma)==1)
                                gammaC=gamma;
                            else 
                                gammaC=gamma(:,c);
                            end
                            linTerm = mu(c)+beta(:,c)'*x_p + gammaC'*HkAll{c}(time_index,:)';
                            lambdaDeltaMat(c,1) = exp(linTerm);
                            if(isnan(lambdaDeltaMat(c,1)))
                                if(linTerm>1e2)
                                    lambdaDeltaMat(c,1)=1;
                                else
                                    lambdaDeltaMat(c,1)=0;
                                end
                            end

                            sumValVec = sumValVec+(dN(c,time_index)-lambdaDeltaMat(c,1))*beta(:,c);
                            sumValMat = sumValMat+(lambdaDeltaMat(c,1))*beta(:,c)*beta(:,c)';
                        end
                    end
            % 
                    usePInv=0;
                    if(usePInv==1)
                        % Use pinv so that we do a SVD and ignore the zero singular values
                        % Sometimes because of the state space model definition and how information
                        % is integrated from distinct CIFs the sumValMat is very sparse. This
                        % allows us to prevent inverting singular matrices
                        invWp = pinv(W_p);
                        invR  = eye(size(R))/R;
                        invWu = invWp + sumValMat +C'*invR*C;
                        invWu(isnan(invWu))=0; %invWu(isinf(invWu))=0;
                        Wu = pinv(invWu);

                    else
                        invWp = eye(size(W_p))/W_p;
                        invR  = eye(size(R))/R;
                        invWu = invWp + sumValMat +C'*invR*C;
                        Wu = eye(size(W_p))/invWu;
                    end 
                    Wu = .5*(Wu + Wu'); %To help with symmetry of matrix;
                    if(any(any(isnan(Wu)))||any(any(isinf(Wu))))
                        Wu=W_p;
                    end
                   % Make sure that the update covariance is positive definite.
                    [vec,val]=eig(Wu); val(val<=0)=eps;
                    W_u=vec*val*vec';
                    W_u=real(W_u);
                    W_u(isnan(W_u))=0;
                    W_u = .5*(W_u + W_u'); %To help with symmetry of matrix;
                    x_u     = x_p + W_u*(sumValVec)+W_u*C'*invR*(y-C*x_p -alpha);


        end

        function  [xKFinal,WKFinal,Ahat, Qhat, Chat, Rhat,alphahat, logll,nIter,negLL]=KF_EM(y, Ahat0, Qhat0, Chat0, Rhat0, alphahat0, x0,Px0)
            numStates = size(Ahat0,1);
            if(nargin<8 || isempty(Px0))
                Px0=10e-10*eye(numStates,numStates);
            end
            if(nargin<7 || isempty(x0))
                x0=zeros(numStates,1);
            end
          
  %         tol = 1e-3; %absolute change;
            tolAbs = 1e-3;
            tolRel = 1e-3;
            llTol  = 1e-3;
            cnt=1;

            maxIter = 100;

            
            A0 = Ahat0;
            Q0 = Qhat0;
            C0 = Chat0;
            R0 = Rhat0;
            alpha0 = alphahat0;
           
           
            Ahat{1} = A0;
            Qhat{1} = Q0;
            Chat{1} = C0;
            Rhat{1} = R0;
            alphahat{1} = alpha0;
            numToKeep=10;
          
            cnt=1;
            dLikelihood(1)=inf;
            negLL=0;
         
            stoppingCriteria =0;
           while(stoppingCriteria~=1 && cnt<=maxIter)
                 storeInd = mod(cnt-1,numToKeep)+1; %make zero-based then mod, then add 1
                 storeIndP1= mod(cnt,numToKeep)+1;
                 storeIndM1= mod(cnt-2,numToKeep)+1;
                disp('---------------');
                disp(['Iteration #' num2str(cnt)]);
                disp('---------------');
                
%                 [x_K,W_K,logll,ExpectationSums]=KF_EStep(A,Q,C,R, y, alpha, x0, Px0)
                [x_K{storeInd},W_K{storeInd},logll(cnt),ExpectationSums{storeInd}]=...
                    DecodingAlgorithms.KF_EStep(Ahat{storeInd},Qhat{storeInd},Chat{storeInd},Rhat{storeInd}, y, alphahat{storeInd},x0, Px0);

%                 [Ahat, Qhat, Chat, Rhat, alphahat] = KF_MStep(y,x_K,ExpectationSums)
                [Ahat{storeIndP1}, Qhat{storeIndP1}, Chat{storeIndP1}, Rhat{storeIndP1}, alphahat{storeIndP1}]= ...
                    DecodingAlgorithms.KF_MStep(y,x_K{storeInd},ExpectationSums{storeInd});
               
                if(cnt==1)
                    dLikelihood(cnt+1)=inf;
                else
                    dLikelihood(cnt+1)=(logll(cnt)-logll(cnt-1));%./abs(logll(cnt-1));
                end
                if(cnt==1)
                    QhatInit = Qhat{1};
                    RhatInit = Rhat{1};
                    xKInit = x_K{1};
                end
                %Plot the progress
%                 if(mod(cnt,2)==0)
                    scrsz = get(0,'ScreenSize');
                    h=figure('OuterPosition',[scrsz(3)*.01 scrsz(4)*.04 scrsz(3)*.98 scrsz(4)*.95]);
                    figure(h);
                    subplot(2,5,[1 2 6 7]); plot(1:cnt,logll,'k','Linewidth', 2); hy=ylabel('Log Likelihood'); hx=xlabel('Iteration'); axis auto;
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    subplot(2,5,3:5); hNew=plot(x_K{storeInd}','Linewidth', 2); hy=ylabel('States'); hx=xlabel('time [sample]');
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on; hOrig=plot(xKInit','--','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    
                    subplot(2,5,8); hNew=plot(diag(Qhat{storeInd}),'o','Linewidth', 2); hy=ylabel('Q'); hx=xlabel('Diagonal Entry');
                    set(gca, 'XTick'       , 1:1:length(diag(Qhat{storeInd})));
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on; hOrig=plot(diag(QhatInit),'r.','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    
                    subplot(2,5,9); hNew=plot(diag(Rhat{storeInd}),'o','Linewidth', 2); hy=ylabel('R'); hx=xlabel('Diagonal Entry');
                    set(gca, 'XTick'       , 1:1:length(diag(Rhat{storeInd})));
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on;hOrig=plot(diag(RhatInit),'r.','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    
                    subplot(2,5,10); imagesc(Rhat{storeInd}); ht=title('R Matrix Image');
                    set(gca, 'XTick'       , 1:1:length(diag(Rhat{storeInd})), 'YTick', 1:1:length(diag(Rhat{storeInd})));
                    set(ht,'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    drawnow;
%                 end
                
                if(cnt==1)
                    dMax=inf;
                else
                 dQvals = max(max(abs(sqrt(Qhat{storeInd})-sqrt(Qhat{storeIndM1}))));
                 dRvals = max(max(abs(sqrt(Rhat{storeInd})-sqrt(Rhat{storeIndM1}))));
                 dAvals = max(max(abs((Ahat{storeInd})-(Ahat{storeIndM1}))));
                 dCvals = max(max(abs((Chat{storeInd})-(Chat{storeIndM1}))));
                 dAlphavals = max(abs((alphahat{storeInd})-(alphahat{storeIndM1})));
                 dMax = max([dQvals,dRvals,dAvals,dCvals,dAlphavals]);
                end

% 
%                 dQRel = max(abs(dQvals./sqrt(Qhat(:,storeIndM1))));
%                 dGammaRel = max(abs(dGamma./gammahat(storeIndM1,:)));
%                 dMaxRel = max([dQRel,dGammaRel]);

                 cnt=(cnt+1);
                
                if(dMax<tolAbs)
                    stoppingCriteria=1;
                    display(['         EM converged at iteration# ' num2str(cnt) ' b/c change in params was within criteria']);
                    negLL=0;
                end
            
                if(abs(dLikelihood(cnt))<llTol  || dLikelihood(cnt)<0)
                    stoppingCriteria=1;
                    display(['         EM stopped at iteration# ' num2str(cnt) ' b/c change in likelihood was negative']);
                    negLL=1;
                end
            

           end
            

                    


            maxLLIndex  = find(logll == max(logll),1,'first');
            maxLLIndMod =  mod(maxLLIndex-1,numToKeep)+1;
            if(maxLLIndex==1)
                maxLLIndex =1;
                maxLLIndMod = 1;
            elseif(isempty(maxLLIndex))
               maxLLIndex = 1; 
               maxLLIndMod = 1;
               
            end
            nIter   = cnt-1;  
            xKFinal = x_K{maxLLIndMod};
            WKFinal = W_K{maxLLIndMod};
            Ahat = Ahat{maxLLIndMod};
            Qhat = Qhat{maxLLIndMod};
            Chat = Chat{maxLLIndMod};
            Rhat = Rhat{maxLLIndMod};
            alphahat = alphahat{maxLLIndMod};
            logll = logll(maxLLIndex);

          
        end
        
        
        function [x_K,W_K,logll,ExpectationSums]=KF_EStep(A,Q,C,R, y, alpha, x0, Px0)
            DEBUG = 0;

            Dx = size(A,2);
            Dy = size(C,1);
            
            K=size(y,2);
            [x_p, W_p, x_u, W_u] = DecodingAlgorithms.kalman_filter(A, C, Q, R,Px0, x0, y-alpha*ones(1,size(y,2)));
            
            [x_K, W_K,Lk] = DecodingAlgorithms.kalman_smootherFromFiltered(A, x_p, W_p, x_u, W_u);


            numStates = size(x_K,1);
            Wku=zeros(numStates,numStates,K,K);
            Tk = zeros(numStates,numStates,K-1);
            for k=1:K
                Wku(:,:,k,k)=W_K(:,:,k);
            end

            for u=K:-1:2
                for k=(u-1):-1:(u-1)
                    Tk(:,:,k)=A;
%                     Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'*pinv(W_p(:,:,k+1)); %From deJong and MacKinnon 1988
                     Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'/(W_p(:,:,k+1)); %From deJong and MacKinnon 1988
                    Wku(:,:,k,u)=Dk(:,:,k)*Wku(:,:,k+1,u);
                    Wku(:,:,u,k)=Wku(:,:,k,u)';
                end
            end
            
            %All terms
            Sxkm1xk = zeros(Dx,Dx);
            Sxkm1xkm1 = zeros(Dx,Dx);
            Sxkxk = zeros(Dx,Dx);
            Sykyk = zeros(Dy,Dy);
            Sxkyk = zeros(Dx,Dy);
            for k=1:K
                if(k==1)
                    Sxkm1xk   = Sxkm1xk+Px0*A'/W_p(:,:,1)*Wku(:,:,1,1);
                    Sxkm1xkm1 = Sxkm1xkm1+Px0+x0*x0';   
                else
                    Sxkm1xk =  Sxkm1xk+Wku(:,:,k-1,k)+x_K(:,k-1)*x_K(:,k)';
                    Sxkm1xkm1= Sxkm1xkm1+Wku(:,:,k-1,k-1)+x_K(:,k-1)*x_K(:,k-1)';
                end
                Sxkxk = Sxkxk+Wku(:,:,k,k)+x_K(:,k)*x_K(:,k)';
                Sykyk = Sykyk+(y(:,k)-alpha)*(y(:,k)-alpha)';
                Sxkyk = Sxkyk+x_K(:,k)*(y(:,k)-alpha)';

            end
            Sxkxk = 0.5*(Sxkxk+Sxkxk');
            Sykyk = 0.5*(Sykyk+Sykyk');
            sumXkTerms = Sxkxk-A*Sxkm1xk-Sxkm1xk'*A'+A*Sxkm1xkm1*A';
            sumYkTerms = Sykyk - C*Sxkyk - Sxkyk'*C' + C*Sxkxk*C';      
            

            logll = -Dx*K/2*log(2*pi)-K/2*log(det(Q))-Dy*K/2*log(2*pi)...
                    -K/2*log(det(R))- Dx/2*log(2*pi) -1/2*log(det(Px0)) -Dx/2  ...
                    -1/2*trace(Q\sumXkTerms) ...
                    -1/2*trace(R\sumYkTerms);
            string0 = ['logll: ' num2str(logll)];
            disp(string0);
            if(DEBUG==1)
                string1 = ['-K/2*log(det(Q)):' num2str(-K/2*log(det(Q)))];
                string2 = ['-K/2*log(det(R)):' num2str(-K/2*log(det(R)))];
                string3= ['Constants: ' num2str(-Dx*K/2*log(2*pi)-Dy*K/2*log(2*pi)- Dx/2*log(2*pi) -Dx/2 -1/2*log(det(Px0)))];
                string4 = ['-.5*trace(Q\sumXkTerms): ' num2str(-.5*trace(Q\sumXkTerms))];
                string5 = ['-.5*trace(R\sumYkTerms): ' num2str(-.5*trace(R\sumYkTerms))];

                disp(string1);
                disp(['Q=' num2str(diag(Q)')]);
                disp(string2);
                disp(['R=' num2str(diag(R)')]);
                disp(string3);
                disp(string4);
                disp(string5);
                
            end

            ExpectationSums.Sxkm1xkm1=Sxkm1xkm1;
            ExpectationSums.Sxkm1xk=Sxkm1xk;
            ExpectationSums.Sxkxk=Sxkxk;
            ExpectationSums.Sxkyk=Sxkyk;
            ExpectationSums.sumXkTerms=sumXkTerms;
            ExpectationSums.sumYkTerms=sumYkTerms;

        end
        function [Ahat, Qhat, Chat, Rhat, alphahat] = KF_MStep(y,x_K,ExpectationSums)
            Sxkm1xkm1=ExpectationSums.Sxkm1xkm1;
            Sxkm1xk=ExpectationSums.Sxkm1xk;
            Sxkxk=ExpectationSums.Sxkxk;
            Sxkyk=ExpectationSums.Sxkyk;
            sumXkTerms=ExpectationSums.sumXkTerms;
            sumYkTerms=ExpectationSums.sumYkTerms;
             K = size(x_K,2);   
             numStates=size(x_K,1);
%              Ahat =diag(diag(Sxkm1xk/Sxkm1xkm1));
%              [V,D] = eig(Ahat); 
%              D(D>=1)=.99999; % Make sure that the A matrix is stable
%              Ahat = V*D*V';
%              Ahat(Ahat>1)=.99999;
             Ahat = eye(numStates,numStates);
             Chat = Sxkyk'/Sxkxk;
             alphahat = sum(y - Chat*x_K,2)/K;
%              Qhat = 1/K*sumXkTerms;
             Qhat = diag(diag(1/K*sumXkTerms));
%              Rhat=diag(diag(1/K*sumYkTerms));
             Rhat=1/K*sumYkTerms;
             
           
        
        end
        function  [xKFinal,WKFinal,Ahat, Qhat, Chat, Rhat,alphahat, muhat, betahat, gammahat, logll,nIter,negLL]=mPPCO_EM(y,dN, Ahat0, Qhat0, Chat0, Rhat0, alphahat0, mu, beta, fitType,delta, gamma, windowTimes, x0, Px0,MstepMethod)
            numStates = size(Ahat0,1);
            if(nargin<16 || isempty(MstepMethod))
               MstepMethod='GLM'; %or NewtonRaphson 
            end
            if(nargin<15 || isempty(Px0))
                Px0=10e-10*eye(numStates,numStates);
            end
            if(nargin<14 || isempty(x0))
                x0=zeros(numStates,1);
            end
            
            if(nargin<13 || isempty(windowTimes))
                if(isempty(gamma))
                    windowTimes =[];
                else
    %                 numWindows =length(gamma0)+1; 
                    windowTimes = 0:delta:(length(gamma)+1)*delta;
                end
            end
            if(nargin<12)
                gamma=[];
            end
            if(nargin<11 || isempty(delta))
                delta = .001;
            end
            if(nargin<10)
                fitType = 'poisson';
            end
            
            minTime=0;
            maxTime=(size(dN,2)-1)*delta;
            K=size(dN,1);
            if(~isempty(windowTimes))
                histObj = History(windowTimes,minTime,maxTime);
                for k=1:K
                    nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
                    nst{k}.setMinTime(minTime);
                    nst{k}.setMaxTime(maxTime);
                    HkAll{k} = histObj.computeHistory(nst{k}).dataToMatrix;
                end
            else
                for k=1:K
                    HkAll{k} = 0;
                end
                gammahat=0;
            end



    %         tol = 1e-3; %absolute change;
            tolAbs = 1e-3;
            tolRel = 1e-3;
            llTol  = 1e-3;
            cnt=1;

            maxIter = 100;

            
            A0 = Ahat0;
            Q0 = Qhat0;
            C0 = Chat0;
            R0 = Rhat0;
            alpha0 = alphahat0;
           
           
            Ahat{1} = A0;
            Qhat{1} = Q0;
            Chat{1} = C0;
            Rhat{1} = R0;
            alphahat{1} = alpha0;
            muhat{1} = mu;
            betahat{1} = beta;
            gammahat{1} = gamma;
            numToKeep=10;
          
            cnt=1;
            dLikelihood(1)=inf;
            x0hat = x0;
            negLL=0;
         
            %Forward EM
            stoppingCriteria =0;
%             logllNew= -inf;
            while(stoppingCriteria~=1 && cnt<=maxIter)
                 storeInd = mod(cnt-1,numToKeep)+1; %make zero-based then mod, then add 1
                 storeIndP1= mod(cnt,numToKeep)+1;
                 storeIndM1= mod(cnt-2,numToKeep)+1;
                disp('---------------');
                disp(['Iteration #' num2str(cnt)]);
                disp('---------------');
                
                [x_K{storeInd},W_K{storeInd},logll(cnt),ExpectationSums{storeInd}]=...
                    DecodingAlgorithms.mPPCO_EStep(Ahat{storeInd},Qhat{storeInd},Chat{storeInd},Rhat{storeInd}, y, alphahat{storeInd},dN, muhat{storeInd}, betahat{storeInd},fitType,delta,gammahat{storeInd},HkAll, x0, Px0);

                
                [Ahat{storeIndP1}, Qhat{storeIndP1}, Chat{storeIndP1}, Rhat{storeIndP1}, alphahat{storeIndP1}, muhat{storeIndP1}, betahat{storeIndP1}, gammahat{storeIndP1}] ...
                    = DecodingAlgorithms.mPPCO_MStep(dN, y,x_K{storeInd},W_K{storeInd}, ExpectationSums{storeInd}, fitType,muhat{storeInd},betahat{storeInd}, gammahat{storeInd},windowTimes,HkAll,MstepMethod);
               
                if(cnt==1)
                    dLikelihood(cnt+1)=inf;
                else
                    dLikelihood(cnt+1)=(logll(cnt)-logll(cnt-1));%./abs(logll(cnt-1));
                end
                if(cnt==1)
                    QhatInit = Qhat{1};
                    RhatInit = Rhat{1};
                    xKInit = x_K{1};
                end
                %Plot the progress
%                 if(mod(cnt,2)==0)
                    scrsz = get(0,'ScreenSize');
                    h=figure('OuterPosition',[scrsz(3)*.01 scrsz(4)*.04 scrsz(3)*.98 scrsz(4)*.95]);
                    figure(h);
                    time = linspace(minTime,maxTime,size(x_K{storeInd},2));
                    subplot(2,5,[1 2 6 7]); plot(1:cnt,logll,'k','Linewidth', 2); hy=ylabel('Log Likelihood'); hx=xlabel('Iteration'); axis auto;
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    subplot(2,5,3:5); hNew=plot(time, x_K{storeInd}','Linewidth', 2); hy=ylabel('States'); hx=xlabel('time [s]');
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on; hOrig=plot(time, xKInit','--','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    
                    subplot(2,5,8); hNew=plot(diag(Qhat{storeInd}),'o','Linewidth', 2); hy=ylabel('Q'); hx=xlabel('Diagonal Entry');
                    set(gca, 'XTick'       , 1:1:length(diag(Qhat{storeInd})));
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on; hOrig=plot(diag(QhatInit),'r.','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    
                    subplot(2,5,9); hNew=plot(diag(Rhat{storeInd}),'o','Linewidth', 2); hy=ylabel('R'); hx=xlabel('Diagonal Entry');
                    set(gca, 'XTick'       , 1:1:length(diag(Rhat{storeInd})));
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on; hOrig=plot(diag(RhatInit),'r.','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    
                    
                    subplot(2,5,10); imagesc(Rhat{storeInd}); ht=title('R Matrix Image'); 
                    set(gca, 'XTick'       , 1:1:length(diag(Rhat{storeInd})), 'YTick', 1:1:length(diag(Rhat{storeInd})));
                    set(ht,'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    drawnow;
%                 end
                
                if(cnt==1)
                    dMax=inf;
                else
                 dQvals = max(max(abs(sqrt(Qhat{storeInd})-sqrt(Qhat{storeIndM1}))));
                 dRvals = max(max(abs(sqrt(Rhat{storeInd})-sqrt(Rhat{storeIndM1}))));
                 dAvals = max(max(abs((Ahat{storeInd})-(Ahat{storeIndM1}))));
                 dCvals = max(max(abs((Chat{storeInd})-(Chat{storeIndM1}))));
                 dMuvals = max(abs((muhat{storeInd})-(muhat{storeIndM1})));
                 dAlphavals = max(abs((alphahat{storeInd})-(alphahat{storeIndM1})));
                 dBetavals = max(max(abs((betahat{storeInd})-(betahat{storeIndM1}))));
                 dGammavals = max(max(abs((gammahat{storeInd})-(gammahat{storeIndM1}))));
                 dMax = max([dQvals,dRvals,dAvals,dCvals,dMuvals,dAlphavals,dBetavals,dGammavals]);
                end

% 
%                 dQRel = max(abs(dQvals./sqrt(Qhat(:,storeIndM1))));
%                 dGammaRel = max(abs(dGamma./gammahat(storeIndM1,:)));
%                 dMaxRel = max([dQRel,dGammaRel]);

                 cnt=(cnt+1);
                
                if(dMax<tolAbs)
                    stoppingCriteria=1;
                    display(['         EM converged at iteration# ' num2str(cnt) ' b/c change in params was within criteria']);
                    negLL=0;
                end
            
                if(abs(dLikelihood(cnt))<llTol  || dLikelihood(cnt)<0)
                    stoppingCriteria=1;
                    display(['         EM stopped at iteration# ' num2str(cnt) ' b/c change in likelihood was negative']);
                    negLL=1;
                end
            

            end
           

            maxLLIndex  = find(logll == max(logll),1,'first');
            maxLLIndMod =  mod(maxLLIndex-1,numToKeep)+1;
            if(maxLLIndex==1)
%                 maxLLIndex=cnt-1;
                maxLLIndex =1;
                maxLLIndMod = 1;
            elseif(isempty(maxLLIndex))
               maxLLIndex = 1; 
               maxLLIndMod = 1;
%             else
%                maxLLIndMod = mod(maxLLIndex,numToKeep); 
               
            end
            nIter   = cnt-1;  
%             maxLLIndMod
            xKFinal = x_K{maxLLIndMod};
            WKFinal = W_K{maxLLIndMod};
            Ahat = Ahat{maxLLIndMod};
            Qhat = Qhat{maxLLIndMod};
            Chat = Chat{maxLLIndMod};
            Rhat = Rhat{maxLLIndMod};
            alphahat = alphahat{maxLLIndMod};
            muhat= muhat{maxLLIndMod};
            betahat = betahat{maxLLIndMod};
            gammahat = gammahat{maxLLIndMod};
            logll = logll(maxLLIndex);
            ExpectationSumsFinal = ExpectationSums{maxLLIndMod};
            K=size(dN,1);
            SumXkTermsFinal = diag(Qhat(:,:,end))*K;
            logllFinal=logll(end);
            McInfo=100;
            McCI = 3000;

            nIter = [];%[nIter1,nIter2,nIter3];
  
            
            K  = size(dN,1); 
            Dx = size(Ahat,2);
            sumXkTerms = ExpectationSums{maxLLIndMod}.sumXkTerms;
            logllobs = logll + Dx*K/2*log(2*pi)+K/2*log(det(Qhat))+ 1/2*trace(pinv(Qhat)*sumXkTerms); 
                  
%             InfoMat = DecodingAlgorithms.estimateInfoMat_mPPCO(fitType,xKFinal, WKFinal,Ahat,Qhat,Chat, Rhat,alphahat, muhat, betahat,gammahat,dN,windowTimes, HkAll,delta,ExpectationSums{maxLLIndMod},McInfo);
%             
%             
%             fitResults = DecodingAlgorithms.prepareEMResults(fitType,neuronName,dN,HkAll,xKFinal,WKFinal,Qhat,gammahat,windowTimes,delta,InfoMat,logllobs);
%             [stimCIs, stimulus] = DecodingAlgorithms.ComputeStimulusCIs(fitType,xKFinal,WkuFinal,delta,McCI);
%             
           
         end
        
   
         
        function [x_K,W_K,logll,ExpectationSums]=mPPCO_EStep(A,Q,C,R, y, alpha,dN, mu, beta,fitType,delta,gamma,HkAll, x0, Px0)
             DEBUG = 0;

             minTime=0;
             maxTime=(size(dN,2)-1)*delta;


   
            [numCells,K]   = size(dN); 
            Dx = size(A,2);
            Dy = size(C,1);
            x_p     = zeros( size(A,2), K );
            x_u     = zeros( size(A,2), K );
            W_p    = zeros( size(A,2),size(A,2), K);
            W_u    = zeros( size(A,2),size(A,2), K );
            

            [x_p, W_p, x_u, W_u] = DecodingAlgorithms.mPPCODecodeLinear(A, Q, C, R, y, alpha, dN,mu,beta,fitType,delta,gamma,[],x0,Px0,HkAll);
            
            [x_K, W_K,Lk] = DecodingAlgorithms.kalman_smootherFromFiltered(A, x_p, W_p, x_u, W_u);
            
            numStates = size(x_K,1);
            Wku=zeros(numStates,numStates,K,K);
            Tk = zeros(numStates,numStates,K-1);
            for k=1:K
                Wku(:,:,k,k)=W_K(:,:,k);
            end

            for u=K:-1:2
                for k=(u-1):-1:(u-1)
                    Tk(:,:,k)=A;
%                     Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'*pinv(W_p(:,:,k)); %From deJong and MacKinnon 1988
                     Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'/(W_p(:,:,k+1)); %From deJong and MacKinnon 1988
                    Wku(:,:,k,u)=Dk(:,:,k)*Wku(:,:,k+1,u);
                    Wku(:,:,u,k)=Wku(:,:,k,u)';
                end
            end
            
            %All terms
            Sxkm1xk = zeros(Dx,Dx);
            Sxkm1xkm1 = zeros(Dx,Dx);
            Sxkxk = zeros(Dx,Dx);
            Sykyk = zeros(Dy,Dy);
            Sxkyk = zeros(Dx,Dy);
            for k=1:K
                if(k==1)
                    Sxkm1xk   = Sxkm1xk+Px0*A'/W_p(:,:,1)*Wku(:,:,1,1);
                    Sxkm1xkm1 = Sxkm1xkm1+Px0+x0*x0';     
                else
%                   
                      Sxkm1xk =  Sxkm1xk+Wku(:,:,k-1,k)+x_K(:,k-1)*x_K(:,k)';
                       
                      Sxkm1xkm1= Sxkm1xkm1+Wku(:,:,k-1,k-1)+x_K(:,k-1)*x_K(:,k-1)';
                end
                Sxkxk = Sxkxk+Wku(:,:,k,k)+x_K(:,k)*x_K(:,k)';
                Sykyk = Sykyk+(y(:,k)-alpha)*(y(:,k)-alpha)';
                Sxkyk = Sxkyk+x_K(:,k)*(y(:,k)-alpha)';

            end
            Sxkxk = 0.5*(Sxkxk+Sxkxk');
            Sykyk = 0.5*(Sykyk+Sykyk');
            sumXkTerms = Sxkxk-A*Sxkm1xk-Sxkm1xk'*A'+A*Sxkm1xkm1*A';
            sumYkTerms = Sykyk - C*Sxkyk - Sxkyk'*C' + C*Sxkxk*C';      

            if(strcmp(fitType,'poisson'))
                sumPPll=0;
                for c=1:numCells
                    Hk=HkAll{c};
                    for k=1:K
                        xk = x_K(:,k);
                        if(numel(gamma)==1)
                            gammaC=gamma;
                        else 
                            gammaC=gamma(:,c);
                        end
                        terms=mu(c)+beta(:,c)'*xk+gammaC'*Hk(k,:)';
                        Wk = W_K(:,:,k);
                        ld = exp(terms);
                        bt = beta(:,c);
                        ExplambdaDelta =ld+0.5*trace(bt*bt'*ld*Wk);
                        ExplogLD = terms;
                        sumPPll=sumPPll+dN(c,k).*ExplogLD - ExplambdaDelta;
                    end
                  
                            
                end
            elseif(strcmp(fitType,'binomial'))
                sumPPll=0;
                for c=1:numCells
                    Hk=HkAll{c};
                    for k=1:K
                        xk = x_K(:,k);
                        if(numel(gamma)==1)
                            gammaC=gamma;
                        else 
                            gammaC=gamma(:,c);
                        end
                        terms=mu(c)+beta(:,c)'*xk+gammaC'*Hk(k,:)';
                        Wk = W_K(:,:,k);
                        ld = exp(terms)./(1+exp(terms));
                        bt = beta(:,c);
                        ExplambdaDelta =ld+0.5*trace(bt*bt'*ld*(1-ld)*(1-2*ld)*Wk);
                        ExplogLD = log(ld)+0.5*trace(-(bt*bt'*ld*(1-ld))*Wk);
                        sumPPll=sumPPll+dN(c,k).*ExplogLD - ExplambdaDelta;
                    end
                  
                            
                end
            end

            logll = -Dx*K/2*log(2*pi)-K/2*log(det(Q))-Dy*K/2*log(2*pi)...
                    -K/2*log(det(R))- Dx/2*log(2*pi) -1/2*log(det(Px0)) -Dx/2  ...
                    +sumPPll - 1/2*trace(pinv(Q)*sumXkTerms) ...
                    -1/2*trace(pinv(R)*sumYkTerms);
                string0 = ['logll: ' num2str(logll)];
                disp(string0);
                if(DEBUG==1)
                    string1 = ['-K/2*log(det(Q)):' num2str(-K/2*log(det(Q)))];
                    string11 = ['-K/2*log(det(R)):' num2str(-K/2*log(det(R)))];
                    string12= ['Constants: ' num2str(-Dx*K/2*log(2*pi)-Dy*K/2*log(2*pi)- Dx/2*log(2*pi) -Dx/2 -1/2*log(det(Px0)))];
                    string2 = ['SumPPll: ' num2str(sumPPll)];
                    string3 = ['-.5*trace(Q\sumXkTerms): ' num2str(-.5*trace(Q\sumXkTerms))];
                    string4 = ['-.5*trace(R\sumYkTerms): ' num2str(-.5*trace(R\sumYkTerms))];

                    disp(string1);
                    disp(['Q=' num2str(diag(Q)')]);
                    disp(string11);
                    disp(['R=' num2str(diag(R)')]);
                    disp(string12);
                    disp(string2);
                    disp(string3);
                    disp(string4);
                end

                ExpectationSums.Sxkm1xkm1=Sxkm1xkm1;
                ExpectationSums.Sxkm1xk=Sxkm1xk;
                ExpectationSums.Sxkxk=Sxkxk;
                ExpectationSums.Sxkyk=Sxkyk;
                ExpectationSums.sumXkTerms=sumXkTerms;
                ExpectationSums.sumYkTerms=sumYkTerms;
                ExpectationSums.sumPPll=sumPPll;

        end
        function [Ahat, Qhat, Chat, Rhat, alphahat, muhat_new, betahat_new, gammahat_new] = mPPCO_MStep(dN, y,x_K,W_K,ExpectationSums,fitType, muhat, betahat,gammahat, windowTimes, HkAll,MstepMethod)
            if(nargin<12 || isempty(MstepMethod))
                MstepMethod = 'GLM'; %GLM or NewtonRaphson
            end
            Sxkm1xkm1=ExpectationSums.Sxkm1xkm1;
            Sxkm1xk=ExpectationSums.Sxkm1xk;
            Sxkxk=ExpectationSums.Sxkxk;
            Sxkyk=ExpectationSums.Sxkyk;
            sumXkTerms=ExpectationSums.sumXkTerms;
            sumYkTerms=ExpectationSums.sumYkTerms;
%             sumPPll=ExpectationSums.sumPPll;
             K = size(x_K,2);   
             numCells=size(dN,1);
             numStates = size(x_K,1);
%              Ahat =diag(diag(Sxkm1xk/Sxkm1xkm1));
%              [V,D] = eig(Ahat); 
%              D(D>=1)=.99999; % Make sure that the A matrix is stable
%              Ahat = V*D*V';
             Ahat = eye(numStates,numStates);
        
             
%              Ahat = diag(diag(Sxkm1xk/Sxkm1xkm1)); %Force A to be diagonal

             Chat = Sxkyk'/Sxkxk;
             
             alphahat = sum(y - Chat*x_K,2)/K;
%              Qhat=1/K*sumXkTerms;
             Qhat = diag(diag(1/K*sumXkTerms));
             Rhat = 1/K*sumYkTerms;
%              Rhat=diag(diag(1/K*sumYkTerms));
             
             betahat_new =betahat;
             gammahat_new = gammahat;
             muhat_new = muhat;
             
            %Compute the new CIF beta using the GLM
            if(strcmp(fitType,'poisson'))
                algorithm = 'GLM';
            else
                algorithm = 'BNLRCG';
            end
            
            % Estimate params via GLM
            if(strcmp(MstepMethod,'GLM'))
                clear c; close all;
                time=(0:length(x_K)-1)*.001;
                labels = cell(1,numStates);
                labels2 = cell(1,numStates+1);
                labels2{1} = 'vel';
                for i=1:numStates
                    labels{i} = strcat('v',num2str(i));
                    labels2{i+1} = strcat('v',num2str(i));
                end
                vel = Covariate(time,x_K','vel','time','s','m/s',labels);
                baseline = Covariate(time,ones(length(time),1),'Baseline','time','s','',...
                    {'constant'});
                for i=1:size(dN,1)
                    spikeTimes = time(find(dN(i,:)==1));
                    nst{i} = nspikeTrain(spikeTimes);
                end
                nspikeColl = nstColl(nst);
                cc = CovColl({vel,baseline});
                trial = Trial(nspikeColl,cc);
                selfHist = windowTimes ; NeighborHist = []; sampleRate = 1000; 
                clear c;
                
                

                if(gammahat==0)
                    c{1} = TrialConfig({{'Baseline','constant'},labels2},sampleRate,[],NeighborHist); 
                else
                    c{1} = TrialConfig({{'Baseline','constant'},labels2},sampleRate,selfHist,NeighborHist); 
                end
                c{1}.setName('Baseline');
                cfgColl= ConfigColl(c);
                warning('OFF');

                results = Analysis.RunAnalysisForAllNeurons(trial,cfgColl,0,algorithm);
                temp = FitResSummary(results);
                tempCoeffs = squeeze(temp.getCoeffs);
                if(gammahat==0)
                    betahat(1:numStates,:) = tempCoeffs(2:(numStates+1),:);
                    muhat = tempCoeffs(1,:)';
                else
                    betahat(1:numStates,:) = tempCoeffs(2:(numStates+1),:);
                    muhat = tempCoeffs(1,:)';
                    histTemp = squeeze(temp.getHistCoeffs);
                    histTemp = reshape(histTemp, [length(windowTimes)-1 numCells]);
                    histTemp(isnan(histTemp))=0;
                    gammahat=histTemp;
                end
            else
                
            % Estimate via Newton-Raphson
                 fprintf(['****M-step for beta**** \n']);
                 for c=1:numCells
    %                  c


                     converged=0;
                     iter = 1;
                     maxIter=100;
    %                  disp(['M-step for beta, neuron:' num2str(c) ' iter: ' num2str(c) ' of ' num2str(maxIter)]); 
                     fprintf(['neuron:' num2str(c) ' iter: ']);
                     while(~converged && iter<maxIter)

                        if(iter==1)
                            fprintf('%d',iter);
                        else
                            fprintf(',%d',iter);
                        end
                        if(strcmp(fitType,'poisson'))
                            gradQ=zeros(size(betahat_new(:,c),1),1);
                            jacQ =zeros(size(betahat_new(:,c),1),size(betahat_new(:,c),1));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                xk = x_K(:,k);
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms =muhat(c)+betahat_new(:,c)'*xk+gammaC'*Hk(k,:)';
                                ld=exp(terms);

                                numStates =length(xk);
                                ExplambdaDeltaXk = zeros(numStates,1);
                                ExplambdaDeltaXkXkT = zeros(numStates,numStates);
                                for m=1:numStates
                                     sm = zeros(numStates,1);
                                     sm(m) =1;
                                     bt=betahat_new(:,c);
                                     ExplambdaDeltaXk(m) = ld*sm'*xk+...
                                         .5*trace(ld*(bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk);
                                    for n=1:m
                                        sn = zeros(numStates,1);
                                        sn(n) =1; 
                                        ExplambdaDeltaXkXkT(n,m) = ld*xk'*sm*sn'*xk+...
                                            +trace(ld*(2*bt*xk'*sn*sm'*xk*bt'+bt*xk'*sn*sm'+sn*sm'*xk*bt'+sn*sm')*Wk);
                                        if(n~=m)
                                            ExplambdaDeltaXkXkT(n,m)=ExplambdaDeltaXkXkT(m,n);
                                        end
                                    end
                                end

                                gradQ = gradQ + (dN(c,k)*xk - ExplambdaDeltaXk);
                                jacQ  = jacQ  - ExplambdaDeltaXkXkT;
                            end


                        elseif(strcmp(fitType,'binomial'))
                            gradQ=zeros(size(betahat_new(:,c),1),1);
                            jacQ =zeros(size(betahat_new(:,c),1),size(betahat_new(:,c),1));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                xk = x_K(:,k);                    
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms =muhat(c)+betahat_new(:,c)'*xk+gammaC'*Hk(k,:)';
                                ld=exp(terms)./(1+exp(terms));

                                numStates =length(xk);
                                ExplambdaDeltaXk = zeros(numStates,1);
                                ExplambdaDeltaSqXk = zeros(numStates,1);
                                ExplambdaDeltaXkXkT = zeros(numStates,numStates);
                                ExplambdaDeltaSqXkXkT = zeros(numStates,numStates);
                                ExplambdaDeltaCubedXkXkT = zeros(numStates,numStates);
                                for m=1:numStates
                                     sm = zeros(numStates,1);
                                     sm(m) =1;
                                     bt=betahat_new(:,c);
                                     ExplambdaDeltaXk(m) = ld*sm'*xk+...
                                         +.5*trace(ld*(bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         -.5*trace((ld^2)*(3*bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         +.5*trace((ld^3)*(2*bt*xk'*sm*bt')*Wk);
                                     ExplambdaDeltaSqXk(m) = (ld)^2*sm'*xk+...
                                         +trace((ld^2)*(2*bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         -trace((ld^3)*(2*bt*xk'*sm*bt'+3*bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         +trace(3*(ld^4)*(bt*xk'*sm*bt')*Wk);

                                    for n=1:m
                                        sn = zeros(numStates,1);
                                        sn(n) =1; 
                                        ExplambdaDeltaXkXkT(n,m) = ld*xk'*sm*sn'*xk+...
                                            +0.5*trace((ld)*(bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm'+2*sn*sm')*Wk)...
                                            -0.5*trace((ld)^2*(3*bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm')*Wk)...
                                            +0.5*trace((ld)^3*(2*bt*xk'*sn*sm'*xk*bt')*Wk);
                                        ExplambdaDeltaSqXkXkT(n,m) = (ld)^2*xk'*sm*sn'*xk+...
                                            +trace((ld)^2*(2*bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm'+sn*sm')*Wk)...
                                            -trace((ld)^3*(5*bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm')*Wk)...
                                            +trace((ld)^4*(3*bt*xk'*sn*sm'*xk*bt')*Wk);

                                        ExplambdaDeltaCubedXkXkT(n,m) = (ld)^3*xk'*sm*sn'*xk+...
                                            +0.5*trace((ld)^3*(9*bt*xk'*sn*sm'*xk*bt'+6*sn*sm'*xk*bt'+6*bt*xk'*sn*sm'+2*sn*sm')*Wk)...
                                            -0.5*trace((ld)^4*(21*bt*xk'*sn*sm'*xk*bt'+6*sn*sm'*xk*bt'+6*bt*xk'*sn*sm')*Wk)...
                                            +0.5*trace((ld)^5*(12*bt*xk'*sn*sm'*xk*bt')*Wk);

                                        if(n~=m)
                                            ExplambdaDeltaXkXkT(n,m)=ExplambdaDeltaXkXkT(m,n);
                                            ExplambdaDeltaSqXkXkT(n,m)=ExplambdaDeltaSqXkXkT(m,n);
                                            ExplambdaDeltaCubedXkXkT(n,m)=ExplambdaDeltaCubedXkXkT(m,n);
                                        end
                                    end
                                end

                                gradQ = gradQ + dN(c,k)*x_K(:,k) - (dN(c,k)+1)*ExplambdaDeltaXk+ExplambdaDeltaSqXk;
                                jacQ  = jacQ  + ExplambdaDeltaXkXkT+ExplambdaDeltaSqXkXkT-2*ExplambdaDeltaCubedXkXkT;
                            end
                        end


    %                    gradQ=0.01*gradQ;


                        if(any(any(isnan(jacQ))) || any(any(isinf(jacQ))))
                            betahat_newTemp = betahat_new(:,c);
                        else
                            betahat_newTemp = (betahat_new(:,c)-jacQ\gradQ);
                            if(any(isnan(betahat_newTemp)))
                                betahat_newTemp = betahat_new(:,c);

                            end
                        end
                        mabsDiff = max(abs(betahat_newTemp - betahat_new(:,c)));
                        if(mabsDiff<10^-2)
                            converged=1;
                        end
                        betahat_new(:,c)=betahat_newTemp;
                        iter=iter+1;
                    end
                    fprintf('\n');              
                 end 


                 %Compute the new CIF means
                 muhat_new =muhat;
                 for c=1:numCells
                     converged=0;
                     iter = 1;
                     maxIter=100;
                     while(~converged && iter<maxIter)
                        if(strcmp(fitType,'poisson'))
                            gradQ=zeros(size(muhat_new(c),2),1);
                            jacQ =zeros(size(muhat_new(c),2),size(muhat_new(c),2));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                ld = exp(terms);
                                bt = betahat(:,c);
                                ExplambdaDelta =ld +0.5*trace(ld*bt*bt'*Wk);


                                gradQ = gradQ + dN(c,k)' - ExplambdaDelta;
                                jacQ  = jacQ  - ExplambdaDelta;
                            end


                        elseif(strcmp(fitType,'binomial'))
                            gradQ=zeros(size(muhat_new(c),2),1);
                            jacQ =zeros(size(muhat_new(c),2),size(muhat_new(c),2));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                ld = exp(terms)./(1+exp(terms));
                                bt = betahat(:,c);
                                ExplambdaDelta = ld+0.5*trace(bt*bt'*(ld)*(1-ld)*(1-2*ld)*Wk);
                                ExplambdaDeltaSq = (ld)^2+...
                                    0.5*trace((ld)^2*(1-ld)*(2-3*ld)*bt*bt'*Wk);
                                ExplambdaDeltaCubed = (ld)^3+...
                                    0.5*trace(3*(ld)^3*(3-7*ld+4*(ld)^2)*bt*bt'*Wk);

                                gradQ = gradQ + dN(c,k)' -(dN(c,k)+1)*ExplambdaDelta...
                                    +ExplambdaDeltaSq;
                                jacQ  = jacQ  - (dN(c,k)+1)*ExplambdaDelta...
                                    +(dN(c,k)+3)*ExplambdaDeltaSq...
                                    -3*ExplambdaDeltaCubed;
                            end

                        end
    %                     gradQ=0.01*gradQ;
                        muhat_newTemp = (muhat_new(c)'-(1/jacQ)*gradQ)';
                        if(any(isnan(muhat_newTemp)))
                            muhat_newTemp = muhat_new(c);

                        end
                        mabsDiff = max(abs(muhat_newTemp - muhat_new(c)));
                        if(mabsDiff<10^-3)
                            converged=1;
                        end
                        muhat_new(c)=muhat_newTemp;
                        iter=iter+1;
                     end

                end

    %             Compute the history parameters
                gammahat_new = gammahat;
                if(~isempty(windowTimes) && any(any(gammahat_new~=0)))
                     for c=1:numCells
                         converged=0;
                         iter = 1;
                         maxIter=100;
                         while(~converged && iter<maxIter)
                            if(strcmp(fitType,'poisson'))
                                gradQ=zeros(size(gammahat_new(c),2),1);
                                jacQ =zeros(size(gammahat_new(c),2),size(gammahat_new(c),2));
                                for k=1:K
                                    Hk=HkAll{c};
                                    Wk = W_K(:,:,k);
                                    if(numel(gammahat)==1)
                                        gammaC=gammahat;
                                    else 
                                        gammaC=gammahat(:,c);
                                    end
                                    terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                    ld = exp(terms);
                                    bt = betahat(:,c);
                                    ExplambdaDelta =ld +0.5*trace(bt*bt'*ld*Wk);


                                    gradQ = gradQ + (dN(c,k)' - ExplambdaDelta)*Hk;
                                    jacQ  = jacQ  - ExplambdaDelta*Hk*Hk';
                                end


                            elseif(strcmp(fitType,'binomial'))
                                gradQ=zeros(size(gammahat_new(c),2),1);
                                jacQ =zeros(size(gammahat_new(c),2),size(gammahat_new(c),2));
                                for k=1:K
                                    Hk=HkAll{c};
                                    Wk = W_K(:,:,k);
                                    if(numel(gammahat)==1)
                                        gammaC=gammahat;
                                    else 
                                        gammaC=gammahat(:,c);
                                    end
                                    terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                    ld = exp(terms)./(1+exp(terms));
                                    bt = betahat(:,c);
                                    ExplambdaDelta =ld...
                                        +0.5*trace(bt*bt'*ld*(1-ld)*(1-2*ld)*Wk);
                                    ExplambdaDeltaSq=ld^2 ...
                                        +trace((ld^2*(1-ld)*(2-3*ld)*bt*bt')*Wk);
                                    ExplambdaDeltaCubed=ld^3 ...
                                        +0.5*trace((9*(ld^3)*(1-ld)^2*bt*bt'-3*(ld^4)*(1-ld)*bt*bt')*Wk);
                                    gradQ = gradQ + (dN(c,k) - (dN(c,k)+1)*ExplambdaDelta+ExplambdaDeltaSq)*Hk;
                                    jacQ  = jacQ  + -ExplambdaDelta*(dN(c,k)+1)*Hk*Hk'...
                                        +ExplambdaDeltaSq*(dN(c,k)+3)*Hk*Hk'...
                                        -ExplambdaDeltaCubed*2*Hk*Hk';
                                end

                            end


    %                         gradQ=0.01*gradQ;

                            gammahat_newTemp = (gammahat_new(:,c)-(eye(size(Hk,2),size(Hk,2))/jacQ)*gradQ');
                            if(any(isnan(gammahat_newTemp)))
                                gammahat_newTemp = gammahat_new(:,c);

                            end
                            mabsDiff = max(abs(gammahat_newTemp - gammahat_new(:,c)));
                            if(mabsDiff<10^-3)
                                converged=1;
                            end
                            gammahat_new(:,c)=gammahat_newTemp;
                            iter=iter+1;
                         end

                    end
    %                  gammahat(:,c) = gammahat_new;
                end
%              betahat =betahat_new;
%              gammahat = gammahat_new;
%              muhat = muhat_new;
            end           
        end
    
          function InfoMatrix=estimateInfoMat_mPPCO(fitType,x_K, W_K,Ahat,Qhat,Chat, Rhat,alphahat, muhat, betahat,gammahat,dN,windowTimes, HkAll,delta,ExpectationSums,Mc)
            if(nargin<15)
                Mc=500;
            end

            [numCells,K]=size(dN);
            nA = size(Ahat,2);
            nQ = size(Qhat,2);
            nC = numel(Chat);
            nR = numel(Rhat);
            nAlpha = length(alphahat);
            nMu= length(muhat);
            nB = numel(betahat);
            nG = numel(gammahat);
            Dx=size(Ahat,2);
            Dy=size(Chat,1);

            % The complete data information matrix
            Ic=zeros(nA+nQ+nC+nR+nAlpha+nMu+nB+nG,nA+nQ+nC+nR+nAlpha+nMu+nB+nG);
            %from K=1 to K-1
            Ic(1:nA,1:nA)= -pinv(Qhat)*(ExpectationSums.Sxkxk - W_K(:,:,K)-x_K(:,K)*x_K(:,K)');
%             Ic(1:nA,1:nA) = diag(diag(Ic(1:nA,1:nA)));
            offset = nA;
            Ic(offset+(1:nQ),offset+(1:nQ)) = K/2*eye(size(Qhat))/Qhat^2 -ExpectationSums.sumXkTerms/Qhat^3;
            offset = nA+nQ;
            
            for j=1:nC
                tempMat=zeros(Dy,Dx);
                
                tempMat(j) =1;
                tempMat2=tempMat*ExpectationSums.Sxkxk;
                GradC{j} = inv(Rhat)*tempMat2;
                
            end
%             Compute information of history terms
            minTime=0;
            maxTime=(size(dN,2)-1)*delta;
            

             if(~isempty(numBasis))
                basisWidth = (maxTime-minTime)/numBasis;
                sampleRate=1/delta;
                unitPulseBasis=nstColl.generateUnitImpulseBasis(basisWidth,minTime,maxTime,sampleRate);
                basisMat = unitPulseBasis.data;
             end

            jacQ =zeros(size(gamma,2),size(gamma,2));
            if(strcmp(fitType,'poisson'))
                for k=1:K
                    Hk=HkAll{k};

                    Wk = basisMat*diag(WK(:,:,k));
                    stimK=basisMat*(xK(:,k));
                    histEffect=exp(gamma*Hk')';
                    stimEffect=exp(stimK)+exp(stimK)/2.*Wk;
                    lambdaDelta = stimEffect.*histEffect;

                    jacQ  = jacQ  - (Hk.*repmat(lambdaDelta,[1 size(Hk,2)]))'*Hk;
                end

             elseif(strcmp(fitType,'binomial'))
                 for k=1:K
                    Hk=HkAll{k};
                    Wk = basisMat*diag(WK(:,:,k));
                    stimK=basisMat*(xK(:,k));

                    histEffect=exp(gamma*Hk')';
                    stimEffect=exp(stimK);
                    C = stimEffect.*histEffect;
                    M = 1./C;
                    lambdaDelta = exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));
                    ExpLambdaDelta = lambdaDelta+Wk.*(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta))/2;
                    ExpLDSquaredTimesInvExp = (lambdaDelta).^2.*1./C;
                    ExpLDCubedTimesInvExpSquared = (lambdaDelta).^3.*M.^2 +Wk/2.*(3.*M.^4.*lambdaDelta.^3+12.*lambdaDelta.^3.*M.^3-12.*M.^4.*lambdaDelta.^4);

                    jacQ  = jacQ  - (Hk.*repmat(ExpLDSquaredTimesInvExp.*dN(k,:)',[1,size(Hk,2)]))'*Hk ...
                                  - (Hk.*repmat(ExpLDSquaredTimesInvExp,[1,size(Hk,2)]))'*Hk ...
                                  - (Hk.*repmat(2*ExpLDCubedTimesInvExpSquared,[1,size(Hk,2)]))'*Hk;

                 end


            end           

            Ic(1:R,1:R)=K*eye(size(Q))/(2*(Q)^2)+(eye(size(Q))/((Q)^3))*SumXkTerms;

            if(~isempty(windowTimes))
                Ic((R+1):(R+J),(R+1):(R+J)) = -jacQ;
            end
            xKDraw = zeros(numBasis,K,Mc);
            for r=1:numBasis  
                WkuTemp=squeeze(Wku(r,r,:,:));
    %             [vec,val]=eig(Wku ); val(val<=0)=eps;
    %             Wku =vec*val*vec';
                [chol_m,p]=chol(WkuTemp);
                if(numel(chol_m)==1)
                    chol_m = diag(repmat(chol_m,[K 1]));
                end
                for c=1:Mc % for r-th step function simulate the path of size K
                    z=zeros(K,1);
                    z=normrnd(0,1,K,1);
                    xKDraw(r,:,c)=xK(r,:)+(chol_m'*z)';
                end
            end



            Im=zeros(J+R,J+R);
            ImMC=zeros(J+R,J+R);

            for c=1:Mc

                gradQGammahat=zeros(size(gamma,2),1);
                gradQQhat=zeros(1,R);        
                if(strcmp(fitType,'poisson'))
                    for k=1:K
                        Hk=HkAll{k};
                        stimK=basisMat*(xKDraw(:,k,c));
                        histEffect=exp(gamma*Hk')';
                        stimEffect=exp(stimK);
                        lambdaDelta = stimEffect.*histEffect;
                        gradQGammahat = gradQGammahat + Hk'*dN(k,:)' - Hk'*lambdaDelta;
                        if(k==1)
                            gradQQhat = ((xKDraw(:,k,c)-A*x0).*(xKDraw(:,k,c)-A*x0));
                        else
                            gradQQhat = gradQQhat+((xKDraw(:,k,c)-A*xKDraw(:,k-1,c)).*(xKDraw(:,k,c)-A*xKDraw(:,k-1,c)));
                        end

                    end
                elseif(strcmp(fitType,'binomial'))
                     for k=1:K
                        Hk=HkAll{k};
                        Wk = basisMat*diag(WK(:,:,k));
                        stimK=basisMat*(xKDraw(:,k,c));

                        histEffect=exp(gamma*Hk')';
                        stimEffect=exp(stimK);
    %                   
                        C = stimEffect.*histEffect;
                        M = 1./C;
                        lambdaDelta = exp(stimK+(gamma*Hk')')./(1+exp(stimK+(gamma*Hk')'));
                        ExpLambdaDelta = lambdaDelta+Wk.*(lambdaDelta.*(1-lambdaDelta).*(1-2*lambdaDelta))/2;
                        ExpLDSquaredTimesInvExp = (lambdaDelta).^2.*1./C;
                        ExpLDCubedTimesInvExpSquared = (lambdaDelta).^3.*M.^2 +Wk/2.*(3.*M.^4.*lambdaDelta.^3+12.*lambdaDelta.^3.*M.^3-12.*M.^4.*lambdaDelta.^4);


                        gradQGammahat = gradQGammahat + (Hk.*repmat(1-ExpLambdaDelta,[1,size(Hk,2)]))'*dN(k,:)' ...
                                          - (Hk.*repmat(ExpLDSquaredTimesInvExp./lambdaDelta,[1,size(Hk,2)]))'*lambdaDelta;
                        if(k==1)
                            gradQQhat = ((xKDraw(:,k,c)-A*x0).*(xKDraw(:,k,c)-A*x0));
                        else
                            gradQQhat = gradQQhat+((xKDraw(:,k,c)-A*xKDraw(:,k-1,c)).*(xKDraw(:,k,c)-A*xKDraw(:,k-1,c)));
                        end
                     end


                end

                gradQQhat = .5*eye(size(Q))/Q*gradQQhat - diag(K/2*eye(size(Q))/Q^2);
                ImMC(1:R,1:R)=ImMC(1:R,1:R)+gradQQhat*gradQQhat';
                if(~isempty(windowTimes))
                    ImMC((R+1):(R+J),(R+1):(R+J)) = ImMC((R+1):(R+J),(R+1):(R+J))+diag(diag(gradQGammahat*gradQGammahat'));
                end
            end
            Im=ImMC/Mc;

            InfoMatrix=Ic-Im; % Observed information matrix



        end
        function  [xKFinal,WKFinal,Ahat, Qhat, muhat, betahat, gammahat, logll,nIter,negLL]=PP_EM(dN, Ahat0, Qhat0, mu, beta, fitType,delta, gamma, windowTimes, x0, Px0,MstepMethod)
            numStates = size(Ahat0,1);
            if(nargin<12 || isempty(MstepMethod))
               MstepMethod='GLM'; %GLM or NewtonRaphson 
            end
            if(nargin<11 || isempty(Px0))
                Px0=10e-10*eye(numStates,numStates);
            end
            if(nargin<10 || isempty(x0))
                x0=zeros(numStates,1);
            end
            
            if(nargin<9 || isempty(windowTimes))
                if(isempty(gamma))
                    windowTimes =[];
                else
    %                 numWindows =length(gamma0)+1; 
                    windowTimes = 0:delta:(length(gamma)+1)*delta;
                end
            end
            if(nargin<8)
                gamma=[];
            end
            if(nargin<7 || isempty(delta))
                delta = .001;
            end
            if(nargin<6)
                fitType = 'poisson';
            end
            
            minTime=0;
            maxTime=(size(dN,2)-1)*delta;
            K=size(dN,1);
            if(~isempty(windowTimes))
                histObj = History(windowTimes,minTime,maxTime);
                for k=1:K
                    nst{k} = nspikeTrain( (find(dN(k,:)==1)-1)*delta);
                    nst{k}.setMinTime(minTime);
                    nst{k}.setMaxTime(maxTime);
                    HkAll{k} = histObj.computeHistory(nst{k}).dataToMatrix;
                end
            else
                for k=1:K
                    HkAll{k} = 0;
                end
                gammahat=0;
            end



    %         tol = 1e-3; %absolute change;
            tolAbs = 1e-3;
            tolRel = 1e-3;
            llTol  = 1e-3;
            cnt=1;

            maxIter = 100;

            
            A0 = Ahat0;
            Q0 = Qhat0;
                      
            Ahat{1} = A0;
            Qhat{1} = Q0;
            muhat{1} = mu;
            betahat{1} = beta;
            gammahat{1} = gamma;
            numToKeep=10;
          
            cnt=1;
            dLikelihood(1)=inf;
            x0hat = x0;
            negLL=0;
         
            stoppingCriteria =0;
            while(stoppingCriteria~=1 && cnt<=maxIter)
                 storeInd = mod(cnt-1,numToKeep)+1; %make zero-based then mod, then add 1
                 storeIndP1= mod(cnt,numToKeep)+1;
                 storeIndM1= mod(cnt-2,numToKeep)+1;
                disp('---------------');
                disp(['Iteration #' num2str(cnt)]);
                disp('---------------');
%                 [x_K,W_K,logll,ExpectationSums]=PP_EStep(A,Q,dN, mu, beta,fitType,delta,gamma,windowTimes, HkAll, x0,Px0)
                [x_K{storeInd},W_K{storeInd},logll(cnt),ExpectationSums{storeInd}]=...
                    DecodingAlgorithms.PP_EStep(Ahat{storeInd},Qhat{storeInd},dN, muhat{storeInd}, betahat{storeInd},fitType,delta,gammahat{storeInd},windowTimes,HkAll, x0, Px0);

%                 [Ahat, Qhat, muhat, betahat, gammahat] = PP_MStep(dN,x_K,W_K,ExpectationSums,fitType, muhat, betahat,gammahat, windowTimes,HkAll,MstepMethod)
                [Ahat{storeIndP1}, Qhat{storeIndP1}, muhat{storeIndP1}, betahat{storeIndP1}, gammahat{storeIndP1}]= ...
                    DecodingAlgorithms.PP_MStep(dN,x_K{storeInd},W_K{storeInd}, ExpectationSums{storeInd}, fitType,muhat{storeInd},betahat{storeInd}, gammahat{storeInd},windowTimes,HkAll,MstepMethod);
               
                if(cnt==1)
                    dLikelihood(cnt+1)=inf;
                else
                    dLikelihood(cnt+1)=(logll(cnt)-logll(cnt-1));%./abs(logll(cnt-1));
                end
                if(cnt==1)
                    QhatInit = Qhat{1};
                    xKInit = x_K{1};
                end
                %Plot the progress
%                 if(mod(cnt,2)==0)
                    
                    scrsz = get(0,'ScreenSize');
                    h=figure('OuterPosition',[scrsz(3)*.01 scrsz(4)*.04 scrsz(3)*.98 scrsz(4)*.95]);
                    figure(h);
                    time = linspace(minTime,maxTime,size(x_K{storeInd},2));
                    subplot(2,4,[1 2 5 6]); plot(1:cnt,logll,'k','Linewidth', 2); hy=ylabel('Log Likelihood'); hx=xlabel('Iteration'); axis auto;
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    subplot(2,4,3:4); hNew=plot(time, x_K{storeInd}','Linewidth', 2); hy=ylabel('States'); hx=xlabel('time [s]');
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold'); 
                    hold on; hOrig=plot(time, xKInit','--','Linewidth', 2); 
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                  
                    
                    subplot(2,4,7:8); hNew=plot(diag(Qhat{storeInd}),'o','Linewidth', 2); hy=ylabel('Q'); hx=xlabel('Diagonal Entry');
                    set(gca, 'XTick'       , 1:1:length(diag(Qhat{storeInd})));
                    set([hx, hy],'FontName', 'Arial','FontSize',12,'FontWeight','bold');
                    hold on; hOrig=plot(diag(QhatInit),'r.','Linewidth', 2);
                    legend([hOrig(1) hNew(1)],'Initial','Current');
                    drawnow;
%                 end
                
                if(cnt==1)
                    dMax=inf;
                else
                 dQvals = max(max(abs(sqrt(Qhat{storeInd})-sqrt(Qhat{storeIndM1}))));
                 dAvals = max(max(abs((Ahat{storeInd})-(Ahat{storeIndM1}))));
                 dMuvals = max(abs((muhat{storeInd})-(muhat{storeIndM1})));
                 dBetavals = max(max(abs((betahat{storeInd})-(betahat{storeIndM1}))));
                 dGammavals = max(max(abs((gammahat{storeInd})-(gammahat{storeIndM1}))));
                 dMax = max([dQvals,dAvals,dMuvals,dBetavals,dGammavals]);
                end


                 cnt=(cnt+1);
                
                if(dMax<tolAbs)
                    stoppingCriteria=1;
                    display(['         EM converged at iteration# ' num2str(cnt) ' b/c change in params was within criteria']);
                    negLL=0;
                end
            
                if(abs(dLikelihood(cnt))<llTol  || dLikelihood(cnt)<0)
                    stoppingCriteria=1;
                    display(['         EM stopped at iteration# ' num2str(cnt) ' b/c change in likelihood was negative']);
                    negLL=1;
                end
            

            end


            maxLLIndex  = find(logll == max(logll),1,'first');
            maxLLIndMod =  mod(maxLLIndex-1,numToKeep)+1;
            if(maxLLIndex==1)
                maxLLIndex =1;
                maxLLIndMod = 1;
            elseif(isempty(maxLLIndex))
               maxLLIndex = 1; 
               maxLLIndMod = 1;
               
            end
            nIter   = cnt-1;  
            xKFinal = x_K{maxLLIndMod};
            WKFinal = W_K{maxLLIndMod};
            Ahat = Ahat{maxLLIndMod};
            Qhat = Qhat{maxLLIndMod};
            muhat= muhat{maxLLIndMod};
            betahat = betahat{maxLLIndMod};
            gammahat = gammahat{maxLLIndMod};
            logll = logll(maxLLIndex);
  

           
        end
        function [x_K,W_K,logll,ExpectationSums]=PP_EStep(A,Q,dN, mu, beta,fitType,delta,gamma,windowTimes, HkAll, x0,Px0)
             DEBUG = 0;

          
            [numCells,K]   = size(dN); 
            Dx = size(A,2);
            
            x_p     = zeros( size(A,2), K+1 );
            x_u     = zeros( size(A,2), K );
            W_p    = zeros( size(A,2),size(A,2), K+1 );
            W_u    = zeros( size(A,2),size(A,2), K );
            x_p(:,1)= A(:,:)*x0;
            W_p(:,:,1)=A*Px0*A' + Q;
            
            for k=1:K
                [x_u(:,k), W_u(:,:,k)] = DecodingAlgorithms.PPDecode_updateLinear(x_p(:,k), W_p(:,:,k), dN,mu,beta,fitType,gamma,HkAll,k);
                [x_p(:,k+1), W_p(:,:,k+1)] = DecodingAlgorithms.PPDecode_predict(x_u(:,k), W_u(:,:,k), A(:,:,min(size(A,3),k)), Q(:,:,min(size(Q,3))));
     
            end
     
%             [x_p, W_p, x_u, W_u] = DecodingAlgorithms.PPDecodeFilterLinear(A, Q, dN,mu,beta,fitType,delta,gamma,windowTimes,x0,Px0);
            
            [x_K, W_K,Lk] = DecodingAlgorithms.kalman_smootherFromFiltered(A, x_p, W_p, x_u, W_u);
            
            numStates = size(x_K,1);
            Wku=zeros(numStates,numStates,K,K);
            Tk = zeros(numStates,numStates,K-1);
            for k=1:K
                Wku(:,:,k,k)=W_K(:,:,k);
            end

            for u=K:-1:2
                for k=(u-1):-1:(u-1)
                    Tk(:,:,k)=A;
                    Dk(:,:,k)=W_u(:,:,k)*Tk(:,:,k)'/(W_p(:,:,k+1)); %From deJong and MacKinnon 1988
                    Wku(:,:,k,u)=Dk(:,:,k)*Wku(:,:,k+1,u);
                    Wku(:,:,u,k)=Wku(:,:,k,u)';
                end
            end
            
            %All terms
            Sxkm1xk = zeros(Dx,Dx);
            Sxkm1xkm1 = zeros(Dx,Dx);
            Sxkxk = zeros(Dx,Dx);
           for k=1:K
                if(k==1)
                    Sxkm1xk   = Sxkm1xk+Px0*A'/W_p(:,:,1)*Wku(:,:,1,1);
                    Sxkm1xkm1 = Sxkm1xkm1+Px0+x0*x0';   
                else
%                   
                      Sxkm1xk =  Sxkm1xk+Wku(:,:,k-1,k)+x_K(:,k-1)*x_K(:,k)';
                       
                      Sxkm1xkm1= Sxkm1xkm1+Wku(:,:,k-1,k-1)+x_K(:,k-1)*x_K(:,k-1)';
                end
                Sxkxk = Sxkxk+Wku(:,:,k,k)+x_K(:,k)*x_K(:,k)';
           end
           Sxkxk = 0.5*(Sxkxk+Sxkxk');
           sumXkTerms = Sxkxk-A*Sxkm1xk-Sxkm1xk'*A'+A*Sxkm1xkm1*A';
           
           if(strcmp(fitType,'poisson'))
                sumPPll=0;
                for c=1:numCells
                    Hk=HkAll{c};
                    for k=1:K
                        xk = x_K(:,k);
                        if(numel(gamma)==1)
                            gammaC=gamma;
                        else 
                            gammaC=gamma(:,c);
                        end
                        terms=mu(c)+beta(:,c)'*xk+gammaC'*Hk(k,:)';
                        Wk = W_K(:,:,k);
                        ld = exp(terms);
                        bt = beta(:,c);
                        ExplambdaDelta =ld+0.5*trace(bt*bt'*ld*Wk);
                        ExplogLD = terms;
                        sumPPll=sumPPll+dN(c,k).*ExplogLD - ExplambdaDelta;
                    end
                  
                            
                end
            elseif(strcmp(fitType,'binomial'))
                sumPPll=0;
                for c=1:numCells
                    Hk=HkAll{c};
                    for k=1:K
                        xk = x_K(:,k);
                        if(numel(gamma)==1)
                            gammaC=gamma;
                        else 
                            gammaC=gamma(:,c);
                        end
                        terms=mu(c)+beta(:,c)'*xk+gammaC'*Hk(k,:)';
                        Wk = W_K(:,:,k);
                        ld = exp(terms)./(1+exp(terms));
                        bt = beta(:,c);
                        ExplambdaDelta =ld+0.5*trace(bt*bt'*ld*(1-ld)*(1-2*ld)*Wk);
                        ExplogLD = log(ld)+0.5*trace(-(bt*bt'*ld*(1-ld))*Wk);
                        sumPPll=sumPPll+dN(c,k).*ExplogLD - ExplambdaDelta;
                    end
                  
                            
                end
            end

            logll = -Dx*K/2*log(2*pi)-K/2*log(det(Q)) - Dx/2*log(2*pi) -1/2*log(det(Px0)) -Dx/2  ...
                    +sumPPll - 1/2*trace(pinv(Q)*sumXkTerms);
                    
                string0 = ['logll: ' num2str(logll)];
                disp(string0);
                if(DEBUG==1)
                    string1 = ['-K/2*log(det(Q)):' num2str(-K/2*log(det(Q)))];
                    string2= ['Constants: ' num2str(-Dx*K/2*log(2*pi)- Dx/2*log(2*pi) -Dx/2 -1/2*log(det(Px0)))];
                    string3 = ['SumPPll: ' num2str(sumPPll)];
                    string4 = ['-.5*trace(Q\sumXkTerms): ' num2str(-.5*trace(Q\sumXkTerms))];
                    

                    disp(string1);
                    disp(['Q=' num2str(diag(Q)')]);
                    disp(string2);
                    disp(string3);
                    disp(string4);

                end

                ExpectationSums.Sxkm1xkm1=Sxkm1xkm1;
                ExpectationSums.Sxkm1xk=Sxkm1xk;
                ExpectationSums.Sxkxk=Sxkxk;
                ExpectationSums.sumXkTerms=sumXkTerms;
                ExpectationSums.sumPPll=sumPPll;

        end
        function [Ahat, Qhat, muhat, betahat, gammahat] = PP_MStep(dN,x_K,W_K,ExpectationSums,fitType, muhat, betahat,gammahat, windowTimes,HkAll,MstepMethod)
            if(nargin<11 || isempty(MstepMethod))
                MstepMethod = 'GLM'; %GLM or NewtonRaphson
            end
            Sxkm1xkm1=ExpectationSums.Sxkm1xkm1;
            Sxkm1xk=ExpectationSums.Sxkm1xk;
            Sxkxk=ExpectationSums.Sxkxk;
            
            sumXkTerms=ExpectationSums.sumXkTerms;
            
            K = size(x_K,2);   
            numCells=size(dN,1);
            numStates = size(x_K,1);
%             Ahat =diag(diag(Sxkm1xk/Sxkm1xkm1));
%             [V,D] = eig(Ahat); 
%             D(D>=1)=.99999; % Make sure that the A matrix is stable
%             Ahat = V*D*V';
%             Ahat(Ahat>1)=.99999;
            Ahat = eye(numStates,numStates);
            Qhat = diag(diag(1/K*sumXkTerms));

             
            betahat_new =betahat;
            gammahat_new = gammahat;
            muhat_new = muhat;
             
            %Compute the new CIF beta using the GLM
            if(strcmp(fitType,'poisson'))
                algorithm = 'GLM';
            else
                algorithm = 'BNLRCG';
            end
            
            % Estimate params via GLM
            if(strcmp(MstepMethod,'GLM'))
                clear c; close all;
                time=(0:length(x_K)-1)*.001;
                labels = cell(1,numStates);
                labels2 = cell(1,numStates+1);
                labels2{1} = 'vel';
                for i=1:numStates
                    labels{i} = strcat('v',num2str(i));
                    labels2{i+1} = strcat('v',num2str(i));
                end
                vel = Covariate(time,x_K','vel','time','s','m/s',labels);
                baseline = Covariate(time,ones(length(time),1),'Baseline','time','s','',...
                    {'constant'});
                for i=1:size(dN,1)
                    spikeTimes = time(find(dN(i,:)==1));
                    nst{i} = nspikeTrain(spikeTimes);
                end
                nspikeColl = nstColl(nst);
                cc = CovColl({vel,baseline});
                trial = Trial(nspikeColl,cc);
                selfHist = windowTimes ; NeighborHist = []; sampleRate = 1000; 
                clear c;
                
                

                if(gammahat==0)
                    c{1} = TrialConfig({{'Baseline','constant'},labels2},sampleRate,[],NeighborHist); 
                else
                    c{1} = TrialConfig({{'Baseline','constant'},labels2},sampleRate,selfHist,NeighborHist); 
                end
                c{1}.setName('Baseline');
                cfgColl= ConfigColl(c);
                warning('OFF');

                results = Analysis.RunAnalysisForAllNeurons(trial,cfgColl,0,algorithm);
                temp = FitResSummary(results);
                tempCoeffs = squeeze(temp.getCoeffs);
                if(gammahat==0)
                    betahat(1:numStates,:) = tempCoeffs(2:(numStates+1),:);
                    muhat = tempCoeffs(1,:)';
                else
                    betahat(1:numStates,:) = tempCoeffs(2:(numStates+1),:);
                    muhat = tempCoeffs(1,:)';
                    histTemp = squeeze(temp.getHistCoeffs);
                    histTemp = reshape(histTemp, [length(windowTimes)-1 numCells]);
                    histTemp(isnan(histTemp))=0;
                    gammahat=histTemp;
                end
            else
                
            % Estimate via Newton-Raphson
                 fprintf(['****M-step for beta**** \n']);
                 for c=1:numCells
                     converged=0;
                     iter = 1;
                     maxIter=100;
                     fprintf(['neuron:' num2str(c) ' iter: ']);
                     while(~converged && iter<maxIter)

                        if(iter==1)
                            fprintf('%d',iter);
                        else
                            fprintf(',%d',iter);
                        end
                        if(strcmp(fitType,'poisson'))
                            gradQ=zeros(size(betahat_new(:,c),1),1);
                            jacQ =zeros(size(betahat_new(:,c),1),size(betahat_new(:,c),1));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                xk = x_K(:,k);
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms =muhat(c)+betahat_new(:,c)'*xk+gammaC'*Hk(k,:)';
                                ld=exp(terms);

                                numStates =length(xk);
                                ExplambdaDeltaXk = zeros(numStates,1);
                                ExplambdaDeltaXkXkT = zeros(numStates,numStates);
                                for m=1:numStates
                                     sm = zeros(numStates,1);
                                     sm(m) =1;
                                     bt=betahat_new(:,c);
                                     ExplambdaDeltaXk(m) = ld*sm'*xk+...
                                         .5*trace(ld*(bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk);
                                    for n=1:m
                                        sn = zeros(numStates,1);
                                        sn(n) =1; 
                                        ExplambdaDeltaXkXkT(n,m) = ld*xk'*sm*sn'*xk+...
                                            +trace(ld*(2*bt*xk'*sn*sm'*xk*bt'+bt*xk'*sn*sm'+sn*sm'*xk*bt'+sn*sm')*Wk);
                                        if(n~=m)
                                            ExplambdaDeltaXkXkT(n,m)=ExplambdaDeltaXkXkT(m,n);
                                        end
                                    end
                                end

                                gradQ = gradQ + (dN(c,k)*xk - ExplambdaDeltaXk);
                                jacQ  = jacQ  - ExplambdaDeltaXkXkT;
                            end


                        elseif(strcmp(fitType,'binomial'))
                            gradQ=zeros(size(betahat_new(:,c),1),1);
                            jacQ =zeros(size(betahat_new(:,c),1),size(betahat_new(:,c),1));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                xk = x_K(:,k);                    
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms =muhat(c)+betahat_new(:,c)'*xk+gammaC'*Hk(k,:)';
                                ld=exp(terms)./(1+exp(terms));

                                numStates =length(xk);
                                ExplambdaDeltaXk = zeros(numStates,1);
                                ExplambdaDeltaSqXk = zeros(numStates,1);
                                ExplambdaDeltaXkXkT = zeros(numStates,numStates);
                                ExplambdaDeltaSqXkXkT = zeros(numStates,numStates);
                                ExplambdaDeltaCubedXkXkT = zeros(numStates,numStates);
                                for m=1:numStates
                                     sm = zeros(numStates,1);
                                     sm(m) =1;
                                     bt=betahat_new(:,c);
                                     ExplambdaDeltaXk(m) = ld*sm'*xk+...
                                         +.5*trace(ld*(bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         -.5*trace((ld^2)*(3*bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         +.5*trace((ld^3)*(2*bt*xk'*sm*bt')*Wk);
                                     ExplambdaDeltaSqXk(m) = (ld)^2*sm'*xk+...
                                         +trace((ld^2)*(2*bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         -trace((ld^3)*(2*bt*xk'*sm*bt'+3*bt*xk'*sm*bt'+sm*bt'+bt*sm')*Wk)...
                                         +trace(3*(ld^4)*(bt*xk'*sm*bt')*Wk);

                                    for n=1:m
                                        sn = zeros(numStates,1);
                                        sn(n) =1; 
                                        ExplambdaDeltaXkXkT(n,m) = ld*xk'*sm*sn'*xk+...
                                            +0.5*trace((ld)*(bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm'+2*sn*sm')*Wk)...
                                            -0.5*trace((ld)^2*(3*bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm')*Wk)...
                                            +0.5*trace((ld)^3*(2*bt*xk'*sn*sm'*xk*bt')*Wk);
                                        ExplambdaDeltaSqXkXkT(n,m) = (ld)^2*xk'*sm*sn'*xk+...
                                            +trace((ld)^2*(2*bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm'+sn*sm')*Wk)...
                                            -trace((ld)^3*(5*bt*xk'*sn*sm'*xk*bt'+2*sn*sm'*xk*bt'+2*bt*xk'*sn*sm')*Wk)...
                                            +trace((ld)^4*(3*bt*xk'*sn*sm'*xk*bt')*Wk);

                                        ExplambdaDeltaCubedXkXkT(n,m) = (ld)^3*xk'*sm*sn'*xk+...
                                            +0.5*trace((ld)^3*(9*bt*xk'*sn*sm'*xk*bt'+6*sn*sm'*xk*bt'+6*bt*xk'*sn*sm'+2*sn*sm')*Wk)...
                                            -0.5*trace((ld)^4*(21*bt*xk'*sn*sm'*xk*bt'+6*sn*sm'*xk*bt'+6*bt*xk'*sn*sm')*Wk)...
                                            +0.5*trace((ld)^5*(12*bt*xk'*sn*sm'*xk*bt')*Wk);

                                        if(n~=m)
                                            ExplambdaDeltaXkXkT(n,m)=ExplambdaDeltaXkXkT(m,n);
                                            ExplambdaDeltaSqXkXkT(n,m)=ExplambdaDeltaSqXkXkT(m,n);
                                            ExplambdaDeltaCubedXkXkT(n,m)=ExplambdaDeltaCubedXkXkT(m,n);
                                        end
                                    end
                                end

                                gradQ = gradQ + dN(c,k)*x_K(:,k) - (dN(c,k)+1)*ExplambdaDeltaXk+ExplambdaDeltaSqXk;
                                jacQ  = jacQ  + ExplambdaDeltaXkXkT+ExplambdaDeltaSqXkXkT-2*ExplambdaDeltaCubedXkXkT;
                            end
                        end


                        if(any(any(isnan(jacQ))) || any(any(isinf(jacQ))))
                            betahat_newTemp = betahat_new(:,c);
                        else
                            betahat_newTemp = (betahat_new(:,c)-jacQ\gradQ);
                            if(any(isnan(betahat_newTemp)))
                                betahat_newTemp = betahat_new(:,c);

                            end
                        end
                        mabsDiff = max(abs(betahat_newTemp - betahat_new(:,c)));
                        if(mabsDiff<10^-2)
                            converged=1;
                        end
                        betahat_new(:,c)=betahat_newTemp;
                        iter=iter+1;
                    end
                    fprintf('\n');              
                 end 


                 %Compute the new CIF means
                 muhat_new =muhat;
                 for c=1:numCells
                     converged=0;
                     iter = 1;
                     maxIter=100;
                     while(~converged && iter<maxIter)
                        if(strcmp(fitType,'poisson'))
                            gradQ=zeros(size(muhat_new(c),2),1);
                            jacQ =zeros(size(muhat_new(c),2),size(muhat_new(c),2));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                ld = exp(terms);
                                bt = betahat(:,c);
                                ExplambdaDelta =ld +0.5*trace(ld*bt*bt'*Wk);


                                gradQ = gradQ + dN(c,k)' - ExplambdaDelta;
                                jacQ  = jacQ  - ExplambdaDelta;
                            end


                        elseif(strcmp(fitType,'binomial'))
                            gradQ=zeros(size(muhat_new(c),2),1);
                            jacQ =zeros(size(muhat_new(c),2),size(muhat_new(c),2));
                            for k=1:K
                                Hk=HkAll{c};
                                Wk = W_K(:,:,k);
                                if(numel(gammahat)==1)
                                    gammaC=gammahat;
                                else 
                                    gammaC=gammahat(:,c);
                                end
                                terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                ld = exp(terms)./(1+exp(terms));
                                bt = betahat(:,c);
                                ExplambdaDelta = ld+0.5*trace(bt*bt'*(ld)*(1-ld)*(1-2*ld)*Wk);
                                ExplambdaDeltaSq = (ld)^2+...
                                    0.5*trace((ld)^2*(1-ld)*(2-3*ld)*bt*bt'*Wk);
                                ExplambdaDeltaCubed = (ld)^3+...
                                    0.5*trace(3*(ld)^3*(3-7*ld+4*(ld)^2)*bt*bt'*Wk);

                                gradQ = gradQ + dN(c,k)' -(dN(c,k)+1)*ExplambdaDelta...
                                    +ExplambdaDeltaSq;
                                jacQ  = jacQ  - (dN(c,k)+1)*ExplambdaDelta...
                                    +(dN(c,k)+3)*ExplambdaDeltaSq...
                                    -3*ExplambdaDeltaCubed;
                            end

                        end
                        muhat_newTemp = (muhat_new(c)'-(1/jacQ)*gradQ)';
                        if(any(isnan(muhat_newTemp)))
                            muhat_newTemp = muhat_new(c);

                        end
                        mabsDiff = max(abs(muhat_newTemp - muhat_new(c)));
                        if(mabsDiff<10^-3)
                            converged=1;
                        end
                        muhat_new(c)=muhat_newTemp;
                        iter=iter+1;
                     end

                end

%              Compute the history parameters
                gammahat_new = gammahat;
                if(~isempty(windowTimes) && any(any(gammahat_new~=0)))
                     for c=1:numCells
                         converged=0;
                         iter = 1;
                         maxIter=100;
                         while(~converged && iter<maxIter)
                            if(strcmp(fitType,'poisson'))
                                gradQ=zeros(size(gammahat_new(c),2),1);
                                jacQ =zeros(size(gammahat_new(c),2),size(gammahat_new(c),2));
                                for k=1:K
                                    Hk=HkAll{c};
                                    Wk = W_K(:,:,k);
                                    if(numel(gammahat)==1)
                                        gammaC=gammahat;
                                    else 
                                        gammaC=gammahat(:,c);
                                    end
                                    terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                    ld = exp(terms);
                                    bt = betahat(:,c);
                                    ExplambdaDelta =ld +0.5*trace(bt*bt'*ld*Wk);


                                    gradQ = gradQ + (dN(c,k)' - ExplambdaDelta)*Hk;
                                    jacQ  = jacQ  - ExplambdaDelta*Hk*Hk';
                                end


                            elseif(strcmp(fitType,'binomial'))
                                gradQ=zeros(size(gammahat_new(c),2),1);
                                jacQ =zeros(size(gammahat_new(c),2),size(gammahat_new(c),2));
                                for k=1:K
                                    Hk=HkAll{c};
                                    Wk = W_K(:,:,k);
                                    if(numel(gammahat)==1)
                                        gammaC=gammahat;
                                    else 
                                        gammaC=gammahat(:,c);
                                    end
                                    terms=muhat_new(c)+betahat(:,c)'*x_K(:,k)+gammaC'*Hk(k,:)';
                                    ld = exp(terms)./(1+exp(terms));
                                    bt = betahat(:,c);
                                    ExplambdaDelta =ld...
                                        +0.5*trace(bt*bt'*ld*(1-ld)*(1-2*ld)*Wk);
                                    ExplambdaDeltaSq=ld^2 ...
                                        +trace((ld^2*(1-ld)*(2-3*ld)*bt*bt')*Wk);
                                    ExplambdaDeltaCubed=ld^3 ...
                                        +0.5*trace((9*(ld^3)*(1-ld)^2*bt*bt'-3*(ld^4)*(1-ld)*bt*bt')*Wk);
                                    gradQ = gradQ + (dN(c,k) - (dN(c,k)+1)*ExplambdaDelta+ExplambdaDeltaSq)*Hk;
                                    jacQ  = jacQ  + -ExplambdaDelta*(dN(c,k)+1)*Hk*Hk'...
                                        +ExplambdaDeltaSq*(dN(c,k)+3)*Hk*Hk'...
                                        -ExplambdaDeltaCubed*2*Hk*Hk';
                                end

                            end


   
                            gammahat_newTemp = (gammahat_new(:,c)-(eye(size(Hk,2),size(Hk,2))/jacQ)*gradQ');
                            if(any(isnan(gammahat_newTemp)))
                                gammahat_newTemp = gammahat_new(:,c);

                            end
                            mabsDiff = max(abs(gammahat_newTemp - gammahat_new(:,c)));
                            if(mabsDiff<10^-3)
                                converged=1;
                            end
                            gammahat_new(:,c)=gammahat_newTemp;
                            iter=iter+1;
                         end

                    end
                end
                
            end
           
        end
    end
end

