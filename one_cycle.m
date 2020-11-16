% ******************************
% ONE CYCLE
% This script file performs one cycle, of any
% drive cycle of N points with any vehicle and
% for lead acid or NiCad batteries.
% All the appropriate variables must be set
% by the calling program.
%% *******************************
% driving_cycle;
% N=length(V);
% DoD=zeros(1,N); % Depth of discharge, as in Chap. 2
% CR=zeros(1,N); % Charge removed from battery, Peukert
%% *******************************
Torque=zeros(1,N);
omega=zeros(1,N);
E=zeros(1,N);
I=zeros(1,N);
Pmot_out = zeros(1,N);
for C=2:N
accel=V(C) - V(C-1);
Fad = 0.5 * 1.25 * A * Cd * V(C)^2; % Equ. 7.2
Fhc = 0; % Eq. 7.3, assume flat
Fla = 1.05 * m * accel;
Frr = Crr*m*g;
% The mass is increased modestly to compensate for
% the fact that we have excluded the moment of inertia
Pte = (Frr + Fad + Fhc + Fla)*V(C); %Equ 7.9 & 7.23
omega(C) = G * V(C); % if G is only gear ratio divide r however if it is
%G/r ratio just take G for example GMEV
if omega(C) == 0 % Stationary
Pte=0;
Pmot_in=0; % No power into motor
Torque(C)=0;
eff_mot=0.5; % Dummy value, to make sure not zero.

elseif omega(C) > 0 % Moving
   if Pte < 0
Pte = Regen_ratio * Pte; % Reduce the power if braking, as not all will be by the motor.
   end                  
% We now calculate the output power of the motor,
% Which is different from that at the wheels, because
% of transmission losses.
 if Pte>=0
    Pmot_out(C)=Pte/eff; % Motor power> shaft power
    elseif Pte<0
    Pmot_out(C)=Pte * eff; % Motor power diminished
 end% if engine braking.
%kw=0.00001;
%kc=1.5;
%ki=0.1;
%ConL=20;
%Pac=50;
%NoCells=15;
%k=1.05;
 Torque(C)=Pmot_out(C)/omega(C); % Basic equation, P=T * omega
%  if Torque(C)>0 % Now use equation 7.23
%     eff_mot=(Torque(C)*omega(C))/((Torque(C)*omega(C))+((Torque(C)^2)*kc)+(omega(C)*ki)+((omega(C)^3)*kw)+ConL);
%     elseif Torque<0
%     eff_mot=(-Torque(C)*omega(C))/((-Torque(C)*omega(C)) + ((Torque(C)^2)*kc)+(omega(C)*ki)+((omega(C)^3)*kw)+ConL);
%  end
 eff_mot=0.95;
 if Pmot_out(C) >= 0
    Pmot_in = Pmot_out(C)/eff_mot; % Equ 7.23
    elseif Pmot_out(C) < 0
    Pmot_in = Pmot_out(C) * eff_mot;
 end
end
 Pac = 250;
 %bat_type=input('Please type your battery type\n','s');
Pbat = Pmot_in + Pac; % Equation 7.27
%% Additional
% bat_type='LI';
% NoCells=96; % 26 of 6 cell (12 Volt) batteries.
% Capacity=120; % 60 Ah batteries. This is
% Rin= (0.022/Capacity)*NoCells; % Int. res, Equ. 2.2
% Rin = Rin + 0.05; % Add a little to make allowance for
% % connecting leads.
% k=1.09;
% PeuCap= ((Capacity/10)^k)*10; % See equation 2.12
% Regen_ratio = 0.5;
%%
 if bat_type=='NC'
% Find the open circuit voltage of a nickel cadmium
% battery at any value of depth of discharge
% The depth of discharge value must be between
% 0 (fully charged) and 1.0 (flat).
if DoD(C)<0
	error('Depth of discharge <0.')
	end
if DoD(C) > 1
   error('Depth of discharge >1')
end
% The NiCad ocv is approximately linear over three distinct
% steps, 0 to 0.1, 0.1 to 0.9 and 0.9 to 1.0 depth of discharge.
% N is the number of cells
if DoD(C) < 0.1
   E(C)= (1.36 - (0.6*DoD(C))) * NoCells;
   %return;
end

if DoD(C) < 0.9
    E(C)= (1.31625 - (0.1625*DoD(C))) * NoCells;
   %return;
end

if DoD(C) >= 0.9
   E(C)= (1.17 - (1.3*(DoD(C)- 0.9))) * NoCells;
   %return;
end
% Three different formulas for the three segments of the discharge curve.
 E(C)=NoCells*( -8.2816 *(DoD(C)^7)  +  23.5749*(DoD(C)^6) -30*(DoD(C)^5) +23.7053*(DoD(C)^4) -12.5877*(DoD(C)^3) + 4.1315*DoD(C)*DoD(C) - 0.8658*DoD(C) +1.37);
    elseif bat_type=='LA'
        if DoD(C)<0
error('Depth of discharge <0.');
end
if DoD(C) > 1
error('Depth of discharge >1')
end
% See equation >2.10 in text.
E(C) = (2.15 - ((2.15-2.00)*DoD(C))) * NoCells;
 elseif bat_type=='LI'
    DoD(C)=1-DoD(C);
    if DoD(C)<0
    error('Depth of discharge <0.');
    end
    if DoD(C) > 1
    error('Depth of discharge >1')
    end
E(C) = NoCells*(-8.719e-17*DoD(C)^9 - 2.638e-14*DoD(C)^8 + 1.978e-11*DoD(C)^7 - 3.857e-9*DoD(C)^6 + 3.681e-7*DoD(C)^5 - 1.947e-5*DoD(C)^4 + 5.86e-4*DoD(C)^3 - 0.0099*DoD(C)^2 + 0.0968*DoD(C) +3.6);
DoD(C)=1-DoD(C);
 else
    error('Invalid battery type');
 end
if Pbat > 0 % Use Equ. 2.20
I(C) = (E(C) -((E(C)* E(C)) - (4.*Rin*Pbat))^0.5)/(2*Rin);
CR(C) = CR(C-1) +((I(C-1)^k)/3600); %Equation 2.18
elseif Pbat==0
I(C)=0;
elseif Pbat <0
% Regenerative braking. Use Equ. 2.22, and
% double the internal resistance.
Pbat = - 1 * Pbat;
I(C) = (-E(C) + ( E(C)* E(C) + (4*2*Rin*Pbat))^0.5)/(2*2*Rin);
CR(C) = CR(C-1) - (I(C-1)/3600); %Equation 2.23
end
DoD(C) = CR(C)/PeuCap; %Equation 2.19
if DoD(C)>1
DoD(C) =1;
end 
% Since we are taking one second time intervals,
% the distance traveled in metres is the same
% as the velocity. Divide by 1000 for km.
D(C) = D(C-1) + (V(C)/1000);
XDATA(C)=omega(C); % See Section 7.4.4 for the use
YDATA(C)=Torque(C); % of these two arrays.
end
% Now return to calling program.