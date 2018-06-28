NumStacksPerGroup = 3; %for wt%: 1%, 2%, 3%
NumGroupsPerAxis = 5;  %for t1's: 80s, 90, 100s, 110s, 120s
NumStackElements = 4;  %for t2's: 0s, 5s, 10s, 15s

% labels to use on tick marks for groups:
groupLabels = {80; 90; 100; 110; 120};

% experimental data:

stackData = cat(3, [0, 4.25E+03, 0; 5.51E+03, 8.06E+03, 0; 1.17E+04, 6.70E+04, 0; 4.25E+04, 3.25E+05, 0; 0, 8.51E+05, 0], ...
    [0, 0, 0; 0, 0, 0; 0, 0, 0; 0, 0, 0; 0, 0, 0], ...
    [0, 0, 0; 0, 0, 0; 1.72E+05, 0, 0; 0, 0, 0; 0, 0, 0], ...
    [0, 0, 0; 0, 0, 0; 0, 0, 0; 0, 0, 0; 0, 0, 0]);

plotBarStackGroups(stackData, groupLabels);
set(gca,'FontSize',12)
set(gcf,'Position',[100 100 720 650])
grid on
set(gca,'Layer','top') % put grid lines on top of stacks