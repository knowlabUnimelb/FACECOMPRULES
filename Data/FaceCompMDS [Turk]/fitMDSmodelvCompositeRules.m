clear all
clc
close all

whichModel      = 'full'; % 'full' or 'constrained'
distanceMetric  = 'minkowski'; % 'cityblock' or 'euclidean' or 'minkowski'
nParallelCores  = 0;


if strcmp(whichModel, 'full')
    model = @mdsModel0;
else
    model = @mdsModel;
end

condition = 1:4;

totalSpace = nan(9,2,4);
totalSpace(:,:,1) = [3 3; 3 1.67; 1.67 3; 1.67 1.67; 3 1; 1.67 1; 1 3; 1 1.67; 1 1];
totalSpace(:,:,2) = [3 3; 3 1.67; 1.67 3; 1.67 1.67; 3 1; 1.67 1; 1 3; 1 1.67; 1 1];
totalSpace(:,:,3) = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];
totalSpace(:,:,4) = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];

bestparms   = cell(4,1);
bestfit     = cell(4,1);
xy          = cell(4,1);
rotxy       = cell(4,1);
R2          = cell(4,1);
cdata       = cell(4,1);
BIC         = cell(4,1);

for sidx = 1:numel(condition)
    keep model condition sidx whichModel nParallelCores distanceMetric totalSpace bestparms bestfit xy rotxy R2 cdata BIC
    
    datafile = ('CompositeRules_5_8_2block.dat');
    dataloc = fullfile(pwd, 'rawdata');
    
    data = dlmread(fullfile(dataloc, datafile));
    
    % Take the relevant participant
    data = data(data(:,2) == sidx,:);

    % Remove button pushers!
    posterior = computeButtonPushingProbabilities(data, .3);
    subs = unique(data(:,1));
    buttonPushers = subs(posterior < .5);
    %     buttonPushers = [3];
    data(ismember(data(:,1), buttonPushers), :) = [];
    
    cdata{sidx} = data;
    disp(numel(unique(data(:,1))))
    
    % Trim data
    data = data(:,[1 2 5 6 7]);
    ratings = aggregate([sort(data(:, 3:4), 2), data(:,5)], 1:2, 3);
    simRatings = squareform(8 - ratings(:,3));
    
    ideal = totalSpace(:,:,sidx);
    
    %% Parameters
    
    switch whichModel
        case 'full'
            % Full model
            temp = ideal(1:8,:);
            parms = temp(:);
            m = -1;
            b = 8;
            parms = [m; b; parms];
        case 'constrained'
            % Constrained model
            parms = [1 2 1 2]';
            m = -1;
            b = 8;
            parms = [m; b; parms];
    end
    
    startparms = repmat(parms, 1, 100) + randn(numel(parms), 100) * .1;
    
    %% Optimization
    defopts = optimset ('fminsearch');
    options = optimset (defopts, 'Display', 'off', 'MaxFunEvals', 1e6, 'MaxIter', 1e6);
    tic;
    if nParallelCores > 0
        matlabpool('local', nParallelCores)
        parfor i = 1:size(startparms, 2)
            [fittedparms(:,i), fit(i), exit_flag(i)] =...
                fminsearch(@(parms) model(parms, simRatings, [], distanceMetric), startparms(:,i), options);
        end
        matlabpool close
    else
        options = optimset (defopts, 'Display', 'iter', 'MaxFunEvals', 1e6, 'MaxIter', 1e6);
        for i = 1:size(startparms, 2)
            [fittedparms(:,i), fit(i), exit_flag(i)] =...
                fminsearch(@(parms) model(parms, simRatings, [], distanceMetric), startparms(:,i), options);
        end
    end
    displayTime(toc);
    
    %% Check output
    [m, midx]       = min(fit);
    bestparms{sidx} = fittedparms(:,midx);
    bestfit{sidx}   = fit(midx);
    [fitcheck, coordinates, R2{sidx}] = model(bestparms{sidx}, simRatings, [], distanceMetric);
    BIC{sidx} = computeBICfromR2(R2{sidx}, size(ratings,1), size(parms,1));
    fprintf('SSD = %3.2f, R^2 = %3.2f\n, BIC = %3.2f\n', bestfit{sidx}, R2{sidx}, BIC{sidx})
    
    xy{sidx} = reshape(coordinates, 9, 2);
    [D, rotxy{sidx}, T] = procrustes(ideal, xy{sidx});
    
    %% Display Figure
    figure('WindowStyle','Docked','Color',[1 1 1]);
    subplot(1,2,1)
    plot(xy{sidx}(:,1), xy{sidx}(:,2), ' ok')
    text(xy{sidx}(:,1), xy{sidx}(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);    
    title('Fitted Solution', 'Fontsize', 15);
    axis square
    
    subplot(1,2,2)
    plot(rotxy{sidx}(:,1), rotxy{sidx}(:,2), ' ok')
    text(rotxy{sidx}(:,1), rotxy{sidx}(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);
    set(gca, 'XLim', [0 4], 'YLim', [0 4])
    title('Procrustes Rotation', 'Fontsize', 15);
    axis square
end

