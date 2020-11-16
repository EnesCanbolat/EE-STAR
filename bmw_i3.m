% BMW i3 acceleration.
t_max = 50;
t_step= 500;
t=linspace(0,t_max,t_step+1); % 0 to 15 seconds, in 0.1 sec. steps
vel=zeros(1,t_step+1); % 151 readings of velocity
dT=t_max/(t_step+1); % 0.1 second time step
%from motor characteristic
eff=0.98; % in percent
Tmax=250; % Nm
Pmax=125000; %W
G=9.665; % gear ratio
r=0.39; % radius of the wheel in m
Crr=0.0045;
m=1420; % weight of the car in kg
g=9.8; %m/s^2
air_density=1.25; %kg*m^-3
Cd=0.29;  
A=2.38; %Frontal area of the car in m^2
vel_c=Pmax/(Tmax*(G/r)); %critical velocity in m/s
v_max = 150/3.6; % maximum velocity in m/s 
for n= 1:t_step
if vel(n)<vel_c % Torque constant till this point
vel(n+1) = vel(n) + dT*((((eff*Tmax*G)/r)-(Crr*m*g))/(1.01*m) - (((0.5*air_density*A*Cd)/(1.01*m))*(vel(n)^2)));
elseif vel(n) > v_max
% Controller stops any more speed increase
vel(n+1) = vel(n);
else  %vel(n)>=vel_c
vel(n+1)=vel(n)+dT*(((eff*G*Tmax*vel_c)/(1.01*r*m*vel(n)))-((Crr*m*g)/(1.05*m))- (((0.5*air_density*A*Cd)/(1.01*m))*(vel(n)^2)));
end
end
vel=vel.*3.6; % Multiply by 3.6 to convert m/sec to kph
i=1;
while vel(i) < 100 
    i = i+1; 
end
perf = t(i);
i2=1;
while vel(i2) < 60 
    i2 = i2+1; 
end
perf2 = t(i2);
fprintf('The vehicle reach 60km/h from 0 in %.2f sec \n',perf2); 
fprintf('The vehicle reach 100km/h from 0 in %.2f sec \n',perf); 
plot(t,vel); 
grid on;
xlabel('Time/seconds');
ylabel('Velocity/kph');
title('Full power (WOT) acceleration of BMW i3');