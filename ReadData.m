clear all
close all
%% Load Previous Data
prompt = 'Load Previous Data? ';
answer = input(prompt, 's')
if answer == 'yes'
    load viscosity.mat
    load error.mat
    
elseif answer == 'no'
    t2_0 = zeros(3,3);
    t2_10 = zeros(3,3);
    t2_15 = zeros(3,3);
    t2_20 = zeros(3,3);
    viscosityData_raw = cat(3, t2_0, t2_10, t2_15, t2_20);
    
    Et2_0 = zeros(3,3);
    Et2_10 = zeros(3,3);
    Et2_15 = zeros(3,3);
    Et2_20 = zeros(3,3);
    errorData = cat(3, t2_0, t2_10, t2_15, t2_20);
end

%% User input
for N = 1:numel(viscosityData_raw)
    
    prompt = 'EGDMA concentration = ';
    Conc = input(prompt)
    prompt = 't1 = ';
    t1 = input(prompt)
    prompt = 't2 = ';
    t2 = input(prompt)
    filepath = uigetdir
    
%% Fitting
    fil = fullfile(filepath,'*.csv')
    d = dir(fil)
    fittype = 'a*[(1 + (b*x)^2)^((n-1)/2)]';
    fitResult = [];
    
    for k=1:numel(d)
        filename = fullfile(filepath,d(k).name)
        T = readtable(filename);
        rate = table2array(T(:, 8));
        viscosity = table2array(T(:, 9));
        figure
        plot(rate, viscosity,'o')
        set(gca, 'YScale', 'log', 'XScale', 'log')
        %pause
        [critX,critY] = ginput(1);
        [f1,gof] = fit(rate,viscosity,fittype, 'startpoint', [critY, 0.05, 0.5],...
            'exclude', rate < critX);
        hold on
        plot(f1)
        c = coeffvalues(f1);
        fitResult = [fitResult; c(1)];
        
    end
    
    avg = mean(fitResult)
    S = std(fitResult)
    
%% Assign Value to Matrix
    if t2 == 0
        m = 1;
    elseif t2 == 10
        m = 2;
    elseif t2 == 15
        m = 3;
    else t2 == 20
        m = 4;
    end
    
    if Conc == 1
        colmn = 1;
    elseif Conc == 2
        colmn = 2;
    else Conc == 3
        colmn = 3;
    end
    
    if t1 == 100
        row = 1;
    elseif t1 == 110
        row = 2;
    else t1 == 120
        row = 3;
    end
    
    viscosityData_raw(row, colmn, m) = avg;
    errorData(row, colmn, m) = S;
    hold on
    
    save('viscosity.mat', 'viscosityData_raw')
    save('error.mat', 'errorData')
end