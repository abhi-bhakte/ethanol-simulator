% CSTR model taken from
%
% Klatt, K.U. and S. Engell, "Ruehrkesselreaktor mit Parallel- und Folgereaktion"  In S. Engell, editor,
%    Nichtlineare Regelung - Methoden, Werkzeuge, Anwendungen.  VDI-Berichte Nr. 1026, pages 101-108,
%    VDI-Verlag, Duesseldorf, 1993.
%
% Description
% This model describes the dynamics of a single CSTR with van der Vusse reaction:
%
% A-->B-->C
% 2A-->D
%
% The inlet is pure cyclopentadiene (substance A) that reacts to form cyclopentenol (B) and two
%    unwanted by-products, cyclopentanediol (C) and dicyclopentadiene (D).  Since C and D are
%    unwanted and do not react further, their concentrations are not computed.

function xdot = cstr_kaushik(t,x)

global mKf FF k10 kw thetaKin cA0

% Inputs (5)
% Vdot/VR (hr^-1)
% FF = u(1,1);  % 14 (h^-1)
% Feed concentration (mol/mL)
% k10 = u(2,1); % 1.287e12; % hr^-1
% Rate constant
% kw   = u(3,1); % 4032e3; % J/hr-m^2-K
% Heat transfer coefficient between jacket and reactor

% cA0=u(2,1);  % 5.1 mol/L
% % Feed Temperature (K)
% theta0=u(3,1); % 104.9 + 273.15 K
% % Coolant Mass flow rate (kg/h)
% mKf = u(4,1); % 6.5 kg/h
% % Coolant inlet Temperature (K)
% thetaKin = u(5,1); % 28 + 273.15 K


% States (4)
% Concentration of A in the reactor (mol/mL)
cA = x(1,1);
% Concentration of B in the reactor (mol/mL)
cB = x(2,1);
% Temperature of reactor fluid (deg K)
theta = x(3,1);
% Temperature of cooling fluid (deg K)
thetaK = x(4,1);

% Arrehnius law parameters
% Reaction A->B
% k10  =  1.287e12; % hr^-1
E1   =  -8930.3; % K
H1   =  -11e3; % J/mol
% Reaction B->C
% k20  =  1.287e12; % hr^-1
% E2   =  -9758.3; % K
% H2   =  -11.0; % kJ/mol
% % Reaction 2A->D
% k30  =  9.043e09; % L*(mol^-1)*(hr^-1)
% E3   =  -8560; % K
% H3   =  -41.85; % kJ/mol

% Density of reactor fluid
rho  =  0.9942; % g/mL
% Heat capacity of reactor fluid
Cp   =  3.01; % J/g-K
% Heat transfer coefficient between jacket and reactor
% kw   =  4032; % kJ/hr-m^2-K
% Surface area for cooling
%AR   =  0.215/50; % m^2
AR = .00108;
% Volume of the CSTR
VR   =  200; % mL
% Coolant Mass
mK   =  5e3/50; % g
% Coolant Heat Capacity
CPK  =  4.186; % J/g-K

%%-----------------------------
% Feed concentration
%cA0  = 1/18; % mol/mL  % 55.6 mol/mL
%%-----------------------------
% Feed temperature
theta0 =  28 + 273.15; % K

% Coolant inlet Temperature (K)
%thetaKin = 20 + 273.15; % K


TIMEUNITS_PER_HOUR = 3600.0;

k1=k10*exp(E1/(theta));
% k2=k20*exp(E2/(theta));
% k3=k30*exp(E3/(theta));

xdot(1,1) = (1/TIMEUNITS_PER_HOUR)* (FF*(cA0-cA) - k1*cA); 

xdot(2,1) = (1/TIMEUNITS_PER_HOUR)* (- FF*cB + k1*cA); 

xdot(3,1) =(1/TIMEUNITS_PER_HOUR) * (FF*(theta0-theta) - ...
   (1/(rho*Cp)) *(k1*cA*H1) + ...
   (kw*AR/(rho*Cp*VR))*(thetaK -theta)); 

% xdot(4,1) = (1/TIMEUNITS_PER_HOUR) * ((1/(mK*CPK))*(QdotK + kw*AR*(theta-thetaK)));

xdot(4,1) = (1/TIMEUNITS_PER_HOUR) * (((mKf/mK)*(thetaKin-thetaK) + ((kw*AR)/(mK*CPK))*(theta-thetaK)));
