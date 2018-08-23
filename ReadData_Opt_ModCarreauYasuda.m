close all; clear all; clc;

%% Create new data/load previous data
prompt = 'Load previous data? yes/no? ';
answer = input(prompt,'s');

if strcmpi(answer,'yes')
    load eta0_fit.mat
    load lamda_fit.mat
    load a_fit.mat
    load n_fit.mat
    
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
    
    % access desired file(s)
    filepath = uigetdir('D:\3D Printing Project\Rheology Data\Selected Rheology Data for Project (as of 07-26)');
    fil = fullfile(filepath,'*.csv');
    d = dir(fil);
    for k=1:numel(d)
        filename = fullfile(filepath,d(k).name);
        % extract data from file(s) and create table(s)
        T = readtable(filename);
        shrate = table2array(T(:,8));
        viscm  = table2array(T(:,9));
        
        % define unknown parameters and make initial guesses
        g = [5, 0.02, 0.7, 0.5]; %initial guesses
        % where: g(1) = eta0; g(2) = lamda; g(3) = a; g(4) = n;
        
        % non-linear constraint function (i.e. Modified Carreau-Yasuda Model)
        % function w/full variable names:
        % visc = @(eta_0,lamda,a,n) eta_0.*((1+(lamda.*shrate).^a).^((n-1)./a));
        % function w/shortened variable names:
        visc = @(g) g(1).*((1+(g(2).*shrate).^g(3)).^((g(4)-1)./g(3)));
        
        % objective function (i.e. function to be minimized)
        objective = @(g) sum(((visc(g)-viscm)./viscm).^2);
       
        % fmincon: Find minimum of constrained nonlinear multivariable function
        % x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
        lb = zeros(size(g)); ub = ones(size(g))*inf;
        options = optimset('Algorithm', 'interior-point', ...
            'MaxFunEval',inf,'MaxIter',Inf);
        gopt = fmincon(objective,g,[],[],[],[],lb,ub,[],options);
        
        % display initial and optimized objective function results 
        disp(['initial objective = ' num2str(objective(g))])
        disp(['optimized objective = ' num2str(objective(gopt))])
        
        % display optimized parameter results
        disp(['optimized parameters: ' num2str(gopt)])
        
        % plot of measured vs optimized/fitted results
        figure
        plot(shrate,viscm,'b.','markers',10)
        set(gca, 'YScale', 'log', 'XScale', 'log');
        hold on
        plot(shrate,visc(gopt),'r-')
        lgnd = legend('measured viscosity', 'fitted viscosity');
        set(lgnd, 'location', 'bestoutside')
        ylabel('shear viscosity (Pa s)'); xlabel('shear rate (1/s)')
        
        % save optimized parameter results
        eta0_fit = [eta0_fit; gopt(1)]; 
        lamda_fit = [lamda_fit; gopt(2)];
        a_fit = [a_fit; gopt(3)]; 
        n_fit = [n_fit; gopt(4)];
    end
    
    % evaluate average optimized parameters
    eta0_avg = mean(eta0_fit);
    lamda_avg = mean(lamda_fit); 
    a_avg = mean(a_fit); 
    n_avg = mean(n_fit);
    
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
    save('eta0_fit.mat', 'eta0_fitData')
    lamda_fitData(row, colmn, m) = lamda_avg;
    save('lamda_fit.mat', 'lamda_fitData')
    a_fitData(row, colmn, m) = a_avg;
    save('a_fit.mat', 'a_fitData')
    n_fitData(row, colmn, m) = n_avg;
    save('n_fit.mat', 'n_fitData')
end