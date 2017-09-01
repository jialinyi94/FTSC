%%  Sensitivity analysis, switches plot and random subject fit plotting
%   change the truth id accordingly when analyzing different simulations
%   -FTSC2

%% loading clustering result
clear;
clc;

%% truth 
TrueID = [ones(50,1); 2*ones(50,1); 3*ones(50,1)];
TrueMembers = ClusteringMembers(3, TrueID);

%% Data I/O
nSim = 1;
NumC = 3;

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\KL\result\';

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
title(strcat('Switches when', {' '},...
        'nsim=', num2str(nSim), ',', {' '},...
        'nc=', num2str(NumC)));
    
%% Spaghetti plot with group average fit
GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(dataset(:));
ymax = max(dataset(:));

figure();
for k=1:nClusters
    
    Y = ClusterData{k};
    [n, T] = size(Y);
    t = (1:T)/T;
    
    % Constructing ssm object
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);    
    [~, logLikSmooth, Output] = smooth(SSM_kalman{k}, Y');
    
    [Smoothed, SmoothedVar] =...
        StatesMeanVar(Output, 'built-in', 'smooth');

    [Smoothed95Upper, Smoothed95Lower] = ...
        NormalCI(Smoothed, SmoothedVar, ConfidenceLevel);
    
    subplot(1,nClusters,k);
    plot(t, Y', 'Color', GrewPoints);
    hold on;
    plot(t, Smoothed(1,:),...
        t, Smoothed95Upper(1,:), '--',...
        t, Smoothed95Lower(1,:), '--');
    hold on;
    plot(t, zeros(1,T),'--');
    hold off;
    ylim([ymin, ymax]);
    plottitle = strcat('Cluster', num2str(k), ' n=', num2str(n));
    title(plottitle);
end

%% Subject-fit plotting
nSubj = 9;

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
    
    RandomSubjFitBuiltIn(nSubj, Y, Members, SSM_kalman{k}, Output_builtin, [ymin, ymax]);
end
