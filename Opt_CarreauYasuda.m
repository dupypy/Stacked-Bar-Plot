close all; clear all; clc;

%% Create new data/load previous data
prompt = 'Load previous data? yes/no? ';
answer = input(prompt,'s')

if strcmpi(answer,'yes')
    load eta0_fit.mat
    load lamda_fit.mat
    load a_fit.mat
    load n_fit.mat
    load sse_fit.mat
    load r2_fit.mat
    load rmse_fit.mat
    
elseif strcmpi(answer,'no')
    % creation of t2 files for: eta_0 
    eta0_t2_0  = zeros(3,3); 
    eta0_t2_10 = zeros(3,3); 
    eta0_t2_15 = zeros(3,3); 
    eta0_t2_20 = zeros(3,3);
    eta0_fitData = cat(3, eta0_t2_0, eta0_t2_10, eta0_t2_15, eta0_t2_20);
    
    % creation of t2 files for: lamda
    lamda_t2_0  = zeros(3,3); 
    lamda_t2_10 = zeros(3,3); 
    lamda_t2_15 = zeros(3,3); 
    lamda_t2_20 = zeros(3,3);
    lamda_fitData = cat(3, lamda_t2_0, lamda_t2_10, lamda_t2_15, lamda_t2_20);
    
    % creation of t2 files for: a
    a_t2_0  = zeros(3,3); 
    a_t2_10 = zeros(3,3); 
    a_t2_15 = zeros(3,3); 
    a_t2_20 = zeros(3,3);
    a_fitData = cat(3, a_t2_0, a_t2_10, a_t2_15, a_t2_20);
    
    % creation of t2 files for: n
    n_t2_0  = zeros(3,3); 
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

%% Optimzation of model parameters
for N = 1:numel(eta0_fitData)
    % solution condition entry
    prompt = 'EGDMA Concentration = ';
    Conc = input(prompt)
    prompt = 't1 = ';
    t1 = input(prompt)
    prompt = 't2 = ';
    t2 = input(prompt)
    
    % creation of empty data sets for model parameters
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
    for k=1:numel(d)
        filename = fullfile(filepath,d(k).name);
        % extract data from file(s) and create table(s)
        T = readtable(filename);
        shrate = table2array(T(:,8));
        viscm  = table2array(T(:,9));
        
        % selection of points by user
        % 1st selection = eta0 guess, 2nd selection = lamda guess
        figure
        plot(shrate,viscm,'b.','markers',10)
        set(gca, 'YScale', 'log', 'XScale', 'log');
        
        [x,y] = ginput(2);
        
        % define unknown parameters and make initial guesses
        g = [y(1), 1/x(2), 0.5, 0.5]; %initial guesses
        % where: g(1) = eta0; g(2) = lamda; g(3) = a; g(4) = n;
        
        % non-linear constraint function (i.e. Modified Carreau-Yasuda Model)
        % function w/full variable names:
        % visc = @(eta_0,lamda,a,n) eta_0.*((1+(lamda.*shrate).^a).^((n-1)./a));
        % function w/shortened variable names:
        visc = @(g) g(1).*((1+(g(2).*shrate).^g(3)).^((g(4)-1)./g(3)));
        
        % objective function (i.e. function to be minimized)
        objective = @(g) sum(((visc(g)-viscm)).^2);
        
        % fmincon: Find minimum of constrained nonlinear multivariable function
        % x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
        lb = zeros(size(g)); ub = [Inf, Inf, Inf, 1];
        options = optimset('Algorithm', 'interior-point', ...
            'MaxFunEval',Inf,'MaxIter',Inf);
        gopt = fmincon(objective,g,[],[],[],[],lb,ub,[],options);
        
        % display initial and optimized objective function results 
        disp(['initial objective = ' num2str(objective(g))])
        disp(['optimized objective = ' num2str(objective(gopt))])
        
        % display optimized parameter results
        disp(['optimized parameters: ' num2str(gopt)])
        
        % plot of measured vs optimized/fitted results
        hold on
        plot(shrate,visc(gopt),'r-')
        lgnd = legend('measured viscosity', 'fitted viscosity');
        set(lgnd, 'location', 'bestoutside')
        ylabel('shear viscosity (Pa s)'); xlabel('shear rate (1/s)')
        
        % save optimized parameter results
        eta0_fit = [eta0_fit; gopt(1)]
        lamda_fit = [lamda_fit; gopt(2)];
        a_fit = [a_fit; gopt(3)]; 
        n_fit = [n_fit; gopt(4)];
        
        % calculate goodness of fit variables
        sse_calc = sum((viscm - visc(g)).^2);
        r2_calc = 1-(sum((viscm - visc(g)).^2)/sum((viscm - mean(viscm)).^2));
        rmse_calc = sqrt(mean((viscm - visc(g)).^2));
        
        %save goodness of fit variable results
        sse_fit(k) = sse_calc;
        r2_fit(k) = r2_calc;
        rmse_fit(k) = rmse_calc;
    end
    % interchanges rows to columns
    sse_fit = sse_fit'
    r2_fit = r2_fit'
    rmse_fit = rmse_fit'
    
    % evaluate average optimized parameters
    eta0_avg = mean(eta0_fit);
    lamda_avg = mean(lamda_fit); 
    a_avg = mean(a_fit); 
    n_avg = mean(n_fit);
    sse_avg = mean(sse_fit);
    r2_avg = mean(r2_fit);
    rmse_avg = mean(rmse_fit);
    
    %% Assign predicted values to matrix
    % assignment variable: t2
    if t2 == 0
        m = 1;
    elseif t2 == 10
        m = 2;
    elseif t2 == 15
        m = 3;
    else t2 == 20
        m = 4;
    end
    % assignment variable: EGDMA Concentration
    if Conc == 1
        colmn = 1;
    elseif Conc == 2
        colmn = 2;
    else Conc == 3
        colmn = 3;
    end
    % assignment variable: t1
    if t1 == 100
        row = 1;
    elseif t1 == 110
        row = 2;
    else t1 == 120
        row = 3;
    end
    
    eta0_fitData(row, colmn, m) = eta0_avg;
    lamda_fitData(row, colmn, m) = lamda_avg;
    a_fitData(row, colmn, m) = a_avg;
    n_fitData(row, colmn, m) = n_avg;
    sse_fitData(row, colmn, m) = sse_avg;
    r2_fitData(row, colmn, m) = r2_avg;
    rmse_fitData(row, colmn, m) = rmse_avg;
    
    save('eta0_fit.mat', 'eta0_fitData')
    save('lamda_fit.mat', 'lamda_fitData')
    save('a_fit.mat', 'a_fitData')
    save('n_fit.mat', 'n_fitData')
    save('sse_fit.mat', 'sse_fitData')
    save('r2_fit.mat', 'r2_fitData')
    save('rmse_fit.mat', 'rmse_fitData')
end