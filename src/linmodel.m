function [T, M, eu] = linmodel(P,S,V)

% [T, M, eu] = linmodel(P,S,V)
%   Solves the log-linear model with GENSYS
% Inputs:
%     P     :   Structure of parameters
%     S     :   Structure of steady state values
%     V     :   Structure of variable locations and names
% Output:
%     T     :   Transition matrix
%     M     :   Impact matrix
%     eu    :   [existence, uniqueness]

%---------------------------------------------
%   Initialize GENSYS components
%---------------------------------------------
G0 = zeros(V.nvar);
G1 = zeros(V.nvar);
Psi = zeros(V.nvar,V.nshock);
Pi = zeros(V.nvar,V.nfore);
CC = zeros(V.nvar,1);
j = 0;
%---------------------------------------------
j=j+1;  % [ARC] (1)
%---------------------------------------------
G0(j,V.c) = S.c;
G0(j,V.y) = -S.y;
%---------------------------------------------
j=j+1;  % [Interest Rate Rule] (2)
%---------------------------------------------
G0(j,V.in) = 1;
G0(j,V.pi) = -P.phipi*(1-P.rhoi);
G0(j,V.mp) = -1;
G1(j,V.in) = P.rhoi;
%---------------------------------------------
j=j+1;  % [Notional Interest Rate] (3) 
%---------------------------------------------
G0(j,V.in) = 1;
G0(j,V.i) = -1;
%---------------------------------------------
j=j+1;  % [Inverse MUC] (4)
%---------------------------------------------
G0(j,V.lam) = 1;
G0(j,V.a) = 1;
G0(j,V.c) = -1;
%---------------------------------------------
j=j+1;  % [FOC Labor] (5)
%---------------------------------------------
G0(j,V.w) = 1;
G0(j,V.a) = -1;
G0(j,V.n) = -P.eta;
G0(j,V.lam) = -1;
%---------------------------------------------
j=j+1;  % [FOC Bond] (6)
%---------------------------------------------
G0(j,V.elam) = 1;
G0(j,V.epi) = 1;
G0(j,V.eg) = 1;
G0(j,V.lam) = -1;
G0(j,V.i) = -1;
%---------------------------------------------
j=j+1;  % [Firm Pricing] (7)
%---------------------------------------------
G0(j,V.epi) = P.varphi*P.beta;
G0(j,V.pi) = -P.varphi;
G0(j,V.w) = P.theta*S.w;
%---------------------------------------------
j=j+1;  % [Production Function] (8) 
%---------------------------------------------
G0(j,V.y) = 1;
G0(j,V.n) = -1;
%---------------------------------------------
j=j+1;  % [Growth Process] 
%---------------------------------------------
G0(j,V.g) = 1;
G1(j,V.g) = P.rhog;
Psi(j,V.epsg) = P.sige;
%---------------------------------------------
j=j+1;  % [Risk Premium Shock Process] 
%---------------------------------------------
G0(j,V.a) = 1;
G1(j,V.a) = P.rhoa;
Psi(j,V.epsa) = P.sigu;
%---------------------------------------------
j=j+1;  % [Monetary Policy Shock Process] 
%---------------------------------------------
G0(j,V.mp) = 1;
G1(j,V.mp) = P.rhomp;
Psi(j,V.epsmp) = P.sigv;
%---------------------------------------------
j=j+1;  %   [FE pi] 
%---------------------------------------------
G0(j,V.pi) = 1;
G1(j,V.epi) = 1;
Pi(j,V.fepi) = 1;
%---------------------------------------------
j=j+1;  %   [FE g] 
%---------------------------------------------
G0(j,V.g) = 1;
G1(j,V.eg) = 1;
Pi(j,V.feg) = 1;
%---------------------------------------------
j=j+1;  %   [FE lam] 
%---------------------------------------------
G0(j,V.lam) = 1;
G1(j,V.elam) = 1;
Pi(j,V.felam) = 1;

%---------------------------------------------
%   Solve Linear Model
%---------------------------------------------
[T,~,M,~,~,~,~,eu] = gensys(G0,G1,CC,Psi,Pi);        
