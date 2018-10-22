close all; clear all; clc;

%% Read below before using code:

%  Code is capable of extracting viscosity and shear-rate data from
%  rheometer. In addition, this code can plot the data in a log-log plot,
%  and fit it to the available models described below. The variables
%  resulting from the fit, as well as certain goodness of fit variables,
%  are stored.

%  Carreau-Yasuda model:
%  eta = eta0*[1+(shrate*lamda)^a]^[(n-1)/a]
%  where: eta = viscosity [Pa s]
%         eta0 = zero-shear viscosity [Pa s]
%         shrate = shear-rate [1/s]
%         lamda = natural time [s]
%         a = index that controls transition from Newtonian to power-law
%         n = power-law index

%  Power law model:
%  eta = K*[shrate^(n-1)]
%  K = consistency index [Pa s]

%% Create new data/load previous data
prompt = 'Load previous data? yes/no? ';
answer = input(prompt,'s')

if strcmpi(answer,'yes')
    load eta0.mat
    load eta0error.mat
    load lamda.mat
    load a.mat
    load n.mat
    load nerror.mat
    load sse.mat
    
elseif strcmpi(answer,'no')
    
    eta0 = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    eta0error = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    lamda = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    a = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    n = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    nerror = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    sse = cat(3, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3));
    
end

%% Fitting of model parameters
for N = 1:numel(eta0)
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
    
    % assignment of EGDMA concentration, t1, t2 to matrix
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
    
    % access desired file(s)
    filepath = uigetdir;
    fil = fullfile(filepath,'*.csv');
    d = dir(fil);
    
    % fitting
    ft_CarreauYasuda = fittype('p*((1+(q*x)^r)^((s-1)/r))');
    for k = 1:numel(d)
        filename = fullfile(filepath, d(k).name);
        T = readtable(filename);
        shrate = table2array(T(:, 8));
        viscosity = table2array(T(:, 9));
        figure
        plot(shrate,viscosity,'b.','markers',10)
        set(gca, 'YScale', 'log', 'XScale', 'log');
        % selection of points by user
        % 1st selection = eta0 guess, 2nd selection = lamda guess
        [x,y] = ginput(2);
        
        % starting points:
        [f1,gof] = fit(shrate, viscosity, ft_CarreauYasuda, ...
            'StartPoint', [y(1), 1/x(2), 0.5, 0.5], ...
            'Lower', [0, 0.001, 0, 0], ...
            'Upper', [Inf, 100, Inf, 1]);
        c = coeffvalues(f1);
        
        % where startincg points are listed in the order: eta0, lamda, a, n
        hold on
        y_fit = c(1)*((1+(c(2)*shrate).^c(3)).^((c(4)-1)/c(3)));
        loglog(shrate,y_fit);
        
        % If SSE > user-defined value (e.g. 1), power law will be used
        gof = cell2mat(struct2cell(gof))';
        sse_val = gof(1);
        if sse_val >= 2
            ft_Powerlaw = fittype('t*(x^(v-1))');
            for i = 1:3
                dcmObject = datacursormode;
                pause
                datacursormode off
                cursor = getCursorInfo(dcmObject);
                pt{i} = cursor.Position;
            end
            start_pt = find(shrate == pt{2}(1));
            end_pt = find(shrate == pt{3}(1));
            [f2,gof] = fit(shrate(start_pt:end_pt), viscosity(start_pt:end_pt), ft_Powerlaw, ...
                'Startpoint', [pt{1}(2), 0.5], ...
                'Lower', [0, 0], ...
                'Upper', [Inf, 1]);
            % where starting points are listed as: K, n
            c2 = coeffvalues(f2);
            hold on
            y_fit = c2(1)*(shrate.^(c2(2)-1));
            loglog(shrate,y_fit)
            
            eta0_fit = [eta0_fit; pt{1}(2)]
            lamda_fit = [lamda_fit; 0];
            a_fit = [a_fit; 0];
            n_fit = [n_fit; c2(2)]
            gof = cell2mat(struct2cell(gof));
            sse_fit = [sse_fit; gof(1)]
        else
            
            eta0_fit = [eta0_fit; c(1)]
            lamda_fit = [lamda_fit; c(2)];
            a_fit= [a_fit; c(3)];
            n_fit = [n_fit; c(4)]
            sse_fit = [sse_fit; gof(1)]
            
        end
    end
    
    lamda_fit(lamda_fit == 0) = NaN;
    a_fit(a_fit == 0) = NaN;
    eta0_avg = mean(eta0_fit);
    eta0_std = std(eta0_fit);
    lamda_avg = mean(lamda_fit, 'omitnan');
    a_avg = mean(a_fit, 'omitnan');
    n_avg = mean(n_fit);
    n_std = std(n_fit);
    sse_avg = mean(sse_fit);
    
    eta0(row, colmn, m) = eta0_avg;
    eta0error(row, colmn, m) = eta0_std;
    lamda(row, colmn, m) = lamda_avg;
    a(row, colmn, m) =  a_avg;
    n(row, colmn, m) = n_avg;
    nerror(row, colmn, m) = n_std;
    sse(row, colmn, m) = sse_avg;
    
    save('eta0.mat', 'eta0')
    save('eta0error.mat', 'eta0error')
    save('lamda.mat', 'lamda')
    save('a.mat', 'a')
    save('n.mat', 'n')
    save('nerror.mat', 'nerror')
    save('sse.mat', 'sse')
    
    prompt = 'Continue fitting (yes/no)?';
    answer = input(prompt, 's');
    
    if strcmpi(answer, 'yes')
        continue
    elseif strcmpi(answer, 'no')
        break
    end
end



