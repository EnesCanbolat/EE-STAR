% Simulation of the BMWi3 running the WLTP driving cycle. 
% This simulation is for range, regenerative energy, torque-speed and power
% measurements for only one cycle. 
load('cycles_wltp.mat');
A=get(WLTP_class_3);
V = getdatasamples(WLTP_class_3,WLTP_class_3.time([2:1801]));
% Get the velocity values, they are in an array V.
N=length(V); 
V=V./3.6; %Divide all velocities by 3.6, to convert to m/sec
% First we set up the vehicle data.
m = 1420 ; % Vehicle mass+ two 70 kg passengers.
A = 2.38; % Frontal area in square metres
Cd = 0.29; % Drag coefficient
r=0.39; % diameter of the wheel in cm
G = 9.665/r; % Gearing ratio, = G/r
eff = 0.95; % Transmission efficiency
g = 9.8;
Regen_ratio = 0.5; % This sets the proportion of the
% braking that is done regeneratively using the motor.
bat_type='LI'; % Lithium Ion battery
NoCells=96; % 26 of 6 cell (12 Volt) batteries.
Capacity=120; % 60 Ah batteries. Assuming to be the 10 hour rate capacity
k=1.05; % Peukert coefficient, typical for good lithium ion
Pac=250; % Average power of accessories.
Crr=0.0045;
% Some constants which are calculated.
Frr=Crr * m * g; % Equation 7.1
Rin= (0.0033/Capacity)*NoCells; % Internal resistance
Rin = Rin + 0.05; % Add a little to make allowance
PeuCap= ((Capacity/10)^k)*10; % See equation (3E.12)
DoD_end = zeros(1,100);
CR_end = zeros(1,100);
D_end = zeros(1,100);
% We now need similar arrays for use within each cycle.
DoD=zeros(1,N); % Depth of discharge
CR=zeros(1,N); % Charge removed from battery, Peukert
% corrected
D=zeros(1,N); % Record of distance traveled in km.
DD=0; % Initially zero.
one_cycle;
% One complete cycle done.
% Now update the end of cycle values.
DoD_end(1) = DoD(N);
CR_end(1) = CR(N);
D_end(1) = D(N);
DD=DoD_end(1); % Update state of discharge
%END OF ONE CYCLE ***************
%CY = CY +1;
%end
% plot(D_end,DoD_end);
% ylabel('Depth of discharge');
% xlabel('Distance traveled/km');
% title('Graph of Distance vs. DoD ');
reg=0;
cons=0;
for i=1:N-1 %regenerative energy calculation
    if DoD(i+1)<DoD(i)
        reg=reg-DoD(i+1)+DoD(i);
    end
end
for i=1:N-1 %consumed energy calculation
    if DoD(i+1)>DoD(i)
        cons=cons+DoD(i+1)-DoD(i);
    end
end
total = reg+ cons;
a=(reg/total)*100;
aa=reg/cons*100;
plot(D,DoD);
grid on
xlabel('Distance (km) ');
ylabel('Speed (km/h)');
title('Graph of range in one cycle for BMWi3');
fprintf('In one cycle BMWi3 can recover the %.2f percent of the consumed energy \n',aa); 
fprintf('The ratio of regeneration energy to the total energy (consumed and recovered) is %.2f percent \n',a);
figure
plot(XDATA,YDATA,'k+');
grid on
xlabel('Angular Velocity (rad/s) ');
ylabel('Torque (N.m)');
title('Torque-Speed characteristic in one cycle for BMWi3');
figure
plot(Pmot_out);
grid on
xlabel('Time (sec) ');
ylabel('Power (W)');
title('Power characteristic in one cycle for BMWi3');