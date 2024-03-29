%{
Date     : 07-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: This program is used to calculate the pumping time of ASTA stage
Inputs   : File name (.txt) of the recorded air pressure inside the vacuum
           chamber. 
           The text data contains information as follows:
           |hh:mm:ss|pressure(mbar)|
Outputs  : The output of this program:
           1. Pumping plot with X-axis represents time and Y-axis
              represents the pressure in mbar
           2. Time required to achieve 5e06 mbar
           3. Preesure after 3 hours pumping
           4. Pressure after 4 hours pumping
           5. Final recorded pressure and duration
%}

%% Initialization
%--------------------------------------------------------------------------
% Clear all
clc; clear all; close all;

% Defined the sampling cycle (second, minute, hour)
samplingCycle = 'second';

% Import data
[fileName, pathName, ] = uigetfile('*.txt', 'Select the file');
fileLocation = fullfile(pathName, fileName);
fileID = fopen(fileLocation, 'r');
data   = textscan(fileID, '%d:%d:%d %f');
fclose(fileID);

% Get pressure data
pressure = data{1,4};
% Remove NaN value inside pressure data
idxNaN = find(isnan(pressure));
pressure(1:idxNaN(end)) = [];

% Get the sampling time
H = data{1,1}; % Hour
MI= data{1,2}; % Minute
S = data{1,3}; % Second

% Create time in duration format
timeDuration = duration(H, MI, S); 
% Calculate the sampling time in duration format
samplingTime = timeDuration(2) - timeDuration(1);
% Convert sampling time (in duration format) to second
samplingTime = seconds(samplingTime); 
% Create linear array of sampling time in second
timeDuration = samplingTime * (1:1:length(pressure));


%% Process the data
%--------------------------------------------------------------------------
% Find the sampling data where the pressure < 5e-6 mbar
pressure_5e06 = find(pressure < 5e-6);
pressure_5e06 = pressure_5e06(1);

% Find the duration to get the pressure < 5e06 mbar
duration_5e06 = duration(0,0,timeDuration(pressure_5e06));

% Find the pressure after 3 hours and 4 hours
pressure_3hrs = pressure(find(timeDuration == 60*60*3));
pressure_4hrs = pressure(find(timeDuration == 60*60*4));

% Find the final pressure and the pumping duration
pressure_final= pressure(end);
duration_final= duration(0,0,timeDuration(end));

% Print to console
disp(pressure_5e06) 
disp(duration_5e06) 
disp(pressure_3hrs) 
disp(pressure_4hrs) 
disp(pressure_final)
disp(duration_final)

%% Plot the pressure
figure(1)
plot(pressure, 'LineWidth', 2)
xlabel('Time [s]');
ylabel('Air pressure [mbar]');
grid on

%% Save Result
%--------------------------------------------------------------------------
% Create unique name
time_stamp = string(regexp(lower(fileName), '20[_-0-9]+[0-9]', 'match'));
proto_id   = string(regexp(lower(fileName), 'proto[_0-9]+[0-9]', 'match'));
test_id    = string(regexp(lower(fileName), 'tc[0-9]+', 'match'));
% Create Directory
mkdir(pathName, 'Result');

% Save file
save_name= join(string({test_id, proto_id, time_stamp}), '_');
save_name= char(save_name);
save_dir = fullfile(pathName,'Result','\',save_name);

save(save_dir); % Save workspace
saveas(gcf, save_dir); % Save figure