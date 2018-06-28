clear all
close all
%% User Input
NumStacksPerGroup = 3; %for wt%: 1%, 2%, 3%
NumGroupsPerAxis = 5;  %for t1's: 80s, 90, 100s, 110s, 120s
NumStackElements = 4;  %for t2's: 0s, 5s, 10s, 15s

% labels to use on tick marks for groups:
groupLabels = {80; 90; 100; 110; 120};
% labels to mark each concentration
barLabels = {'1%', '2%', '3%'};

% experimental viscosity data (in mPa*s)
% different t2s are grouped with square brackets
% different t1s are separated by semicolons
% different wt% are separated by commas

t2_0 =  [2, 2, 3; 4, 3, 7; 4, 2, 5; 4, 3, 6; 7, 8, 9];
t2_5 =  [10, 13, 15; 12, 15, 18; 11, 17, 19; 13, 16, 18; 13, 18, 19];
t2_10 = [210, 240, 260; 250, 280, 290; 220, 230, 270; 270, 290, 280; 240, 250, 290];
t2_15 = [3200, 3400, 3500; 3200, 3600, 3800; 3400, 3600, 3900; 3500, 3700, 3900; 3600, 3800, 4000];
Et2_0 = [1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1];
Et2_5 = [1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1];
Et2_10 = [1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1];
Et2_15 = [1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1; 1, 1, 1];


viscosityData_raw = cat(3, t2_0, t2_5, t2_10, t2_15);

%viscosityData = viscosityData_raw(:,:,2:end) - cumsum(viscosityData_raw(:,:,1:end-1), 3)
viscosityData_diff = viscosityData_raw(:,:,2:end) - viscosityData_raw(:,:,1:end-1);
viscosityData = cat(3,viscosityData_raw(:,:,1), viscosityData_diff);
errorData = cat(3, Et2_0, Et2_5, Et2_10, Et2_15);
viscosityData(viscosityData<0) = 0;

plotBarStackGroups(viscosityData, viscosityData_raw, errorData, groupLabels, barLabels);

