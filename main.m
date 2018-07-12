clear all
close all
%% User Input
NumStacksPerGroup = 3; %for wt%: 1%, 2%, 3%
NumGroupsPerAxis = 3;  %for t1's: 100s, 110s, 120s
NumStackElements = 4;  %for t2's: 0s, 10s, 15s, 20s

% labels to use on tick marks for groups:
groupLabels = {100; 110; 120};
% labels to mark each concentration
barLabels = {'1%', '2%', '3%'};

% experimental viscosity data (in mPa*s)
% different t2s are grouped with square brackets
% different t1s are separated by semicolons
% different wt% are separated by commas

%fake data
%t2_0 =  [2, 2, 3; 4, 3, 7; 4, 2, 5];
%t2_10 =  [10, 13, 15; 12, 15, 18; 11, 17, 19];
%t2_15 = [210, 240, 260; 250, 280, 290; 220, 230, 270];
%t2_20 = [3200, 3400, 3500; 3200, 3600, 3800; 3400, 3600, 3900];

%Et2_0 = [1, 1, 1; 1, 1, 1; 1, 1, 1];
%Et2_10 = [1, 1, 1; 1, 1, 1; 1, 1, 1];
%Et2_15 = [1, 1, 1; 1, 1, 1; 1, 1, 1];
%Et2_20 = [1, 1, 1; 1, 1, 1; 1, 1, 1];

%real data
t2_0 = [0, 3.6222, 0; 28.8237, 14.0229, 70.5849; 58.2891, 66.5564, 0];
t2_10 = [0, 9.5, 0; 154.6, 571.3, 1055.3; 1211.1, 175.6, 0];
t2_15 = [0, 25.9757, 0; 0, 0, 0; 0, 0, 0];
t2_20 = [0, 418.4068, 0; 0, 0, 0; 0, 0, 0];

Et2_0 = [0, 0.2732, 0; 3.6321, 1.3698, 9.8821; 10.0428, 14.2315, 0];
Et2_10 = [0, 0.3632, 0; 4.3583, 530.0980, 517.6684; 991.1328, 65.0078, 0];
Et2_15 = [0, 2.9810, 0; 0, 0, 0; 0, 0, 0];
Et2_20 = [0, 530.4584, 0; 0, 0, 0; 0, 0, 0];

viscosityData_raw = cat(3, t2_0, t2_10, t2_15, t2_20);

%viscosityData = viscosityData_raw(:,:,2:end) - cumsum(viscosityData_raw(:,:,1:end-1), 3)
viscosityData_diff = viscosityData_raw(:,:,2:end) - viscosityData_raw(:,:,1:end-1);
viscosityData = cat(3,viscosityData_raw(:,:,1), viscosityData_diff);
errorData = cat(3, Et2_0, Et2_10, Et2_15, Et2_20);
viscosityData(viscosityData<0) = 0;

plotBarStackGroups(viscosityData, viscosityData_raw, errorData, groupLabels, barLabels);