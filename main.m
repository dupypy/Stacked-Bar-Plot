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
t2_0 = [0, 3.6205, 0; 28.9199, 14.0229, 70.5849; 58.1890, 74.3470, 0];
t2_10 = [0, 9.5396, 0; 154.5885, 265.5246, 757.0792; 526.7408, 137.7570, 0];
t2_15 = [0, 26.0032, 0; 0, 0, 0; 0, 0, 0];
t2_20 = [0, 112.2641, 0; 0, 0, 0; 0, 0, 0];

Et2_0 = [0, 0.2731, 0; 3.5602, 1.3698, 9.8821; 9.9527, 5.2955, 0];
Et2_10 = [0, 0.3350, 0; 4.3584, 112.9001, 125.8526; 164.9465, 8.5631, 0];
Et2_15 = [0, 3.0280, 0; 0, 0, 0; 0, 0, 0];
Et2_20 = [0, 3.4422, 0; 0, 0, 0; 0, 0, 0];

viscosityData_raw = cat(3, t2_0, t2_10, t2_15, t2_20);

%viscosityData = viscosityData_raw(:,:,2:end) - cumsum(viscosityData_raw(:,:,1:end-1), 3)
viscosityData_diff = viscosityData_raw(:,:,2:end) - viscosityData_raw(:,:,1:end-1);
viscosityData = cat(3,viscosityData_raw(:,:,1), viscosityData_diff);
errorData = cat(3, Et2_0, Et2_10, Et2_15, Et2_20);
viscosityData(viscosityData<0) = 0;

plotBarStackGroups(viscosityData, viscosityData_raw, errorData, groupLabels, barLabels);