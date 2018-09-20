close all; clear all; clc;

%% Read FTIR Data Script

% generates hue-saturation-value color map for plot
colormap = lines(5);

% acess desired file
filepath = uigetdir;
fil = fullfile(filepath,'*.csv');
d = dir(fil);

% read FTIR data
for k=1:numel(d)
        filename = fullfile(filepath,d(k).name)
        FTIR_Data = xlsread(filename,'A6:B1874');
        
        wavenumber = FTIR_Data(:,1);
        transmittance = FTIR_Data(:,2);
        
        [filepath, name, ext] = fileparts(filename);
        
        plot(wavenumber, transmittance, 'displayname', name, ...
            'color', colormap(k,:))
        hold on
        xlabel('wavenumbers [1/cm]'); ylabel('% transmittance');
        xlim([400, 4000]); ylim([0, 100]);
        xticks(400:200:4000);
        set(gca, 'xdir', 'reverse')
        legend('-dynamiclegend', 'location', 'northeastoutside');
        grid on
        end