clear; close all;

% Define the file name
filename = '240829_114429.txt'; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CHANGE

% Import the data from the file
data = importdata(filename);

rawTime = data.data(:, 1);
rawLVDT = data.data(:, 2);


%% Experiment parameters

rho_sed = 2.6; % density of silica in g/cm^3 <<<<<< CHANGE
dry_mass = 96; % dry mass of sediment in g <<<<<<< CHANGE
H0 = 25.4; % mm, initial height <<<<<<< CHANGE
Diameter = 6.25; % in cm
radius = Diameter / 2; % in cm
Vs = dry_mass / rho_sed; % dry volume in cm^3
H0 = 22.2; % mm, initial height
A = pi * (radius)^2; % cross-sectional area in cm^2
Hs = Vs / A * 10; % equivalent height of solids in mm
LVDTcoef = 5.5175; % LVDT calibration coefficient (V/mm)


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
xlabel('Time (s)');
ylabel('LVDT');
title('LVDT vs Time Local');
grid on;



% Calculate Axial Strain
Axial =  LVDT / H0 * 100; % percent axial strain

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
SQRTtime_1 =sqrt(step1_time - step1_time(1));
AxialSTRN_1 = step1_LVDT / H0 * 100;

plot(SQRTtime_1, AxialSTRN_1, '.'); axis ij
xlabel('sqrt(time) (s^{0.5})');

ylabel('Axial Strain %');

grid on;

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
    selectedSQRTTime = SQRTtime_1(idx1:idx2);
    selectedAxial = AxialSTRN_1(idx1:idx2);

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

f = fitlm(selectedSQRTTime, selectedAxial)

figure;
plot(f); axis ij
xlabel('sqrt(Time)');
ylabel('Axial Strain %');
grid on


figure;

% properties of the first line
slope_x1 = f.Coefficients.Estimate(2);
intercept = f.Coefficients.Estimate(1);
2.7
%slope second line
slope_x2 = slope_x1 * (1 - 0.15);


plot(SQRTtime_1, AxialSTRN_1, '.'); axis ij
xlabel('sqrt(Time)');
ylabel('Axial Strain %');

hold on
fplot(@(x) x*slope_x1 + intercept, 'r-' ); axis ij
hold on 
fplot(@(x) x*slope_x2+ intercept, 'b-' )
grid on
xlim([0, 300])
ylim([min(AxialSTRN_1), max(AxialSTRN_1)])

%%

% Instructions for selecting the point corresponding to t90
disp('Click on the plot to select the point corresponding to t90.');

% Let the user manually pick the point and save the x-coordinate as t90
[x_t90, ~] = ginput(1);

% Save the x-coordinate as t90
t90 = (x_t90)^2; % [s] square to get t90 in seconds

% Display the selected t90 value
disp(['t90 (Time at selected point): ', num2str(t90)]);

% Plot the selected point on the graph
plot(x_t90, 0, 'go', 'MarkerSize', 10, 'DisplayName', 'Point t90'); % y-coordinate is arbitrary here for display
xline(x_t90, 'g--', 'LineWidth', 1.5); % Plot a vertical line at t90

% Add a legend
legend('Location', 'best');

hold off



%% Caclulating the consolidation coefficient

mm2m = 1e-6;
mm2cm = 0.01;
H0 = 22.2; % mm initial sample thickness
cv = mm2cm * (0.848 * (H0/2)^2) / t90 ; % cm^2/s

% Display the result
disp(['The Consolidation coefficient (Cv) is ', num2str(cv), ' cm²/s']);

se = f.Coefficients.SE(2);

% Display the result
disp(['The standard error of the regression slope is ', num2str(se)]);
