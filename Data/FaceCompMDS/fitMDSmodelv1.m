clear all
clc
close all

%% Set Model Parameters
whichModel = 'constrained'; % 'full' or 'constrained' 'superConstrained'
distanceMetric = 'euclidean'; % 'cityblock' or 'euclidean' minkowski
nParallelCores = 8;

if strcmp(whichModel, 'full')
    model = @mdsModel0;
elseif strcmp(whichModel, 'constrained')
    model = @mdsModel;
elseif strcmp(whichModel, 'superConstrained')
    model = @mdsModelSC;
end

%% Extract Data From Folder
% Find the files
data_folder     = {'Data'};
temp_dir        = dir(fullfile(pwd,data_folder{1}));

for i = 3:size(temp_dir,1);
    file_list{i-2} = temp_dir(i).name;
end % for i

% Collect the data
data = [];

for i = 1:size(file_list,2);
    temp_var = dlmread(fullfile(pwd,data_folder{1},file_list{i}));
    temp_var = temp_var(:,1:5);
    data = [data; temp_var];
end % for i...
% data = data(506:end,:);

subs    = unique(data(:,1));

% subs = 401;
nsubs   = numel(subs);
rawMDS      = cell(nsubs,1);
rotMDS      = cell(nsubs,1);
bestparms   = cell(nsubs,1);
bestfit     = nan(nsubs,1);
BIC         = nan(nsubs,1);
R2          = nan(nsubs,1);

targetCoordinates = [];
targetCoordinates(:,:,1) = [3 3; 3 1.67; 1.67 3; 1.67 1.67; 3 1; 1.67 1; 1 3; 1 1.67; 1 1];
targetCoordinates(:,:,2) = [3 3; 3 1.67; 1.67 3; 1.67 1.67; 3 1; 1.67 1; 1 3; 1 1.67; 1 1];
targetCoordinates(:,:,3) = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];
targetCoordinates(:,:,4) = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];

for sidx = 1:nsubs
    keep model condition sidx whichModel nParallelCores ...
         data targetCoordinates distanceMetric rawMDS ... 
         rotMDS BIC bestparms bestfit R2 subs;
    
    pdata       = data(data(:,1) == subs(sidx),:);    
    condition   = mean(pdata(:,2));
    
    ratings     = aggregate([sort(pdata(:, 3:4), 2), pdata(:,5)], 1:2, 3);
    simRatings  = squareform(8 - ratings(:,3));
    
    %% Parameters
    ideal = targetCoordinates(:,:,condition);
    
    switch whichModel
        case 'full'
            % Full model
            parms = ideal(:);
            m = -1;
            b = 8;
            parms = [m; b; parms];
        case 'constrained'
            % Constrained model
            parms = [1 2 1 2]';
            m = -1;
            b = 8;
            parms = [m; b; parms];
        case 'superConstrained'
            m = -1;
            b = 8;
            parms = [1 1]';
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
    [m, midx] = min(fit);
    bestparms{sidx} = fittedparms(:,midx);
    bestfit(sidx) = fit(midx);
    [fitcheck, coordinates, R2(sidx)] = model(bestparms{sidx}, simRatings, [], distanceMetric);    
    xy = reshape(coordinates, 9, 2);
    BIC(sidx) = computeBICfromR2(R2(sidx), size(ratings,1), size(parms,1));
    fprintf('SSD = %3.2f, R^2 = %3.2f\n, BIC = %3.2f\n', bestfit(sidx), R2(sidx),BIC(sidx))
    
    [D, rotxy, T] = procrustes(ideal, xy);
    
    %% Display Figure
    figure('WindowStyle','Docked','Color',[1 1 1]);
    subplot(1,2,1)
    plot(xy(:,1), xy(:,2), ' ok')
    text(xy(:,1), xy(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);
    %     set(gca, 'XLim', [0 4], 'YLim', [0 4])
    title('Fitted Solution', 'Fontsize', 15);
    axis square
    
    subplot(1,2,2)
    plot(rotxy(:,1), rotxy(:,2), ' ok')
    text(rotxy(:,1), rotxy(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);
    set(gca, 'XLim', [0 4], 'YLim', [0 4])
    title('Procrustes Rotation', 'Fontsize', 15);
    axis square
    
    temp = ['Participant: ' num2str(subs(sidx))];
    supertitle(temp)
        
    rawMDS{sidx} = xy;
    rotMDS{sidx} = rotxy;  
    
end

Ps = aggregate(aggregate(data,1,2),2,1,@count);
disp('Done')
