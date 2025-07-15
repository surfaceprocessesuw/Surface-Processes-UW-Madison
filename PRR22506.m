% Clear the workspace and close all figures
clear;
close all;
%%
% Data
MeanTau = [13.3216 10.4654 21.4426 32.7647 52.3102 63.4305 114.5585 135.0704 237.0222 340.5228];
SigmaN = [9.8000 19.6000 39.2000 49.0000 68.6000 78.4000 166.6000 196.0000 352.8000 509.6000];

% Linear fit
p = polyfit(SigmaN, MeanTau, 1); 

% Slope and angle calculations
slope = p(1);
angle_radians = atan(slope); 
angle_degrees = rad2deg(angle_radians); 

fprintf('Slope: %.4f\n', slope);
fprintf('Angle (radians): %.4f\n', angle_radians);
fprintf('Angle (degrees): %.4f\n', angle_degrees);

% Create figure
figure('Color', 'w'); 
plot(SigmaN, MeanTau, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.1, 0.4, 0.8], ...
    'MarkerEdgeColor', 'k');
hold on;

SigmaN_fit = linspace(0, 600);  % Extend from 0 to max(SigmaN)

MeanTau_fit = polyval(p, SigmaN_fit);

plot(SigmaN_fit, MeanTau_fit, 'r-', 'LineWidth', 2);

% Axis labels
xlabel('\sigma_N (kPa)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('\tau (kPa)', 'FontSize', 12, 'FontWeight', 'bold');

grid on;
set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.6);
xticks(0:100:600);  % Set x-axis ticks at intervals of 50, from 0 to 400
yticks(0:50:400)

eqnStr = sprintf('y = %.2fx + %.2f', p(1), p(2))

title('PRR22506', 'FontSize', 14, 'FontWeight', 'bold'); 

set(gca, 'FontSize', 14, 'LineWidth', 1);
hold off;


%%
MeanTau_fit_2 = polyval(p, SigmaN);

SS_res = sum((MeanTau - MeanTau_fit_2).^2);  
SS_tot = sum((MeanTau - mean(MeanTau)).^2);
R_squared = 1 - (SS_res / SS_tot)

% RMSE calculation
RMSE = sqrt(mean((MeanTau - MeanTau_fit_2).^2))