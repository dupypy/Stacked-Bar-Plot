close all; clear all; clc;
%% Model used in this code: Carreau-Yasuda model
%% Create new data/load previous data
prompt = 'Load previous data? Yes/No? '; %if answer = no, enter 'no!' for code to work
answer = input(prompt,'s');
if answer == 'Yes'
    load predictedinf.mat
    load predictedviscosity.mat
    load predictedlamda.mat
    load predicteda.mat
    load predictedn.mat
elseif answer == 'No!'
    %creation of files for: eta_inf
    inft2_0  = zeros(3,3); inft2_10 = zeros(3,3); inft2_15 = zeros(3,3); inft2_20 = zeros(3,3);
    predictedinfData = cat(3, inft2_0, inft2_10, inft2_15, inft2_20);
    %creation of files for: eta_0 
    visct2_0  = zeros(3,3); visct2_10 = zeros(3,3); visct2_15 = zeros(3,3); visct2_20 = zeros(3,3);
    predictedviscosityData = cat(3, visct2_0, visct2_10, visct2_15, visct2_20);
    %creation of files for: lamda
    lamt2_0  = zeros(3,3); lamt2_10 = zeros(3,3); lamt2_15 = zeros(3,3); lamt2_20 = zeros(3,3);
    predictedlamdaData = cat(3, lamt2_0, lamt2_10, lamt2_15, lamt2_20);
    %creation of files for: a
    at2_0  = zeros(3,3); at2_10 = zeros(3,3); at2_15 = zeros(3,3); at2_20 = zeros(3,3);
    predictedaData = cat(3, at2_0, at2_10, at2_15, at2_20);
    %creation of files for: n
    nt2_0  = zeros(3,3); nt2_10 = zeros(3,3); nt2_15 = zeros(3,3); nt2_20 = zeros(3,3);
    predictednData = cat(3, nt2_0, nt2_10, nt2_15, nt2_20);
end
%% Carreau-Yasuda model optimization
for N = 1:numel(predictedviscosityData)
    %% Solution condition entry
    prompt = 'EGDMA Concentration = ';
    Conc = input(prompt)
    prompt = 't1 = ';
    t1 = input(prompt)
    prompt = 't2 = ';
    t2 = input(prompt)
    
    eta_infp = []; eta_0p = []; lamdap = []; ap = []; np = [];
    %% Access desired file(s)
    filepath = uigetdir('D:\3D Printing Project\Rheology Data\Selected Rheology Data for Project (as of 07-26)');
    fil = fullfile(filepath,'*.csv');
    d = dir(fil);
    for k=1:numel(d)
        filename = fullfile(filepath,d(k).name);
        %% Extract data from file(s) and create table(s)
        T = readtable(filename);
        shrate = table2array(T(:,8)); %shear rate
        viscm  = table2array(T(:,9)); %measured viscosity
        %% Define unknown parameters and make initial guesses
        g = [0, 0.5, 0.5, 0.5, 0.5]; %initial guesses
        eta_infi = g(1); eta_0i = g(2); lamdai = g(3); ai = g(4); ni = g(5);
        %% Non-linear constraint function (i.e. Carreau-Yasuda Model)
        %function w/full variable names:
        %visc = @(eta_inf,eta_0,lamda,a,n) eta_inf+(eta_0-eta_inf).*((1+(lamda.*shrate).^a).^((n-1)./a));
        %function w/shortened variable names:
        visc = @(g) g(1)+(g(2)-g(1)).*((1+(g(3).*shrate).^g(4)).^((g(5)-1)./g(4)));
        %% Objective function (i.e. function to be minimized)
        objective = @(g) sum(((visc(g)-viscm)./viscm).^2);
        %% fmincon: Find minimum of constrained nonlinear multivariable function
        %x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
        lb = zeros(size(g)); ub = ones(size(g))*inf;
        %Usable fmincon algorithms: 'interior-point' & 'sqp'
        options = optimset('Algorithm', 'interior-point', 'MaxFunEval',inf,'MaxIter',Inf);
        gopt = fmincon(objective,g,[],[],[],[],lb,ub,[],options);
        
        disp(['initial objective = ' num2str(objective(g))])
        disp(['optimized objective = ' num2str(objective(gopt))])
        disp(['optimized parameters: ' num2str(gopt)])
        
        figure
        plot(shrate,viscm,'b.','markers',10)
        set(gca, 'YScale', 'log', 'XScale', 'log');
        hold on
        plot(shrate,visc(gopt),'r-')
        lgnd = legend('measured viscosity', 'predicted viscosity (w/optimized vals)');
        set(lgnd, 'location', 'bestoutside')
        ylabel('shear rate (1/s)'); xlabel('viscosity (Pa s)')
        
        eta_infp = [eta_infp; gopt(1)]; eta_0p = [eta_0p; gopt(2)]; 
        lamdap = [lamdap; gopt(3)]; ap = [ap; gopt(4)]; np = [np; gopt(5)];
    end
    eta_infavg = mean(eta_infp); eta_0avg = mean(eta_0p);
    lamdaavg = mean(lamdap); aavg = mean(ap); navg = mean(np);
    %% Assign predicted values to matrix
    %Assignment variable: t2
    if t2 == 0
        m = 1;
    elseif t2 == 10
        m = 2;
    elseif t2 == 15
        m = 3;
    else t2 == 20
        m = 4;
    end
    %Assignment variable: EGDMA Concentration
    if Conc == 1
        colmn = 1;
    elseif Conc == 2
        colmn = 2;
    else Conc == 3
        colmn = 3;
    end
    %Assignment variable: t1
    if t1 == 100
        row = 1;
    elseif t1 == 110
        row = 2;
    else t1 == 120
        row = 3;
    end
    
    predictedviscosityData(row, colmn, m) = eta_0avg;
    save('predictedviscosity.mat', 'predictedviscosityData')
    predictedinfData(row, colmn, m) = eta_infavg;
    save('predictedinf.mat', 'predictedinfData')
    predictedlamdaData(row, colmn, m) = lamdaavg;
    save('predictedlamda.mat', 'predictedlamdaData')
    predictedaData(row, colmn, m) = aavg;
    save('predicteda.mat', 'predictedaData')
    predictednData(row, colmn, m) = navg;
    save('predictedn.mat', 'predictednData')
end