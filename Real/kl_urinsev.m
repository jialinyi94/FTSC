%% Urin Severity: Optimal number of clusters
%  plot the Kullback-Leibler information distance curve
%  For different dataset, change filename
clear;
clc;

%% Simulation setting
nSim = 1;
nCL = 1;
nCU = 10;
d = nCU - nCL + 1;
diffusePrior = 1e7;

KLCell = {@KLCondP, @KL01, @KLUnif};

%% Plotting
f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = 'KL divergence for URINSEV';
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';


for i=1:3
    
    KL = KLCell{i};
    % preallocation
    KLD = zeros(1,d);

    %  Computing the Kullback-Leibler distance for different clustering
    for NumC = nCL:nCU

        path_result = 'Y:\Users\Jialin Yi\output\URINSEV\Model Selection\';

        load(strcat(path_result, 'URINSEV_dif_FC_', num2str(NumC),'C.mat'));

        q = NumC - nCL + 1;

        KLD(q) = KL(logP);
    end

    % KL distance curve and optimal number of clusters
    subplot(1,3,i,'Parent',p)
    plot(KLD);
    [KL_opti, nclusters_opti] = min(KLD);
    text = strcat(func2str(KL),' : The optimal number of clusters is', {' '}, num2str(nclusters_opti));
    title(text);
    ylim([30,40]);
end
