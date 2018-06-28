function [] = plotBarStackGroups(stackData, viscosityData_raw, errorData, groupLabels, barLabels)
%% Parameters: 
%%      stackData is a 3D matrix (i.e., stackData(i, j, k) => (Group, Stack, StackElement)) 
%%      groupLabels is a CELL type (i.e., { 'a', 1 , 20, 'because' };)
%% 
NumGroupsPerAxis = size(stackData, 1);
NumStacksPerGroup = size(stackData, 2);
%barLabels={'1%', '2%', '3%'};
% Count off the number of bins
groupBins = 1:NumGroupsPerAxis;
MaxGroupWidth = 0.75; % Fraction of 1. If 1, then we have all bars in groups touching
groupOffset = MaxGroupWidth/NumStacksPerGroup;
figure
    hold on;
for i=1:NumStacksPerGroup
    % for each concentration
    Y = squeeze(stackData(:,i,:));
    EY = squeeze(errorData(:,i,:));
    Y_raw = squeeze(viscosityData_raw(:,i,:));
    
    % Center the bars:
    internalPosCount = i-((NumStacksPerGroup+1)/2);
    
    % Offset the group draw positions:
    groupDrawPos = (internalPosCount)*groupOffset+groupBins
    
    h(i,:) = bar(Y, 'stacked');
    for k = 1:5
    errorbar(repmat(groupDrawPos(k), 1, 4), Y_raw(k,:), EY(k,:), 'LineStyle','none');
    end
    set(h(i,1),'facecolor','b','edgecolor','k'); 
    set(h(i,2),'facecolor','c','edgecolor','k'); 
    set(h(i,3),'facecolor','y','edgecolor','k'); 
    set(h(i,4),'facecolor','r','edgecolor','k');
    set(h(i,:),'BarWidth',groupOffset);
    set(h(i,:),'XData',groupDrawPos); 
    
    % Bar labeling:
for j=1:NumGroupsPerAxis
    text(groupDrawPos(j),sum(Y(j,:),2),... 
        barLabels{i},'VerticalAlignment','bottom','HorizontalAlignment','center');
end

end

% Add bar labels:

hold off;
set(gca,'XTickMode','manual');
set(gca,'XTick',1:NumGroupsPerAxis);
set(gca,'XTickLabelMode','manual');
set(gca,'XTickLabel',groupLabels);
set(gca,'Yscale', 'log')

% Add axis labels:
xlabel('t1 (s)')
ylabel('viscosity (mPa*s)')

% Add a legend:
leg = legend('t2 = 0s', 't2 = 5s', 't2 = 10s', 't2 = 15s')
set(leg, 'location', 'bestoutside')
end 