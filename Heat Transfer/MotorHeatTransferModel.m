clear
clc

%{
Assumptions:
1) Motor is uniform body - model as lumped system
2) To calculate h based on Mars environment, convection across surface of
   cylinder is modeled as convection over flat plate
3) In calculating Ra, free convection near wall (in theory relationship
   only valid when Ra > 10^12
4) In calculating Ra, characteristic length is motor height
5) In calculating h, l is the characteristic length w.r.t. gravity

Conclusions:
Important variables:
    motor efficiency
    surface area for convection
    power

Irrelevant variables:
    motor operating temperature
    motor mass
    flight time
    motor effective specific heat
%}

%% Constants/Inputs

% Operational Specifications
T_motor = 50; %maximum allowable motor temperature [C]
t = 10 * 60; %flight time [s]
v_freestream = 40; %flight velocity [m/s]
v_down = 40; %downward flow speed [m/s]

% Environmental Constants
g = 3.711; %gravitational acceleration [m/s^2]
sigma = 5.67e-8; %Stefan-Boltzmann Constant [W/m^2*K^4]

T_mars = -50; %ambient temperature on Mars [C]
c_p = 730; %specific heat capacity Mars atmosphere [m/s^2*K]
rho = 0.0139; %atmospheric density [kg/m^3]
k = 0.0096; %thermal conductivity [W/m*K]
mu = 1.422e-5; %dynamic viscosity [m^2/s]
epsilon = 0.98; %motor surface emmisivity
%alpha = k / (c_p * rho); %thermal diffusivity of atmosphere [m^2/s]

% Motor Specifications
P_rotor = 5578; %power required by 1 rotor [W]
eta = 0.85; %motor efficiency [fraction]
m = 0.75; %motor mass [kg]
c_motor = 100; %approximate specific heat of motor (ranges from 15 to 420 for metals) [W/m*K]
r = 0.05; %motor radius [m]
l = 0.2; %motor height [m]

%% Required Heat Dissipation Rate

deltaT = T_motor - T_mars; %temp. difference between motor & atmosphere
T_mars = T_mars + 273.15; %convert to K
T_motor = T_motor + 273.15; %convert to K

A_noFin = (2 * pi * r * l + 2 * pi * r^2); %surface area of motor (no fins) [m^2]

P_dis = (P_rotor / eta) * (1 - eta); %power lost by 1 motor
P_accum = m * c_motor * deltaT / t; %power accumulated by one motor over flight
P_rad = epsilon * sigma * A_noFin * (T_motor^4 - T_mars^4);
Q_dot_req = P_dis - P_accum - P_rad; %required rate of heat transfer away from motor [W]

h_reqNoFin = Q_dot_req / (A_noFin * deltaT); %required convective h.t. coef. (no fins) [W/m^2*K]


%% Possible Heat Transfer Characteristics

Pr = mu * c_p / k; %Prandtl number

% Flow across cylinder (1)
l_char(1) = 2*r; %characteristic length = diameter
Re(1) = rho * v_freestream * (l_char(1)) / mu; %Reynolds number
Nu(1) = 0.3 + (0.62 * sqrt(Re(1)) * Pr^(1/3) / (1 + (0.4/Pr)^(2/3)) ^ (1/4)) *...
           (1 + (Re(1)/282000)^(5/8)) ^ (4/5); %Nusselt number
h_across = Nu(1) * k / l_char(1); %possible convective h.t. coef. (no fins) [W/m^2*K]

Q_dot_across = h_across * A_noFin * deltaT;

% Flow down over cylinder
l_char(2) = l;
Re(2) = rho * v_down * (l_char(2)) / mu; %Reynolds number
Nu(2) = 0.664 * Re(2)^0.5 * Pr^(1/3); %Nusselt number
h_down = Nu(2) * k / l_char(2); %possible convective h.t. coef. (no fins) [W/m^2*K]

Q_dot_down = h_down * A_noFin * deltaT;

%% Results
fprintf('    Required Q_dot by convection: %.2f W\n', Q_dot_req);
fprintf('Possible Q_dot (across cylinder): %.2f W\n', Q_dot_across);
fprintf('  Possible Q_dot (down cylinder): %.2f W\n\n', Q_dot_down);





