clear all
clc
close all

plotGRT = true;
plotLBA = true;
plotLBA2 = true;
plotLBA3 = true;

% Plot for 107 and 306
subjects = [107 306]; % These need to match datafiles in the Data folder
xlabels = {'UA3' 'IA5'};

models = {'freedriftst'};
fitfolder = fullfile(pwd, 'Fits', 'Facerules');

figure1 = figure('WindowStyle', 'docked');
figure2 = figure('WindowStyle', 'docked');
figure3 = figure('WindowStyle', 'docked');


for sidx = 1:numel(subjects)
    subject = subjects(sidx);
    load(fullfile(fitfolder, sprintf('s%d_%s_t.mat', subject, models{1})), 'model', 'data', 'theta', 'logtheta', 'weight', 'n')
    n.burnin = n.mc - 750;
    
    names = fieldnames(theta);
    for j = 1:numel(names);
        temp = theta.(names{j})(:,n.burnin:end);
        samples.(names{j}) = temp(:);
    end
    
    %% GRT parameters
    if plotGRT
        figure(figure1)
        plot1 = gca;
        parmNames = {'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'v8', 'v9'};
        colors = [0 .5 0; 0 0 .5];
        adj = [-.25 .25];
        for j = 1:numel(parmNames)
            currparm = parmNames{j};
            bandwidth = getbandwidth(samples.(currparm)(:));
            
            [h.(currparm),L.(currparm),MX.(currparm),MED.(currparm),bw.(currparm)] =...
                violin(samples.(currparm), 'x', j+adj(sidx),...
                'facecolor', colors(sidx,:), 'edgecolor', 'k',...
                'facealpha', .5, 'mc', '', 'medc', '', 'bw', bandwidth);
            hp.(currparm) = plot(j+adj(sidx), mean(samples.(currparm)), ' ok', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
            hold on
            hh(sidx) = h.(currparm);
            
            if j < 9
                line([j + .5 j + .5], [0 1], 'LineStyle', '--', 'Color', 'k')
       
            end
        end
      
    end
    %% LBA parameters
    if plotLBA
        figure(figure2)
        plot2 = gca;
        currparm = 'A';
        bandwidth = getbandwidth(samples.(currparm)(:));
        [h.(currparm),L.(currparm),MX.(currparm),MED.(currparm),bw.(currparm)] =...
            violin(samples.(currparm), 'x', sidx-.25,...
            'facecolor', [0 .5 0], 'edgecolor', 'k',...
            'facealpha', .5, 'mc', '', 'medc', '', 'bw', bandwidth);
        hp.(currparm) = plot(sidx-.25, mean(samples.(currparm)), ' ok', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
        hold on
        
             currparm = 'bMa1';
        bandwidth = getbandwidth(samples.(currparm)(:));
        [h.(currparm),L.(currparm),MX.(currparm),MED.(currparm),bw.(currparm)] =...
            violin(samples.(currparm), 'x', sidx+.25,...
            'facecolor', [.5  0 0], 'edgecolor', 'k',...
            'facealpha', .5, 'mc', '', 'medc', '', 'bw', bandwidth);
        hp.(currparm) = plot(sidx+.25, mean(samples.(currparm)), ' ok', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
        hold on
        
        currparm = 'bMa2';
        bandwidth = getbandwidth(samples.(currparm)(:));
        [h.(currparm),L.(currparm),MX.(currparm),MED.(currparm),bw.(currparm)] =...
            violin(samples.(currparm), 'x', sidx+.25,...
            'facecolor', [.5  .5 0], 'edgecolor', 'k',...
            'facealpha', .5, 'mc', '', 'medc', '', 'bw', bandwidth);
        hp.(currparm) = plot(sidx+.25, mean(samples.(currparm)), ' ok', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
        hold on
    end
    %% Other LBA parameters
    if plotLBA2
        figure(figure3)
        plot3 = gca;
        currparm = 's';
        bandwidth = getbandwidth(samples.(currparm)(:));
        [h.(currparm),L.(currparm),MX.(currparm),MED.(currparm),bw.(currparm)] =...
            violin(samples.(currparm), 'x', sidx-.25,...
            'facecolor', [0 .5 0], 'edgecolor', 'k',...
            'facealpha', .5, 'mc', '', 'medc', '', 'bw', bandwidth);
        hp.(currparm) = plot(sidx-.25, mean(samples.(currparm)), ' ok', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
        hold on
        
        currparm = 't0';
        bandwidth = getbandwidth(samples.(currparm)(:));
        [h.(currparm),L.(currparm),MX.(currparm),MED.(currparm),bw.(currparm)] =...
            violin(samples.(currparm), 'x', sidx+.25,...
            'facecolor', [0  0 .5], 'edgecolor', 'k',...
            'facealpha', .5, 'mc', '', 'medc', '', 'bw', bandwidth);
        hp.(currparm) = plot(sidx+.25, mean(samples.(currparm)), ' ok', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
        hold on
        
    end
    
end
if plotGRT
    set(plot1, 'XLim', [0 10], 'YLim', [0 1], 'XTick', 1:9, 'XTickLabel',...
        {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'});
    legend([hh(1), hh(2)], 'UA3', 'IA5')
    xlabel('Subject')
    ylabel('Density')
end
if plotLBA
    set(plot2, 'XLim', [0 3], 'YLim', [0 1], 'XTick', 1:2, 'XTickLabel',...
        xlabels);
    legend([h.A, h.bMa1, h.bMa2], 'A',  'T_{A}-A', 'T_{B}-A')
    xlabel('Subject')
    ylabel('Density')
end
if plotLBA2
    set(plot3, 'XLim', [0 3], 'YLim', [0 .5], 'XTick', 1:2, 'XTickLabel',...
        xlabels);
    legend([h.s, h.t0], 'Drift Variability', 'Non-decision Time')
    xlabel('Subject')
    ylabel('Density')
end
