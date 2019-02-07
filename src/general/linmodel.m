function [T,M,eu] = linmodel(P,S,V)

% [T,M,eu] = linmodel(P,S,V)
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
j = j+1;% [ARC]
%---------------------------------------------
G0(j,V.c) = 1;
G0(j,V.y) = -1;
%---------------------------------------------
j = j+1;% [Output Definition]
%---------------------------------------------
G0(j,V.y) = 1;
G0(j,V.yf) = -1;
%---------------------------------------------
j = j+1;% [Output Growth Gap] 
%---------------------------------------------
G0(j,V.yg) = 1;
G0(j,V.g) = -1/P.g;
G0(j,V.y) = -1/S.y;
G1(j,V.y) = -1/S.y;
%---------------------------------------------
j = j+1;% [Interest Rate Rule]
%---------------------------------------------
G0(j,V.in) = 1/S.in;
G0(j,V.pi) = -P.phipi*(1-P.rhoi)/P.pi;
G0(j,V.yg) = -P.phiy*(1-P.rhoi);
G0(j,V.mp) = -1;
G1(j,V.in) = P.rhoi/S.in;
%---------------------------------------------
j=j+1;  % [Notional Interest Rate] 
%---------------------------------------------
G0(j,V.in) = 1;
G0(j,V.i) = -1;
%---------------------------------------------
j=j+1;  % [Inverse MUC]
%---------------------------------------------
G0(j,V.lam) = 1;
G0(j,V.c) = -1;
G0(j,V.g) = -P.h*S.c/P.g^2;
G1(j,V.c) = -P.h/P.g;
%---------------------------------------------
j = j+1;% [Production Function] 
%---------------------------------------------
G0(j,V.yf) = 1;
G0(j,V.n) = -1;
%---------------------------------------------
j=j+1;%	[FOC Labor]
%---------------------------------------------
G0(j,V.w) = 1/S.w;
G0(j,V.n) = -P.eta/P.n;
G0(j,V.lam) = -1/S.lam;
%---------------------------------------------
j = j+1;% [FOC Bond]
%---------------------------------------------
G0(j,V.elam) = 1/S.lam;
G0(j,V.epi) = 1/P.pi;
G0(j,V.eg) = 1/P.g;
G0(j,V.lam) = -1/S.lam;
G0(j,V.s) = -1/P.s;
G0(j,V.i) = -1/S.i;
%---------------------------------------------
j = j+1;% [Price Phillips Curve] 
%---------------------------------------------
G0(j,V.epi) = P.varphip*P.beta/P.pi;
G0(j,V.pi) = -P.varphip/P.pi;
G0(j,V.w) = P.thetap;
%---------------------------------------------
j=j+1;  % [Growth Process] 
%---------------------------------------------
G0(j,V.g) = 1;
Psi(j,V.epsg) = P.sigg;
%---------------------------------------------
j=j+1;  % [Risk Premium Process] 
%---------------------------------------------
G0(j,V.s) = 1;
G1(j,V.s) = P.rhos;
Psi(j,V.epss) = P.sigs;
%---------------------------------------------
j=j+1;  % [Interest Rate Process] 
%---------------------------------------------
G0(j,V.mp) = 1;
Psi(j,V.epsmp) = P.sigmp;

%---------------------------------------------
j=j+1;  %   [FE lam] 
%---------------------------------------------
G0(j,V.lam) = 1;
G1(j,V.elam) = 1;
Pi(j,V.felam) = 1;
%---------------------------------------------
j=j+1;  %   [FE g] 
%---------------------------------------------
G0(j,V.g) = 1;
G1(j,V.eg) = 1;
Pi(j,V.feg) = 1;
%---------------------------------------------
j=j+1;  %   [FE pi] 
%---------------------------------------------
G0(j,V.pi) = 1;
G1(j,V.epi) = 1;
Pi(j,V.fepi) = 1;

%---------------------------------------------
%   Solve Linear Model
%---------------------------------------------
[T,~,M,~,~,~,~,eu] = gensys(G0,G1,CC,Psi,Pi);        