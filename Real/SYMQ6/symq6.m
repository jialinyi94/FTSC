%% SYMQ6 data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

%% Data I/O

path_data = 'Y:\Users\Jialin Yi\data\SYMQ6\';

path_result = 'Y:\Users\Jialin Yi\output\SYMQ6\Model Selection\';

%% Clustering setting
nCLower = 1;
nCUpper = 10;
dif = nCUpper - nCLower + 1;

%% Clustering setting
MAX_LOOP = 20;
logpara0 = [0.5;6;6;-5;0];

%% 

    
for nClusters = nCLower:nCUpper

    % load data
    load(strcat(path_data, 'SYMQ6_dif_',num2str(nClusters),'C.mat'));
    dataset = symq6_dif;
    IniClusterIDs = WaldClusterID;

    % get time points
    [~, m] = size(dataset);
    t = (1:m)/m;

    % clustering starts
    tic;
    [ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
        SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);
    clustertime = toc;

    % convergence of algorithm
    subplot(2, 5, nClusters);
    plot(SwitchHistory)
    title(strcat('Switches when', {' '},...
                'SYMQ6', {', '}, ...
                'nClusters=', num2str(nClusters)));

    % save result
    save(strcat(path_result, 'SYMQ6_dif_FC_',num2str(nClusters),'C.mat'));

    ProgressInfo = ['SYMQ6 ', ...
        ': nClusters = ', num2str(nClusters), ' is finised.'];
    display(ProgressInfo);
    
end


