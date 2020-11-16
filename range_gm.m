% Simulation of the GM EV1 running the SFUDS
% driving cycle. This simulation is for range
% measurement. The run continues until the
% battery depth of discharge > 90%
cycle=xlsread('SFUDS.xls');
K=length(cycle);
time = [cycle(1:K)]; %second
V = transpose([cycle(:,3)]); %kph
% Get the velocity values, they are in
% an array V.
N=length(V); % Find out how many readings
%Divide all velocities by 3.6, to convert to m/sec
V=V./3.6;
% First we set up the vehicle data.
m = 1540 ; % Vehicle mass+ two 70 kg passengers.
A = 1.8; % Frontal area in square metres
Cd = 0.19; % Drag coefficient
G = 37; % Gearing ratio, = G/r
eff = 0.95; % Transmission efficiency
Regen_ratio = 0.5; % This sets the proportion of the
g = 9.8;
r=0.30; % diameter of the wheel in cm
% braking that is done regeneratively
% using the motor.
bat_type='LA'; % Lead acid battery
NoCells=156; % 26 of 6 cell (12 Volt) batteries.
Capacity=60; % 60 Ah batteries. This is
% assumed to be the 10 hour rate capacity
k=1.12; % Peukert coefficient, typical for good lead acid
Pac=250; % Average power of accessories.
% These are the constants for the motor efficiency
% equation, 7.23
kc=0.3; % For copper losses
ki=0.01; % For iron losses
kw=0.000005; % For windage losses
ConL=600; % For constant electronics losses
Crr=0.0048;
% Some constants which are calculated.
Frr=Crr * m * g; % Equation 7.1
Rin= (0.022/Capacity)*NoCells; % Int. res, Equ. 2.2
Rin = Rin + 0.05; % Add a little to make allowance for
% connecting leads.
PeuCap= ((Capacity/10)^k)*10; % See equation 2.12
% Set up arrays for storing data for battery,
% and distance traveled. All set to zero at start.
% These first arrays are for storing the values at
% the end of each cycle.
% We shall assume that no more than 100 of any cycle is
% completed. (If there are, an error message will be
% displayed, and we can adjust this number.)
DoD_end = zeros(1,100);
CR_end = zeros(1,100);
D_end = zeros(1,100);
% We now need similar arrays for use within each cycle.
DoD=zeros(1,N); % Depth of discharge, as in Chap. 2
CR=zeros(1,N); % Charge removed from battery, Peukert
% corrected, as in Chap 2.
D=zeros(1,N); % Record of distance traveled in km.
CY=1;
% CY controls the outer loop, and counts the number
% of cycles completed. We want to keep cycling till the
% battery is flat. This we define as being more than
% 90% discharged. That is, DoD end > 0.9
% We also use the variable XX to monitor the discharge,
% and to stop the loop going too far.
DD=0; % Initially zero.
while DD < 0.9
%Beginning of a cycle.************
% Call the script file that performs one
% complete cycle.
one_cycle;
% One complete cycle done.
% Now update the end of cycle values.
DoD_end(CY) = DoD(N);
CR_end(CY) = CR(N);
D_end(CY) = D(N);
% Now reset the values of these "inner" arrays
% ready for the next cycle. They should start
% where they left off.
DoD(1)=DoD(N); CR(1)=CR(N);D(1)=D(N);
DD=DoD_end(CY); % Update state of discharge
%END OF ONE CYCLE ***************
CY = CY +1;
end
plot(D_end,DoD_end,'k+');
grid on
ylabel('Depth of discharge');
xlabel('Distance traveled/km');
title('Graph of Distance vs. DoD ');
 figure
 plot(Pmot_out);
grid on;
xlabel('Motor power (Watts)');
ylabel('Time (seconds)');
title('Graph of motor power vs time for GMEV1 in the SFUDS cycle');
