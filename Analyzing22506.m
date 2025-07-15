%% Processing Direct Shear Data for Till Project

% Clear the workspace and close all figures
clear;
close all;

%% Inputs

% Direct shear txt file name 
file = '250121_144853.txt'; %     <<<<<<<<<<<< CHANGE

%mass of weights hung from lever arm
mass = 52 % (kg) <<<<<< CHANGE

% LVDT Coefficients
C_LVDT1 = 5.5175; % [mm/V]
C_LVDT2 = 5.5343; % [mm/V]

%%
%OPTION #1

R = readtable(file); R = R(:, [1; 4; 5; 19; 20] );

% Remove rows with NaN values in DSMVelocity_mm_min_ column
R = R(~isnan(R.DSMVelocity_mm_min_), :);

R = R(R.DSMVelocity_mm_min_ >= -0, :);

% Calculate shear stress and displacement from raw data
Time = R.Time - R.Time(1);
Tau= (R.LC_kg_ - R.LC_kg_(1)) * 9.8 /1000/.01;   % Calculates measured shear stress from an initial zero (kPa)

LVDT1 = (R.rawLVDT1_V_ - R.rawLVDT1_V_(1)) * C_LVDT1; % vertical displacement (mm)
LVDT2 = (R.rawLVDT2_V_ - R.rawLVDT2_V_(1)) * -C_LVDT2; % horizontal displacement (mm)
SigmaN = mass * 10*9.8/1000/.01; % vertical stress (kPa)

%%
figure
plot(LVDT2,Tau, '.r')
xlabel('Displacement (mm)')
ylabel('Shear Force, F_{s} (kN)')
xlim([-5 10])

disp('Click on two successive points to select a range where shear stress is relatively "steady"');
[xp, yp] = ginput(2);

% Find the indices of the selected points
[~, i1] = min(abs(LVDT1 - xp(1)));
[~, i2] = min(abs(LVDT1- xp(2)));


disp('Click on the point of maximum displacement');
[xp1, yp1] = ginput(1);

% Find the indices of the selected points
[~, i1] = min(abs(LVDT1 - xp(1)));
[~, i2] = min(abs(LVDT1- xp(2)));
%%
% Calculate the average of the measured shear stress between the selected points
disp('Mean shear stress (kPa)');
meanTau = mean(Tau(i1:i2))
%Tau= Tau(i1:i2);

% Normal Stress
disp('Normal Stress in kPa');
SigmaN

% Calculate the standard deviation for the points between the selected points
disp('Standard deviation of data corresponding to mean shear stress interval');
stdTau= std(Tau(i1:i2))

% number of data included in calculation of mean shear stress
disp('number of data included in calculation of mean shear stress');
num = i2-i1

% Maximum displacement
disp('Maximum displacement in mm');
maxDisp = xp1