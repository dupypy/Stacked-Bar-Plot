close all; clear all; clc;

%% Create new data/load previous data
prompt = 'Load previous data? yes/no? ';
answer = input(prompt,'s')

if strcmpi(answer,'yes')
    load viscosity.mat
    load error.mat
    load turningpoint.mat
    load powerlawexponent.mat
    load sse.mat
    load rsquare.mat
    load rmse.mat
    
elseif strcmpi(answer,'no')
    % creation of t2 files for: eta_0
    t2_0  = zeros(3,3);
    t2_10 = zeros(3,3);
    t2_15 = zeros(3,3);
    t2_20 = zeros(3,3);
    viscosityData_raw = cat(3, t2_0, t2_10, t2_15, t2_20);
    
    % creation of t2 files for: error
    Et2_0 = zeros(3,3);
    Et2_10 = zeros(3,3);
    Et2_15 = zeros(3,3);
    Et2_20 = zeros(3,3);
    errorData = cat(3, t2_0, t2_10, t2_15, t2_20);
    
    % creation of t2 files for: turning point
    tpt2_0 = zeros (3,3);
    tpt2_10 = zeros(3,3);
    tpt2_15 = zeros(3,3);
    tpt2_20 = zeros(3,3);
    turningPointData = cat(3, t2_0, t2_10, t2_15, t2_20);
   
    % creation of t2 files for: power-law exp
    plet2_0 = zeros (3,3);
    plet2_10 = zeros(3,3);
    plet2_15 = zeros(3,3);
    plet2_20 = zeros(3,3);
    powerlawExponentData = cat(3, t2_0, t2_10, t2_15, t2_20);
    
    % creation of t2 files for: sse
    sset2_0 = zeros (3,3);
    sset2_10 = zeros(3,3);
    sset2_15 = zeros(3,3);
    sset2_20 = zeros(3,3);
    gofsseData = cat(3, t2_0, t2_10, t2_15, t2_20);
    
    % creation of t2 files for: r^2
    rsquaret2_0 = zeros (3,3);
    rsquaret2_10 = zeros(3,3);
    rsquaret2_15 = zeros(3,3);
    rsquaret2_20 = zeros(3,3);
    gofrsquareData = cat(3, t2_0, t2_10, t2_15, t2_20);
    
    % creation of t2 files for: rmse
    rmset2_0 = zeros (3,3);
    rmset2_10 = zeros(3,3);
    rmset2_15 = zeros(3,3);
    rmset2_20 = zeros(3,3);
    gofrmseData = cat(3, t2_0, t2_10, t2_15, t2_20);
end

%% Fitting of model parameters
% Solution condition entry
for N = 1:numel(viscosityData_raw)
    prompt = 'EGDMA concentration = ';
    Conc = input(prompt)
    prompt = 't1 = ';
    t1 = input(prompt)
    prompt = 't2 = ';
    t2 = input(prompt)

    % Creation of empty data sets
    fitResult = [];
    turningPoint = [];
    powerlawExponent = [];
    gofsse = [];
    gofrsquare = [];
    gofrmse = [];
    
    % access desired file(s)
    filepath = uigetdir('D:\3D Printing Project\Rheology Data\Selected Rheology Data for Project (as of 08-29)');
    fil = fullfile(filepath,'*.csv');
    d = dir(fil);
    
    % fitting
    fittype = 'a*[(1 + (b*x)^2)^((n-1)/2)]';
    for k=1:numel(d)
        filename = fullfile(filepath,d(k).name)
        T = readtable(filename);
        rate = table2array(T(:, 8));
        viscosity = table2array(T(:, 9));
        figure
        plot(rate, viscosity,'o')
        set(gca, 'YScale', 'log', 'XScale', 'log')
        [critX,critY] = ginput(2);
        [f1,gof] = fit(rate,viscosity,fittype, 'startpoint', [critY(1), 1/critX(2), 0.5],...
            'Lower', [0, 0, 0], ...
            'Upper', [Inf, Inf, 1], ...
            'Exclude', rate < critX(1));
        hold on
        plot(f1)
        c = coeffvalues(f1);
        
        fitResult = [fitResult; c(1)]
        turningPoint = [turningPoint; c(2)];
        powerlawExponent = [powerlawExponent; c(3)];
        gofmatrix = cell2mat(struct2cell(gof))';
        gofsse = [gofsse; gofmatrix(1)]
        gofrsquare = [gofrsquare; gofmatrix(2)]
        gofrmse = [gofrmse; gofmatrix(5)]
    end
    
    %prompt user if data needs to be modified
    prompt = 'Need to modify data? yes/no? ';
    answer = input(prompt,'s')
    
    if strcmpi(answer,'yes')
        fitResultModified = fitResult;
        outlier_removal = 'enter row number of outlier to be removed = ';
        outlier_val = input(outlier_removal)
        fitResultModified(outlier_val) = [];
        turningPointModified = turningPoint;
        turningPointModified(outlier_val) = [];
        powerlawExponentModified = powerlawExponent;
        powerlawExponentModified(outlier_val) = [];
        gofsseModified = gofsse;
        gofsseModified(outlier_val) = [];
        gofrsquareModified = gofrsquare;
        gofrsquareModified(outlier_val) = [];
        gofrmseModified = gofrmse;
        gofrmseModified(outlier_val) = [];
        
        avg = mean(fitResultModified);
        S = std(fitResultModified);
        avg_turningPoint = mean(turningPointModified);
        avg_powerlawExponent = mean(powerlawExponentModified);
        avg_gofsse = mean(gofsseModified);
        avg_gofrsquare = mean(gofrsquareModified);
        avg_gofrmse = mean(gofrmseModified);
        
    elseif strcmpi(answer,'no')
        avg = mean(fitResult);
        S = std(fitResult);
        avg_turningPoint = mean(turningPoint);
        avg_powerlawExponent = mean(powerlawExponent);
        avg_gofsse = mean(gofsse);
        avg_gofrsquare = mean(gofrsquare);
        avg_gofrmse = mean(gofrmse);
    end
    %% Assign fit values to matrix
    %assignment variable: t2
    if t2 == 0
        m = 1;
    elseif t2 == 10
        m = 2;
    elseif t2 == 15
        m = 3;
    else t2 == 20
        m = 4;
    end
    
    %assignment variable: EGDMA Concentration
    if Conc == 1
        colmn = 1;
    elseif Conc == 2
        colmn = 2;
    else Conc == 3
        colmn = 3;
    end
    
    %assignment variable: t1
    if t1 == 100
        row = 1;
    elseif t1 == 110
        row = 2;
    else t1 == 120
        row = 3;
    end
    
    viscosityData_raw(row, colmn, m) = avg;
    errorData(row, colmn, m) = S;
    turningPointData(row, colmn, m) = avg_turningPoint;
    powerlawExponentData(row, colmn, m) =  avg_powerlawExponent;
    gofsseData(row, colmn, m) = avg_gofsse;
    gofrsquareData(row, colmn, m) = avg_gofrsquare;
    gofrmseData(row, colmn, m) = avg_gofrmse;
    
    save('viscosity.mat', 'viscosityData_raw')
    save('error.mat', 'errorData')
    save('turningpoint.mat', 'turningPointData')
    save('powerlawexponent.mat', 'powerlawExponentData')
    save('sse.mat', 'gofsseData')
    save('rsquare.mat', 'gofrsquareData')
    save('rmse.mat', 'gofrmseData')
end