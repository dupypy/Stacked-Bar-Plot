%% Read Data from Image
% Last Edited: 24 August 2018
% Summary: Uses ginput to define ROI of input image (a graph). 
% Gives datapoints based on image anaylsis. 
% Note: Matlab indexes images from the top left, not the bottom left. 
% This is why in Crop Image to ROI
% we use Y top to bottom, and X bottom to top. 

%% Load Data
clc
clear all
[filename, user_canceled] = imgetfile
A = imread(filename); % file of image to be analysed
BW = im2bw(A,.2); % convert to binary image
BW = imcomplement(BW); % computes the complement of the image BW.

%% ROI Selection
imshow(BW) %show it for ginput
disp('Select your bottom-left most point in your graph.') % bottom left most point
[bottomX,bottomY]=ginput(1);
disp('Select your top-right most point in your graph.')   % top right most point
[topX,topY]=ginput(1);
beep
%% Crop image to ROI
BWcrop = BW(round(topY):round(bottomY),round(bottomX):round(topX)); % crop
BWcrop = imcomplement(BWcrop); % centroids looks for white, not black

%% Scale input
disp('For scaling, enter image length (x).')
inputX2=input('');
disp('Enter image height (y).')
inputY2=input('');

% manual inputs
inputX1=0;
%inputX2=1200;
inputY1=0;
%inputY2=50;

%% Calculate scale factor of graph
realX=round(topX)-round(bottomX); % width of image
realY=round(topY)-round(bottomY); % height of image
inputX=inputX2-inputX1; % width of graph scale
inputY=inputY2-inputY1; % height of graph scale
scaleX=inputX/realX; % width factor for image to graph scale
scaleY=inputY/realY; % height factor for image to graph scale
beep
%% Image Processing
% Bins image into 1*height(image) segments, and caluclates the centroid of
% each bin, where the image is a long thin black rectangle with a white gap
% in the middle where the data point(s) is(are)

for n=1:length(BWcrop)-1 % for the length of the image
    sliceBW = BWcrop(:,n:n+1); % bin it to 1*height
    props = regionprops(sliceBW,'Centroid'); % find the centroid of white
    catchError=false; % boolean used for catching errors
    zeroError=false; % boolean in case there is no previous centroid
    try
        centroid = props.Centroid; % get centroid data
    catch % if error thrown due to no centroid
        if n>1 % if there is a previous value for 
            catchError=true; % use previous Y lovation using below code
        else
            dataY(n)=-1; % make first Y value negative
            zeroError=true;
        end
    end
    if zeroError==false
        if catchError==true % if an error was found (and there are previous centroid entries)
            dataY(n)=dataY(n-1); % use previous Y location
        else
            dataY(n)=centroid(1,2); % save current Y location
        end
    end
    dataX(n)=n; % save X location
end

%% Remove zeros/negatives to shift data
ZCount=0;
for n=1:length(dataY)-1 % for the length of the image
    if dataY(n)<0
        ZCount=ZCount+1;
    end
end

dataXz=dataX(ZCount+1:length(dataX));
dataYz=dataY(ZCount+1:length(dataY));

%% Scale Results
dataXs=(dataXz*scaleX)+inputX1; % multiplies data by scaling factor and shifts data to origin
dataYs=(dataYz*scaleY)+inputY2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Straighten Image
dataM=((dataYs(length(dataYs)-1))-(dataYs(1)))/((dataXs(length(dataXs)-1))-(dataXs(1))); % slope of best fit line
for n=1:length(dataYs)-1
   dataYn(n) = dataYs(n)-((dataM*dataXs(n))+dataYs(1)); % original y - best fit equation (m*x+b)
   dataXn(n)=dataXs(n);
end

p=polyfit(dataXn,dataYn,2); % Order 2 polynomial fit
for n=1:length(dataYn)-1
    dataXp(n)=dataXn(n);
    Yp(n) = (p(1)*dataXn(n)^2)+(p(2)*dataXn(n))+p(3); % original y - best fit equation (m*x+b)
    dataYp(n) = dataYn(n)-Yp(n);
end

%% Filter Data (LowPass)
d = designfilt('lowpassiir','FilterOrder',15,'PassbandFrequency',35e3,'PassbandRipple',0.2,'SampleRate',200e3);
dataYf=filter(d,dataYp);

%% Sin curve fit
y=dataYf;
x=dataXp(1:length(dataYf));
yu = max(y);
yl = min(y);
yr = (yu-yl);                               % Range of ‘y’
yz = y-yu+(yr/2);
zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
per = 2*mean(diff(zx));                     % Estimate period
ym = mean(y);                               % Estimate offset
fit = @(b,x)  b(1).*(sin(2*pi*x./b(2) + 2*pi/b(3))) + b(4);    % Function to fit
fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
s = fminsearch(fcn, [yr;  per;  -1;  ym])                       % Minimise Least-Squares
% s(1): sine wave amplitude (in units of y)
% s(2): period (in units of x)
% s(3): phase (phase is s(2)/(2*s(3)) in units of x)
% s(4): offset (in units of y)

%% Plot Results
figure(1) % plots data points over original figure
hold on
imshow(BW);
plot(dataX+bottomX,dataY+topY,'ro')
title('Raw Data Fitting')

figure(2)
subplot(3,1,1) % plots data on straightened axis
plot(dataXn,dataYn);
hold on
plot(dataXp,Yp)
title('Data aligned to axis and normalized to zero')
subplot(3,1,2) % plots data on straightened axis
plot(dataXp,dataYp);
title('Straightened data')
subplot(3,1,3) % plots sin of data
xp = linspace(min(x),max(x));
plot(x,y,'b',xp,fit(s,xp),'r')
grid
title('Data fitted with sin curve')
per