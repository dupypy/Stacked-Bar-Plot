function [] = plotBarStackGroups(stackData, groupLabels)
%% Parameters: 
%%      stackData is a 3D matrix (i.e., stackData(i, j, k) => (Group, Stack, StackElement)) 
%%      groupLabels is a CELL type (i.e., { 'a', 1 , 20, 'because' };)
%% 
NumGroupsPerAxis = size(stackData, 1);
NumStacksPerGroup = size(stackData, 2);

% Count off the number of bins
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75; % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumStacksPerGroup;
figure
    hold on;
for i=1:NumStacksPerGroup

    Y = squeeze(stackData(:,i,:));
    
    % Center the bars:
    internalPosCount = i-((NumStacksPerGroup+1)/2);
    
    % Offset the group draw positions:
    groupDrawPos = (internalPosCount)*groupOffset+groupBins;
    
    h(i,:) = bar(Y, 'stacked');
    set(h(i,1),'facecolor','b','edgecolor','k'); 
    set(h(i,2),'facecolor','c','edgecolor','k'); 
    set(h(i,3),'facecolor','y','edgecolor','k'); 
    set(h(i,4),'facecolor','r','edgecolor','k');
    set(h(i,:),'BarWidth',groupOffset);
    set(h(i,:),'XData',groupDrawPos); 
end

% Add bar labels:
barLabels={'1%', '2%', '3%'};

% Bar labeling:
for j=1:NumGroupsPerAxis
    text(groupDrawPos(j),sum(Y(j,:),2),... 
        barLabels{i},'VerticalAlignment','bottom','HorizontalAlignment','center');
end

hold off;
set(gca,'XTickMode','manual');
set(gca,'XTick',1:NumGroupsPerAxis);
set(gca,'XTickLabelMode','manual');
set(gca,'XTickLabel',groupLabels);

% Add axis labels:
xlabel('t1 (s)')
ylabel('viscosity (mPa*s)')

% Add a legend:
legend('t2 = 0s', 't2 = 5s', 't2 = 10s', 't2 = 15s')
end 