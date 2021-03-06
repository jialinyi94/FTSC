%%  Demo for simulation with sin-cos fixed effects
%   change the truth id accordingly when analyzing different simulations
%   -FTSC

%% loading clustering result
clear;
clc;

%% truth 
TrueID = [ones(50,1); 2*ones(50,1); 3*ones(50,1)];
TrueMembers = ClusteringMembers(3, TrueID);

%% Data I/O
nSim = 1;
NumC = 3;

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\Model Selection\result\';

load(strcat(path_result, 'simu_result_', num2str(nSim),'_', num2str(NumC),'C.mat'));

%% clustering running time
id = sum(clustertime(nSim,:) ~= 0);
fprintf('The clustering algorithm running time is %.2f minutes.\n', clustertime(nSim,id)/60)

%% preallocation
% get data in each cluster
ClusterData = ClusteringData(dataset, ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level

%% sensitivity analysis

% wald's minimum variance
WaldMembers = ClusteringMembers(nClusters, WaldClusterID);
fprintf('kmeans clustering: \n')
SensTable(TrueMembers, WaldMembers)

% state-space model clustering
fprintf('State-space model clustering: \n')
SensTable(TrueMembers, ClusterMembers)

%% Switches plot
plot(SwitchHistory);
title(strcat('Swaps in each iteration', {' '},...
        'nSim=', num2str(nSim), ',', {' '},...
        'nClusters=', num2str(nClusters)));
    
%% Raw data
plot(dataset')
title('Simlulation: 150 samples in 3 groups')
    
%% Spaghetti plot with group average fit
SpaghettiPlot(dataset, nSim, nClusters, ClusterMembers, logparahat);

%% Subject-fit plotting
nSubj = min([9, min(cellfun('length', ClusterMembers))]);

% get scale for dataset
ymin = min(min(dataset));
ymax = max(max(dataset));

for k=1:nClusters
    
    Y = ClusterData{k};
    Members = ClusterMembers{k};
    [n, ~] = size(Y);
    
    % Constructing SSM structures for one cluster
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);    
    [~, logLikSmooth, Output_builtin] = smooth(SSM_kalman{k}, Y');
    
    f = figure;
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = strcat('Random selected subjects in Cluster',num2str(k)); 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';

    RandomSubjFitBuiltIn(nSubj, Y, Members, SSM_kalman{k}, Output_builtin, [ymin, ymax], p);
end
