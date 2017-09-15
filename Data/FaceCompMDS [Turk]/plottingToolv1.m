%% Clear variable space
clear all
close all
clc

plotversion = 0;
% load('Rfull_fitsv2.mat');
datafiles = {'CompRules5_8_cityblock_full_1.mat', 'CompRules5_8_cityblock_constrained_1.mat'...
            'CompRules5_8_euclidean_full_1.mat', 'CompRules5_8_euclidean_constrained_1.mat'...
            'CompRules5_8_cityblock_full_2.mat', 'CompRules5_8_cityblock_constrained_2.mat'...
            'CompRules5_8_euclidean_full_2.mat', 'CompRules5_8_euclidean_constrained_2.mat'};
plot_title = {'Cityblock Unconstrained', 'Cityblock Constrained',...
                'Euclidean Unconstrained', 'Euclidean Constrained',...
                'Cityblock Unconstrained', 'Cityblock Constrained',...
                'Euclidean Unconstrained', 'Euclidean Constrained'};

condition_title = {'Inverted Aligned', 'Inverted Misaligned', 'Upright Aligned','Upright Misaligned'};

nmodels = numel(datafiles);

for fidx = 1:nmodels
    load(datafiles{fidx});
    disp(datafiles{fidx});
    figure('WindowStyle','Docked','Color',[1 1 1]);

    for pidx = 1:numel(condition)
        subplot(2,2,pidx);
        plot(rotxy{pidx}(:,1), rotxy{pidx}(:,2), ' ok')
        text(rotxy{pidx}(:,1), rotxy{pidx}(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);
        set(gca,'XLim', [.0 4], 'XTick', 1:1:3,'XTickLabel',{'1', '2', '3'});
        set(gca,'YLim', [.0 4], 'YTick', 1:1:3,'YTickLabel',{'1', '2', '3'});
        xlabel('A-B Morph Dimension');
        ylabel('C-D Morph Dimension');
        title(condition_title{pidx}, 'Fontsize', 15);
        axis square
    end
    supertitle(plot_title{fidx})
    
    disp([condition', cell2mat(bestfit), cell2mat(R2), cell2mat(BIC)]);
end
