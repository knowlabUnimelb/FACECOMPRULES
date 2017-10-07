% Set up
clear all
clc
% close all force hidden

dataPrefix   = '2014_comprules'; % String at the beginning of data file
datalocation = fullfile(pwd, 'rawdata'); % Location folder of datafiles
Rdataloc     = fullfile(pwd, 'Rdata');   % Location of summary files for Houpt SFT [R] analysis
modelingDataloc = fullfile(pwd, 'modeldata');
dataformat   = '%s_s%03d_con%d_ses%d.dat'; % Format for datafile name; first string is dataPrefix

dimensions = {'Top', 'Bottom'}; % Specify descriptive names for your dimensions

si = 19; % which subject to analyse? [Must correspond to the entry in subjectNumber variable]

% 103 and 208 omitted for high error rates
subjectNumbers   = [101, 103, 105, 107, 109,...
                    202, 204, 206, 208, 210,...
                    301, 302, 303, 304, 306,...
                    401, 402, 403, 404,...
                    262]; % Subject number to analyse
conditionNumbers = [1, 1, 1, 1, 1,...
                    2, 2, 2, 2, 2,...
                    3, 3, 3, 3, 3,...
                    4, 4, 4, 4,...
                    5];
sessions = {[2:3, 5:7, 9:10], 2:8, 2:8, 2:8, 2:8,...
            2:8, 2:8, 2:8, 2:5, 3:8,...
            2:8, 2:8, 2:8, 2:8, 2:8,...
            2:8, [2,4:9], 3:9, 2:8,...
            2:3}; % You can set this to more than one session by stating: 2:5
subjectCodes = {'UA1', 'omit', 'UA2', 'UA3', 'UA4', 'UM1', 'UM2', 'UM3', 'omit', 'UM4', 'IA1', 'IA2', 'IA3', 'IA4', 'IA5', 'IM1', 'IM2', 'IM3', 'IM4', 'pilot'};

ploton = true; % Set to true to display plots
runStats = false;
anovaTable = 'off';

minrt = 200; % Minimum RT cutoff 200ms 

% Data file column names (some columns are necessary: 'sub', 'itm', 'rt'
cols = {'sub', 'con', 'rot', 'ses', 'tri', 'itm', 'top', 'bot', 'rsp', 'cat', 'acc', 'rt'};

%%
% Select from lists
subjectNumber = subjectNumbers(si); 
conNumber     = conditionNumbers(si);
session       = sessions{si};

%%
% Read data
data = [];
for i = 1:numel(session)
    data = [data; dlmread(fullfile(datalocation, sprintf(dataformat, dataPrefix, subjectNumber, conNumber, session(i))))];
end

% Set up block column
nPracTrials = 9;           % Number of practice trials
nTrialsPerSession = 459;   % Number of trials per session
nTrialsPerBlock = [45+9, 45, 45, 45, 45, 45, 45, 45, 45, 45]; % Number of trials in each block

nSessions = numel(session); % Number of sessions
nTrialsPerBlock = repmat(nTrialsPerBlock, 1, nSessions); % Duplicate number of trials per block across sessions
blocks = 1:((size(data, 1)/nSessions - nPracTrials)/45); % Number the blocks
blocks = repmat(blocks, 1, nSessions);                   % Replicate blocks across sessions

% Add in block column to data file
sessionblocks = [];
for i = 1:numel(blocks);
    sessionblocks = [sessionblocks; ones(nTrialsPerBlock(i), 1) * blocks(i)];
end
rdata   = [data(:,1:4), sessionblocks,  data(:, 5:end)];
cols = [cols(1:4), 'blk', cols(5:end)]; % Add to col names

%% Remove overall long RTs
cutoffPercentiles = repmat([99.9], 1, numel(subjectNumbers)); % Throw out anything greater than this prctile (if 100 then don't throw out anything)
% This is useful for getting rid of extremely long RTs if the P, for instance, took a phonecall or fell asleep

idxTooLong = find(rdata(:,end) > prctile(rdata(:,strcmp(cols, 'rt')), cutoffPercentiles(si)));
rdata(idxTooLong, :) = []; % Delete long RTs
fprintf('Number of long RT trials removed = %d\n', numel(idxTooLong))
condition = rdata(1, strcmp('con', cols));

%% Remove timeouts
idx9 = find(rdata(:,strcmp('acc', cols)) == 9); % Remove timeouts
rdata(idx9,:) = []; % Delete timeouts
fprintf('Number of timeouts removed = %d\n', numel(idx9))

rdata(isnan(rdata(:,strcmp('rt', cols))), :) = []; % Delete nans

%% Convert RTs to msecs if not already in secs
if max(rdata(:,end)) < 1000 
    rdata(:,end) = rdata(:,end) * 1000;
end

%% Process data file

% Throw out practice trials
sessions = unique(rdata(:, strcmp('ses', cols)));
cbd = [];
for i = 1:numel(sessions)
    ddata = rdata(rdata(:,strcmp('ses', cols)) == sessions(i),:);
    if any(ismember(blocks, 1)) % If this block has practice trials, then throw them out
        currentBlockData = ddata(ismember(ddata(:,strcmp('blk', cols)), blocks),:);
        cbd = [cbd; currentBlockData(nPracTrials+1:end,:)];
    else % No practice
        currentBlockData = ddata(ismember(ddata(:,strcmp('blk', cols)), blocks),:);
        cbd = [cbd; currentBlockData];
    end
end
data = cbd;

% Compute accuracy by blocks
if nSessions == 1
    disp('Accuracy by blocks')
    aggregate(cbd(cbd(:,strcmp('ses', cols)) == session, :), find(strcmp('blk', cols)), find(strcmp('acc', cols)))
    disp('Accuracy this session')
    aggregate(cbd(cbd(:,strcmp('ses', cols)) == sessions,:), find(strcmp('ses', cols)), find(strcmp('acc', cols)))
end


%% Compute averages, remove outliers
x = data; % Sort the data by session and by trial
means = aggregate(x, strcmp('itm', cols), strcmp('rt', cols));        % Compute the means for each item
stds  = aggregate(x, strcmp('itm', cols), strcmp('rt', cols), @std);  % Compute the stds for each item

trialnumber =  (1:size(data,1))'; 
fintrialnumber =[];
trialdata = []; 
cedata = [];
for item = 1:9
    correctAndErrorData = data(data(:,strcmp('itm', cols)) == item,:); % Get data for items.
    itemdata = data(data(:,strcmp('itm', cols)) == item,:);
    trial    = trialnumber(data(:,strcmp('itm', cols)) == item,1);
    
    % Remove errors
    errors{item} = find(itemdata(:,strcmp('acc', cols)) == 0);
    nerrors(item,1) = numel(errors{item});
    itemdata(errors{item},:) = [];
    trial(errors{item},:) = [];
    
    % Remove outlying RTs < minrt (for errors and correct) or > 3 stds + mean (for correct only)
    % 14 Sep 2017 - The line below has a bug which means that we never
    %   removed any RTs > 3 stds above the mean 
    outliers{item} = find(any([itemdata(:,strcmp('rt', cols)) < minrt, itemdata(:,strcmp('acc', cols)) == 0 & itemdata(:,strcmp('rt', cols)) > means(item,2) + stds(item,2) * 3], 2));
    noutliers(item,1) = numel(outliers{item});
    itemdata(outliers{item}, :) = [];
    trial(outliers{item}, :) = [];
    correctAndErrorData(outliers{item}, :) = [];
    
    ncorrect(item,1) = size(itemdata,1);
    itemdata(:,strcmp('rt', cols)) = itemdata(:,strcmp('rt', cols));
    mrt(item,1) = mean(itemdata(:,strcmp('rt', cols)));
    
    trialdata = [trialdata; itemdata];
    fintrialnumber = [fintrialnumber; trial];
    cedata = [cedata; correctAndErrorData];
    output(item,:) = [prctile(itemdata(:,strcmp('rt', cols)), [10 30 50 70 90]), ncorrect(item,1), noutliers(item,1), nerrors(item,1), mrt(item,1)];
end
save(fullfile(modelingDataloc, sprintf('s%d_cedata.mat', subjectNumber)), 'cedata') % Save matfile for model fitting

cleandata = sortrows(trialdata, [find(strcmp('ses', cols)), find(strcmp('blk', cols)), find(strcmp('tri', cols))]);
trialdata(:,strcmp(cols, 'rot') | strcmp(cols, 'blk')) = [];
% save(sprintf('s%d_trialdata.mat', subjectNumber), 'trialdata') % Save trial data?
dlmwrite(fullfile(Rdataloc, sprintf('R_analysis_%s_%d.dat', dataPrefix, subjectNumbers(si))), cedata(:,mstrfind(cols, {'sub', 'con', 'rt', 'acc', 'itm'})), 'delimiter', '\t')

%% Collate data for ANOVA
cols = {'sub', 'con',   'ses', 'tri', 'itm', 'top', 'bot', 'rsp', 'cat', 'acc', 'rt'}; %% Copied from top of script

anovadata = trialdata(:, [find(strcmp('sub', cols)), find(strcmp('ses', cols)), find(strcmp('itm', cols)), find(strcmp('rt', cols))]);
anovadata(:, 5) = double(ismember(anovadata(:,3), [1 2 3 4]));
anovadata(ismember(anovadata(:,3), [1 2]), 5) = anovadata(ismember(anovadata(:,3), [1 2]), 5) + 1;
anovadata(:, 6) = double(ismember(anovadata(:,3), [1 2 3 4]));
anovadata(ismember(anovadata(:,3), [1 3]), 6) = anovadata(ismember(anovadata(:,3), [1 3]), 6) + 1;

x = anovadata(ismember(anovadata(:,3), 1:4), [3 5 6 4]);
targ = aggregate(x, [2 3], 4, [],1); 
mic = targ(1) - targ(2) - targ(3) + targ(4);
targstd = aggregate(x, [2 3], 4, @std,1); targcnt = aggregate(x, [2 3], 4, @count,1);
targerr = targstd./sqrt(targcnt);


%% Run ANOVA
if runStats
%     [p, t, stats, terms] = anovan(x(:,4), {x(:,2), x(:,3)}, 'varnames', dimensions, 'model', 'full', 'display', anovaTable);
    
    % Run sessions anova
    sessionX = anovadata(ismember(anovadata(:,3), 1:4), [2 3 5 6 4]);
    [anovap, t, stats, terms] = anovan(sessionX(:,5), {sessionX(:,1), sessionX(:,3), sessionX(:,4)},...
        'varnames', {'Session', dimensions{1}, dimensions{2}}, 'model', 'full', 'display', anovaTable);
    
    itemComparisons = [5 6; 7 8; 5 9; 6 9; 7 9; 8 9];
    labels = {'', '', '', '',...
        sprintf('E_{%s}', dimensions{1}),...
        sprintf('I_{%s}', dimensions{1}),...
        sprintf('E_{%s}', dimensions{2}),...
        sprintf('I_{%s}', dimensions{2}),...
        'R'};
    for icIdx = 1:size(itemComparisons, 1)
        item1 = anovadata(ismember(anovadata(:,3), itemComparisons(icIdx,1)), 4);
        item2 = anovadata(ismember(anovadata(:,3), itemComparisons(icIdx,2)), 4);
        [h, ttestp, ci, stats]= ttest2(item1, item2);
%         if strcmp(anovaTable, 'on')
            fprintf('Contrast category comparison: %10s vs %10s: Mean Diff = %3.2f, t(%d) = %6.2f, p = %3.3f\n',...
                labels{itemComparisons(icIdx, 1)}, labels{itemComparisons(icIdx, 2)},...
                mean(item1)-mean(item2), stats.df, stats.tstat, ttestp);
%         end
    end
end

cols = {'sub', 'con', 'rot', 'ses', 'blk', 'tri', 'itm', 'sat', 'barpos', 'rsp', 'cat', 'acc', 'rt'}; % copied from line 60

%% Run SIC & CCF Analysis
data = cleandata;
data(~ismember(data(:,strcmp('itm', cols)), [1 2 3 4 5 6 7 8 9]), :) = [];

%% Estimate CDF for all items
mint = min([min(cedata(:,strcmp('rt', cols))), 5]);
maxt = max([max(cedata(:,strcmp('rt', cols)))]) + 300;
t = mint:10:maxt; % #### set t, time vector in msec (MIN : bin size : MAX)

items = unique(cedata(:,strcmp('itm', cols)));
[S, d, acc, tsic] = computeSurvivors(cedata(:,mstrfind(cols, {'itm', 'acc', 'rt'})), 'kaplan', []);

%  7  | 3    1
%     |
%  8  | 4    2
%     |--------
%  9    6    5


%% Get MICS
targ = [mean(d{4}) mean(d{2}) mean(d{3}) mean(d{1})]';
cont = [mean(d{5}) mean(d{6}) mean(d{7}) mean(d{8}) mean(d{9})]';
targerr = [std(d{4})/sqrt(length(d{4})) std(d{2})/sqrt(length(d{2})) std(d{3})/sqrt(length(d{3})) std(d{1})/sqrt(length(d{1}))]';
conterr = [std(d{5})/sqrt(length(d{5})) std(d{6})/sqrt(length(d{6})) std(d{7})/sqrt(length(d{7})) std(d{8})/sqrt(length(d{8})) std(d{9})/sqrt(length(d{9}))]';

%% Target SICs
% Target SIC item codes: LL = 4, LH = 2, HL = 3, HH = 1;
HH = d{1}; HL = d{2}; LH = d{3}; LL = d{4};
HHacc = acc{1}; HLacc = acc{2}; LHacc = acc{3}; LLacc = acc{4};
[sic, tcdf, tsf, tsic, sichi, siclo] = computeSIC(LL, LH, HL, HH, LLacc, LHacc, HLacc, HHacc, mint, maxt);
means = nansum(tsf);
MIC = means(1) - means(2) - means(3) + means(4);

% [Rdiff, Rboot, Rcdfs, RSs] = computeResiliency(d{9}, d{6}, d{8}, d{5}, d{7}, mint, maxt);
AH = d{5}; AL = d{6}; BH = d{7}; BL = d{8};
AHacc = acc{5}; ALacc = acc{6}; BHacc = acc{7}; BLacc = acc{8};
[ccf, ccf_H, tccf, ccfhi, ccflo] = computeCCF(AH, AL, BH, BL, AHacc, ALacc, BHacc, BLacc, mint, maxt);
ccfMean = nansum(exp(ccf_H));
Mccf = (ccfMean(1) - ccfMean(2)) + (ccfMean(3) - ccfMean(4));

%% Plot Target Category MICs
if ploton
    fig = figure('WindowStyle', 'docked');
    subplot(3,2,1)
    hold on
    e1 = errorbar(1:2, targ(1:2), targerr(1:2), '-k');
    set(e1, 'LineWidth', 1)
    e2 = errorbar(1:2, targ(3:4), targerr(3:4), '--k');
    set(e2, 'LineWidth', 1)
    
    h = plot(1:2, targ(1:2), '-ko', 1:2, targ(3:4), '--ko');
%     set(gca,'XLim', [.5 2.5], 'XTick', [1 2], 'XTickLabel', {'L', 'H'});
    set(gca,'XLim', [.5 2.5], 'XTick', [], 'YTick', []);
%     title('Target Category Mean RTs', 'FontSize', 14)
    title(sprintf('MIC = %4.2f', mic), 'FontSize', 14)
    
    set(h(1), 'MarkerFaceColor', [0 0 0], 'LineWidth', 1, 'MarkerSize',8)
    set(h(2), 'MarkerFaceColor', [1 1 1], 'LineWidth', 1, 'MarkerSize',8)
%     legend('Low (Bottom)', 'High (Bottom)', 'Location', 'NorthEast')
%     xlabel('Top', 'FontSize', 14)
    box on
    
    %%
    y = anovadata(~ismember(anovadata(:,3), 1:4), [3 5 6 4]);
    cont = aggregate(y, 1, 4, [], 1);
    contstd = aggregate(y, 1, 4, @std,1); contcnt = aggregate(y, 1, 4, @count,1);
    conterr = contstd./sqrt(contcnt);
    lowYlim = floor((min([targ; cont] - [targerr; conterr]) - 50)/100) * 100;
    highYlim = lowYlim + ceil(max([max([targ; cont] + [targerr; conterr]) - lowYlim + 50, 600])/100) * 100;
    
    set(gca,'YLim', [lowYlim highYlim], 'FontSize', 12)
%     ylabel('Mean RT (ms)', 'FontSize', 14)
    
    subplot(3,2,2)
    hold on
    e3 = errorbar(1, cont(5), conterr(5)); set(e3, 'LineStyle', 'none', 'Color', [0 0 0]);
    set(e3, 'LineWidth', 2)
    e4 = errorbar(2:3, cont([2 1]), conterr([2 1]), '-k');
    set(e4, 'LineWidth', 2)
    e5 = errorbar(2:3, cont([4 3]), conterr([4 3]), '-k');
    set(e5, 'LineWidth', 2)
    
    h2 = plot(1, cont(5), ' sk', 2:3, cont([4 3]), '-ko', 2:3, cont([2 1]), '-kd');
    
    set(gca,'XLim', [.5 3.5], 'XTick', [1 2 3], 'XTickLabel', {'R', 'I', 'E'});
    set(h2(1), 'MarkerFaceColor', [1 1 1], 'LineWidth', 2, 'MarkerSize',10)
    set(h2(2), 'MarkerFaceColor', [1 1 1], 'LineWidth', 2, 'MarkerSize',10)
    set(h2(3), 'MarkerFaceColor', [0 0 0], 'LineWidth', 2, 'MarkerSize',10)
    
    legend(h2([2 3 1]), dimensions{1}, dimensions{2}, 'Redundant', 'Location', 'NorthWest')
    
    box on
%     set(gca,'YLim', [lowYlim highYlim],'FontSize', 12)
    set(gca,'YLim', [600 1400],'FontSize', 12)
    xlabel('Interior-Exterior', 'FontSize', 14)
    ylabel('Mean RT (ms)', 'FontSize', 14)
%     title('Contrast Category Mean RTs', 'FontSize', 14)
    title(subjectCodes{si}, 'FontSize', 14)

    %% Plot Survivors
    subplot(3,2,3)
    hs = plot(tsic, tsf);
    set(hs(4), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    set(hs(3), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
    set(hs(2), 'Color', 'b', 'LineStyle', '-' , 'LineWidth', 2)
    set(hs(1), 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2)
    legend(hs, 'HH', 'HL', 'LH', 'LL') 
    xlabel('t', 'FontSize', 14)
    ylabel('P (T > t)', 'FontSize', 14)
    axis([mint maxt 0 1])
    set(gca,'FontSize', 14)
    title('Survivor Functions', 'FontSize', 14)
    
    %% Plot SICS
    subplot(3,2,5)
    hsic = plot(tsic, sic); 
    hold on
    set(hsic, 'Color', 'k', 'LineStyle', '-' , 'LineWidth', 2)
    
    hsicCI = plot(tsic, sichi, '--k', tsic, siclo, '--k');
    set(hsicCI, 'LineWidth', 1)
    
    xlabel('t', 'FontSize', 14)
    ylabel('SIC(t)', 'FontSize', 14)
    axis tight
    l = line([0 3000], [0 0]); set(l, 'Color', 'k')
    set(gca,'FontSize', 14, 'XLim', [0 3000], 'YLim', [-.5 .25])
%     title(sprintf('MIC = %4.2f', MIC), 'FontSize', 14) % Plot mic estimated by integrating censored SIC
%     title(sprintf('MIC = %4.2f', mic), 'FontSize', 14)
    title(subjectCodes{si});
    
    %% Plot conflict survivors
    subplot(3,2,4)
    hs = plot(tccf, exp(ccf_H));
    set(hs(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    set(hs(2), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2)
    set(hs(3), 'Color', 'b', 'LineStyle', '-' , 'LineWidth', 2)
    set(hs(4), 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2)
    legend(hs, 'AH', 'AL', 'BH', 'BL') 
    xlabel('t', 'FontSize', 14)
    ylabel('P (T > t)', 'FontSize', 14)
    axis([mint maxt 0 1])
    set(gca,'FontSize', 14)
    title('Survivor Functions', 'FontSize', 14)

    %% Plot conflict contrast function
    sm = 2; % 2 * std boot
    subplot(3,2,6)
    plot(t, zeros(1, length(t)), '-k');
    hold on
    
    hc = plot(tccf, ccf);
    set(hc(1), 'Color', 'r', 'LineStyle', '-' , 'LineWidth', 2)
    hold on
    hcCI = plot(tccf, ccfhi, '--b', tccf,  ccflo, '--b');    % plot 95% Confidence Interval
    set(hcCI, 'LineWidth', 1)
    title(sprintf('Mean_{CCF} = %4.2f', Mccf), 'FontSize', 14)
    xlabel('t', 'FontSize', 14)
    ylabel('CCF(t)', 'FontSize', 14)
    set(gca,'FontSize', 12, 'XLim', [mint maxt])    
%     set(gca, 'XLim', [300 3000], 'YLim', [-3 1]) 
end
disp('Finished')