close all; clear all; clc;

%% Create new data/load previous data
prompt = 'Load previous data? yes/no? ';
answer = input(prompt,'s')

if strcmpi(answer,'yes')
    load eta0_fit.mat
    load eta0error_fit.mat
    load lamda_fit.mat
    load a_fit.mat
    load n_fit.mat
    load sse_fit.mat
    load r2_fit.mat
    load rmse_fit.mat
    
elseif strcmpi(answer,'no')
    % creation of t2 files for: eta0
    eta0_t2_0  = zeros(3,3);
    eta0_t2_10 = zeros(3,3);
    eta0_t2_15 = zeros(3,3);
    eta0_t2_20 = zeros(3,3);
    eta0_fitData = cat(3, eta0_t2_0, eta0_t2_10, eta0_t2_15, eta0_t2_20);
    
    % creation of t2 files for: error (standard deviation)
    error_t2_0 = zeros(3,3);
    error_t2_10 = zeros(3,3);
    error_t2_15 = zeros(3,3);
    error_t2_20 = zeros(3,3);
    eta0error_fitData = cat(3, error_t2_0, error_t2_10, error_t2_15, error_t2_20);
    
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
    
    % creation of t2 files for: r2
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
for N = 1:numel(eta0_fitData)
    prompt = 'EGDMA concentration = ';
    Conc = input(prompt)
    prompt = 't1 = ';
    t1 = input(prompt)
    prompt = 't2 = ';
    t2 = input(prompt)

    % Creation of empty data sets
    eta0_fit = [];
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
        shrate = table2array(T(:, 8));
        viscosity = table2array(T(:, 9));
        
        figure
        plot(shrate, viscosity,'b.','markers', 10)
        set(gca, 'YScale', 'log', 'XScale', 'log')
        
        % selection of points by user
        % 1st selection = eta0 guess, 2nd selection = lamda guess
        [x,y] = ginput(2);
        
        %starting points: 
        [f1,gof] = fit(shrate, viscosity, ft, 'StartPoint', [y(1), 1/x(2), 0.5, 0.5],...
            'Lower', [0, 0.001, 0, 0], ...
            'Upper', [Inf, 100, Inf, 1]);
            %'Exclude', shrate < x(1));
            %where startincg points are listed in the order: eta0, lamda, a, n
        hold on
        plot(f1)
        c = coeffvalues(f1);
        
        eta0_fit = [eta0_fit; c(1)]
        lamda_fit = [lamda_fit; c(2)];
        a_fit = [a_fit; c(3)];
        n_fit = [n_fit; c(4)];
        gofmatrix = cell2mat(struct2cell(gof))';
        sse_fit = [sse_fit; gofmatrix(1)]
        r2_fit = [r2_fit; gofmatrix(2)];
        rmse_fit = [rmse_fit; gofmatrix(5)]
    end
    %prompt user if data needs to be modified
    prompt = 'Need to modify data? yes/no? ';
    answer = input(prompt,'s')
    
    if strcmpi(answer,'yes')
        eta0_Modified = eta0_fit;
        outlier_removal = 'Enter row number of outlier to be removed = ';
        outlier_val = input(outlier_removal)
        
        eta0_Modified(outlier_val) = [];
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
        
        eta0_avg = mean(eta0_Modified);
        eta0error_avg = std(eta0_Modified);
        lamda_avg = mean(lamda_Modified);
        a_avg = mean(a_Modified);
        n_avg = mean(n_Modified);
        sse_avg = mean(sse_Modified);
        r2_avg = mean(r2_Modified);
        rmse_avg = mean(rmse_Modified);
        
    elseif strcmpi(answer,'no')
        eta0_avg = mean(eta0_fit);
        eta0error_avg = std(eta0_fit);
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
    
    eta0_fitData(row, colmn, m) = eta0_avg;
    eta0error_fitData(row, colmn, m) = eta0error_avg;
    lamda_fitData(row, colmn, m) = lamda_avg;
    a_fitData(row, colmn, m) =  a_avg;
    n_fitData(row, colmn, m) = n_avg;
    sse_fitData(row, colmn, m) = sse_avg;
    r2_fitData(row, colmn, m) = r2_avg;
    rmse_fitData(row, colmn, m) = rmse_avg;
    
    save('eta0_fit.mat', 'eta0_fitData')
    save('eta0error_fit.mat', 'eta0error_fitData')
    save('lamda_fit.mat', 'lamda_fitData')
    save('a_fit.mat', 'a_fitData')
    save('n_fit.mat', 'n_fitData')
    save('sse_fit.mat', 'sse_fitData')
    save('r2_fit.mat', 'r2_fitData')
    save('rmse_fit.mat', 'rmse_fitData')
end