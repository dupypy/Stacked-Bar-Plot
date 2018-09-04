close all; clear all; clc;

%% Create new data/load previous data
prompt = 'Load previous data? yes/no? ';
answer = input(prompt,'s')

if strcmpi(answer,'yes')
    load viscosity.mat
    load error.mat
    load lamda_fit.mat
    load a_fit.mat
    load n_fit.mat
    load sse_fit.mat
    load r2_fit.mat
    load rmse_fit.mat
    
elseif strcmpi(answer,'no')
    % creation of t2 files for: eta_0 (labeled here as: viscosity)
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
    errorData = cat(3, Et2_0, Et2_10, Et2_15, Et2_20);
    
    % creation of t2 files for: lamda
    lamda_t2_0 = zeros (3,3);
    lamda_t2_10 = zeros(3,3);
    lamda_t2_15 = zeros(3,3);
    lamda_t2_20 = zeros(3,3);
    lamda_fitData = cat(3, lamda_t2_0, lamda_t2_10, lamda_t2_15, lamda_t2_20);
   
    % creation of t2 files for: a
    a_t2_0 = zeros (3,3);
    a_t2_10 = zeros(3,3);
    a_t2_15 = zeros(3,3);
    a_t2_20 = zeros(3,3);
    a_fitData = cat(3, a_t2_0, a_t2_10, a_t2_15, a_t2_20);
    
    % creation of t2 files for: n
    n_t2_0 = zeros (3,3);
    n_t2_10 = zeros(3,3);
    n_t2_15 = zeros(3,3);
    n_t2_20 = zeros(3,3);
    n_fitData = cat(3, n_t2_0, n_t2_10, n_t2_15, n_t2_20);
    
    % creation of t2 files for: sse
    sse_t2_0 = zeros (3,3);
    sse_t2_10 = zeros(3,3);
    sse_t2_15 = zeros(3,3);
    sse_t2_20 = zeros(3,3);
    sse_fitData = cat(3, sse_t2_0, sse_t2_10, sse_t2_15, sse_t2_20);
    
    % creation of t2 files for: r^2
    r2_t2_0 = zeros (3,3);
    r2_t2_10 = zeros(3,3);
    r2_t2_15 = zeros(3,3);
    r2_t2_20 = zeros(3,3);
    r2_fitData = cat(3, r2_t2_0, r2_t2_10, r2_t2_15, r2_t2_20);
    
    % creation of t2 files for: rmse
    rmse_t2_0 = zeros (3,3);
    rmse_t2_10 = zeros(3,3);
    rmse_t2_15 = zeros(3,3);
    rmse_t2_20 = zeros(3,3);
    rmse_fitData = cat(3, rmse_t2_0, rmse_t2_10, rmse_t2_15, rmse_t2_20);
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
    lamda_fit = [];
    a_fit = [];
    n_fit = [];
    sse_fit = [];
    r2_fit = [];
    rmse_fit = [];
    
    % access desired file(s)
    filepath = uigetdir('D:\3D Printing Project\Rheology Data\Selected Rheology Data for Project (as of 08-29)');
    fil = fullfile(filepath,'*.csv');
    d = dir(fil);
    
    % fitting
    ft = fittype('p*((1+(q*x)^r)^((s-1)/r))');
    for k=1:numel(d)
        filename = fullfile(filepath,d(k).name)
        T = readtable(filename);
        rate = table2array(T(:, 8));
        viscosity = table2array(T(:, 9));
        figure
        plot(rate, viscosity,'b.','markers', 10)
        set(gca, 'YScale', 'log', 'XScale', 'log')
        [x,y] = ginput(2);
        [f1,gof] = fit(rate,viscosity,ft,'StartPoint',[y(1), 1/x(2), 0.5, 0.5],...
            'Lower', [0, 0, 0, 0], ...
            'Upper', [Inf, Inf, 1, 1]);
        hold on
        plot(f1)
        c = coeffvalues(f1);
        
        fitResult = [fitResult; c(1)]
        lamda_fit = [lamda_fit; c(2)];
        a_fit = [a_fit; c(3)];
        n_fit = [n_fit; c(4)];
        gofmatrix = cell2mat(struct2cell(gof))';
        sse_fit = [sse_fit; gofmatrix(1)]
        r2_fit = [r2_fit; gofmatrix(2)]
        rmse_fit = [rmse_fit; gofmatrix(5)]
    end
    
    %prompt user if data needs to be modified
    prompt = 'Need to modify data? yes/no? ';
    answer = input(prompt,'s')
    
    if strcmpi(answer,'yes')
        fitResult_Modified = fitResult;
        outlier_removal = 'enter row number of outlier to be removed = ';
        outlier_val = input(outlier_removal)
        
        fitResult_Modified(outlier_val) = [];
        lamda_Modified = lamda_fit;
        lamda_Modified(outlier_val) = [];
        a_Modified = a_fit;
        a_Modified(outlier_val) = [];
        n_Modified = n_fit;
        n_Modified(outlier_val) = [];
        sse_Modified = sse_fit;
        sse_Modified(outlier_val) = [];
        r2_Modified = r2_fit;
        r2_Modified(outlier_val) = [];
        rmse_Modified = rmse_fit;
        rmse_Modified(outlier_val) = [];
        
        avg = mean(fitResult_Modified);
        S = std(fitResult_Modified);
        lamda_avg = mean(lamda_Modified);
        a_avg = mean(a_Modified);
        n_avg = mean(n_Modified);
        sse_avg = mean(sse_Modified);
        r2_avg = mean(r2_Modified);
        rmse_avg = mean(rmse_Modified);
        
    elseif strcmpi(answer,'no')
        avg = mean(fitResult);
        S = std(fitResult);
        lamda_avg = mean(lamda_fit);
        a_avg = mean(a_fit);
        n_avg = mean(n_fit);
        sse_avg = mean(sse_fit);
        r2_avg = mean(r2_fit);
        rmse_avg = mean(rmse_fit);
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
    lamda_fitData(row, colmn, m) = lamda_avg;
    a_fitData(row, colmn, m) =  a_avg;
    sse_fitData(row, colmn, m) = sse_avg;
    r2_fitData(row, colmn, m) = r2_avg;
    rmse_fitData(row, colmn, m) = rmse_avg;
    
    save('viscosity.mat', 'viscosityData_raw')
    save('error.mat', 'errorData')
    save('lamda_fit.mat', 'lamda_fitData')
    save('a_fit.mat', 'a_fitData')
    save('sse_fit.mat', 'sse_fitData')
    save('r2_fit.mat', 'r2_fitData')
    save('rmse_fit.mat', 'rmse_fitData')
end