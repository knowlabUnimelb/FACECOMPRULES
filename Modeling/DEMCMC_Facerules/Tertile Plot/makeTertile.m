clear all
clc
close all

subjects =  [101 105 107 109 202 206 210 301 302 303 304 306 401 402 403 404];
cr = [1 1 1 1 2 2 2 2 2];
percentiles = 25:25:75;
symbols = {' xk', ' xk', ' xk', ' xk', ' ok', ' ok', ' ok', ' ok', ' ^k', ' ^k', ' ^k', ' ^k', ' ^k', ' *k', ' *k', ' *k', ' *k'};
figure1 = figure; 
for i = 1:numel(subjects);
    load(sprintf('s%dplotData.mat', subjects(i)));
    getDataPercentiles = @(i,j)prctile(data.rt(data.item == i & data.resp == j & data.rt < 10), percentiles);
    % Extract 25:50:75 from data.
    dataPercent(1:4,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 1), 1:4, 'UniformOutput', false)');
    dataPercent(5:9,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 2), 5:9, 'UniformOutput', false)');
    
    for j = 1:9
%         getsim = @(j,k,p)(prctile(sim.rt{j,k}(sim.resp{j,k} == cr(j) & sim.rt{j,k} < 3), p));
        getsim = @(j,k,p)(prctile(sim.rt{j,k}(sim.resp{j,k} == cr(j) & sim.rt{j,k} < 10), p));
        
        getSimPercentiles = @(k)getsim(j,k,25);
        simPercent{1}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1:20, 'UniformOutput', false));
            
        getSimPercentiles = @(k)getsim(j,k,50);
        simPercent{2}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1:20, 'UniformOutput', false));
        
        getSimPercentiles = @(k)getsim(j,k,75);
        simPercent{3}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1:20, 'UniformOutput', false));
        
        
        subplot(1,3,1);
        plot(dataPercent(j,1), simPercent{1}(j,:), symbols{i}); hold on
        subplot(1,3,2);
        plot(dataPercent(j,2), simPercent{2}(j,:), symbols{i}); hold on
        subplot(1,3,3);
        plot(dataPercent(j,3), simPercent{3}(j,:),  symbols{i}); hold on
    end
end

%%
subplot(1,3,1)
lims = [0 2.5];
set(gca, 'XLim', lims, 'YLim', lims)
line(lims, lims, 'LineStyle', '-', 'Color', 'k')
xlabel('Observed')
ylabel('Predicted')
subplot(1,3,2)
set(gca, 'XLim', lims, 'YLim', lims)
line(lims, lims, 'LineStyle', '-', 'Color', 'k')
xlabel('Observed')
ylabel('Predicted')
subplot(1,3,3)
set(gca, 'XLim', lims, 'YLim', lims)
line(lims, lims, 'LineStyle', '-', 'Color', 'k')
xlabel('Observed')
ylabel('Predicted')