clear; close all;

% Define the file name
filename = '240830_114737.txt'; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CHANGE

% Import the data from the file
data = importdata(filename);

rawTime = data.data(:, 1);
rawLVDT = data.data(:, 2);


%% Experiment parameters

rho_sed = 2.6; % density of silica in g/cm^3 <<< CHANGE
dry_mass = 96; % dry mass of sediment in g <<< CHANGE
H0 = 25.4; % mm, initial height <<< CHANGE
Diameter = 6.25; % in cm
radius = Diameter / 2; % in cm
Vs = dry_mass / rho_sed; % dry volume in cm^3
H0 = 22.2; % mm, initial height
A = pi * (radius)^2; % cross-sectional area in cm^2
Hs = Vs / A * 10; % equivalent height of solids in mm
LVDTcoef = 5.5175; % LVDT calibration coefficient (V/mm)
Tv50 = 0.197; %Timefactor at 50% deformation

% Initial void ratio
e0 = (H0 - Hs)/Hs;

%% Convert timestamps and extract LVDT data

timediff = 5;
timedata = rawTime/86400;
timedata = timedata + datenum(1904, 1, 1);
TimeLocal = datetime(timedata, 'ConvertFrom', 'datenum') - hours(timediff);
TimeSeconds = seconds(TimeLocal - TimeLocal(1));

% Extract LVDT data
LVDT = (rawLVDT) * LVDTcoef;
zeroLVDT = LVDT(1);
LVDT = LVDT - zeroLVDT;

% Plot Axial Strain vs Time
figure;
plot(TimeLocal, LVDT, '-o'); axis ij
xlabel('Local time');
ylabel('LVDT');
title('LVDT vs Time Local');
grid on;

% Calculate Axial Strain
Axial = LVDT / H0 * 100; % percent axial strain

% Plot Axial Strain vs Time
figure;
plot(TimeSeconds, Axial, '-o'); axis ij
xlabel('Time (s)');
ylabel('Axial Strain %');
title('Axial Strain vs Time (seconds)');
grid on;

step_counter = 1;

while true
    % Instructions for selecting points
    disp('Zoom, pan, and click on the plot to add data tips. Press Enter in the Command Window after placing exactly two data tips.');

    % Enable data cursor mode
    dcm_obj = datacursormode(gcf);
    datacursormode on;

    % Wait until the user presses Enter in the Command Window
    pause;

    % Retrieve data tips from the current figure
    cursor_info = getCursorInfo(dcm_obj);

    % Check if exactly two points were selected
    if length(cursor_info) ~= 2
        disp('Error: Please select exactly two points.');
        continue;
    end

    % Get the indices of the selected points directly
    idx1 = cursor_info(1).DataIndex;
    idx2 = cursor_info(2).DataIndex;

    % Ensure idx1 is less than idx2
    if idx1 > idx2
        temp = idx1;
        idx1 = idx2;
        idx2 = temp;
    end

    % Extract the data between these points (including the points themselves)
    selectedTime = TimeSeconds(idx1:idx2);
    selectedLVDT = LVDT(idx1:idx2);

    % Store the data in separate variables as vectors
    eval(['step' num2str(step_counter) '_time = selectedTime;']);
    eval(['step' num2str(step_counter) '_LVDT = selectedLVDT;']);

    % Increment the counter
    step_counter = step_counter + 1;

    % Ask the user if they want to select more points
    answer = questdlg('Do you want to select another pair of points?', ...
                      'Continue', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        break;
    end

    % Delete existing data tips before the next selection
    delete(findall(gcf,'type','hggroup'));
end

disp('Data extraction completed.');

%%
figure;
time_1 =(step1_time - step1_time(1))/60;
AxialSTRN_1 = step1_LVDT / H0 * 100;
semilogx(time_1, AxialSTRN_1, '.'); axis ij
xlabel('time (min)');
ylabel('Axial Strain %');
grid on;

step_counter = 1;

while true
    % Instructions for selecting points
    disp('Zoom, pan, and click on the plot to add data tips. Press Enter in the Command Window after placing exactly two data tips.');

    % Enable data cursor mode
    dcm_obj = datacursormode(gcf);
    datacursormode on;

    % Wait until the user presses Enter in the Command Window
    pause;

    % Retrieve data tips from the current figure
    cursor_info = getCursorInfo(dcm_obj);

    % Check if exactly two points were selected
    if length(cursor_info) ~= 2
        disp('Error: Please select exactly two points.');
        continue;
    end

    % Get the indices of the selected points directly
    idx1 = cursor_info(1).DataIndex;
    idx2 = cursor_info(2).DataIndex;

    % Ensure idx1 is less than idx2
    if idx1 > idx2
        temp = idx1;
        idx1 = idx2;
        idx2 = temp;
    end

    % Extract the data between these points (including the points themselves)
    selectedTime = time_1(idx1:idx2);
    selectedAxial = AxialSTRN_1(idx1:idx2);

% Store the data in separate variables as vectors
    eval(['step' num2str(step_counter) '_TIME = selectedTime;']);
    eval(['step' num2str(step_counter) '_Axial = selectedAxial;']);

    % Increment the counter
    step_counter = step_counter + 1;

    % Ask the user if they want to select more points
    answer = questdlg('Do you want to select another pair of points?', ...
                      'Continue', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        break;
    end

    % Delete existing data tips before the next selection
    delete(findall(gcf,'type','hggroup'));
  
end

disp('Data extraction completed.');

% fit regressions through selected intervals
f1 = fitlm(log10(step1_TIME), step1_Axial)
f2 = fitlm(log10(step2_TIME), step2_Axial)

% Get coefficients for f1 and f2
coeffs_f1 = f1.Coefficients.Estimate;
coeffs_f2 = f2.Coefficients.Estimate;

f3 = figure;

plot(f1); axis ij
hold
plot(f2)
hold on
fplot(@(x) coeffs_f1(1) + coeffs_f1(2) * x, 'g-', 'LineWidth', 2)
fplot(@(x) coeffs_f2(1) + coeffs_f2(2) * x, 'm-', 'LineWidth', 2)

grid on
ylim([0 max(AxialSTRN_1)])
xlim([0 max(log10(time_1))])
title('Picking the intersection point a')
xlabel('log(Time)');
ylabel('Axial Strain %');


% Instructions for selecting the intersection point
disp('Click on the plot to select the intersection point "A"');

% Let the user manually pick the intersection point
[x_intersect, y_intersect] = ginput(1);

% Save the y-coordinate of the picked point as D100
D100 = y_intersect;

% Display the picked point and the saved D100 value
disp(['Intersection point selected at: (', num2str(x_intersect), ', ', num2str(y_intersect), ')']);
disp(['D100 (Axial Strain at intersection): ', num2str(D100)]);

% Plot the selected point on the graph
hold on;
plot(x_intersect, y_intersect, 'ro', 'MarkerSize', 10, 'DisplayName', 'Selected Intersection');
legend('Location', 'best');
hold off;


%%
figure;
semilogx(time_1, AxialSTRN_1, '.'); axis ij
%xlabel('sqrt(time) (s^{0.5})');
xlabel('time (min)');
ylabel('Axial Strain %');
grid on;


% Instructions for selecting the first point
disp('Click on the plot to select the first point (B).');

% Let the user manually pick the first point (B)
[x_B, y_B] = ginput(1);

% Save the selected point as B
B = [x_B, y_B];

% Plot the selected point B on the graph
hold on;
plot(x_B, y_B, 'ro', 'MarkerSize', 10, 'DisplayName', 'Point B');

% Plot a vertical line at the x-coordinate of point B
xline(4*x_B, 'r--', 'LineWidth', 1.5);

% Instructions for selecting the second point
disp('Now click on the plot to select the second point (C).');

% Let the user manually pick the second point (C)
[x_C, y_C] = ginput(1);

% Save the selected point as C
C = [x_C, y_C];

% Plot the selected point C on the graph
plot(x_C, y_C, 'bo', 'MarkerSize', 10, 'DisplayName', 'Point C');

% Finalize the plot
legend('Location', 'best');

% Difference between the y-intercept of C from B
delx = y_B - y_C;

%D0 intitial deformation
D0 = y_B - delx

% Deformation at t50
D50 = (D0 + D100)/2;

% Plot a vertical line at the x-coordinate of point B
yline(D50, 'b--', 'LineWidth', 1.5);

% Instructions for selecting the third point
disp('Finally, click on the plot to select the third point (t50).');

% manually pick the third point corresponding to t50
[x_t50, y_t50] = ginput(1);

% Save the y-intercept of the third point as t50
t50 = y_t50;

% Plot the selected point t50 on the graph
plot(x_t50, y_t50, 'go', 'MarkerSize', 10, 'DisplayName', 'Point t50');

% Plot a vertical line at the x-coordinate of point t50
xline(x_t50, 'k--', 'LineWidth', 1.5);

%% Calculating Cv

Hdr = (H0/2)/10 ; % Drainage distance, ie half sediment height in cm
t50 = t50*60
Cv = (Tv50 * Hdr^2)/t50

% Display the result
disp(['The Consolidation coefficient (Cv) is ', num2str(Cv), ' cm²/s']);
