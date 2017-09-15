clear all
clc
% close all

subjects =  [101 105 107 109 202 206 210 301 302 303 304 306 401 402 403 404];
cr = [1 1 1 1 2 2 2 2 2];
er = [ 2 2 2 2 2 1 1 1 1 ];
percentiles = 25:25:75;
symbols = {' xk', ' xk', ' xk', ' xk', ' ok', ' ok', ' ok', ' ok', ' ^k', ' ^k', ' ^k', ' ^k', ' ^k', ' *k', ' *k', ' *k', ' *k'};
figure1 = figure('WindowStyle', 'docked'); 
hcnt = 1;

for i = 1:numel(subjects);
    load(sprintf('s%dplotData.mat', subjects(i)));
    getDataPercentiles = @(i,j)prctile(data.rt(data.item == i & data.resp == j & data.rt < 10), percentiles);
    % Extract 25:50:75 from data.
    dataPercent(1:4,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i,1), 1:4, 'UniformOutput', false)');
    dataPercent(5:9,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i,2), 5:9, 'UniformOutput', false)');
        dataEPercent(1:4,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 2), 1:4, 'UniformOutput', false)');
    dataEPercent(5:9,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 1), 5:9, 'UniformOutput', false)');

    for j = 1:9
        for kdx = 2:20
            sim.rt{j,1} = [sim.rt{j,1}; sim.rt{j,kdx}];
            sim.resp{j,1} = [sim.resp{j,1}; sim.resp{j,kdx}];
        end
            
            
        getsim = @(j,k,p)(prctile(sim.rt{j,k}(sim.resp{j,k} == cr(j) & sim.rt{j,k} < 10), p));
         getesim = @(j,k,p)(prctile(sim.rt{j,k}(sim.resp{j,k} == er(j) & sim.rt{j,k} < 10), p));
       
        getSimPercentiles = @(k)getsim(j,k,25);
        simPercent{1}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));
            
        getSimPercentiles = @(k)getsim(j,k,50);
        simPercent{2}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));
        
        getSimPercentiles = @(k)getsim(j,k,75);
        simPercent{3}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));
        
                getSimPercentiles = @(k)getesim(j,k,25);
        simePercent{1}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));
            
        getSimPercentiles = @(k)getesim(j,k,50);
        simePercent{2}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));
        
        getSimPercentiles = @(k)getesim(j,k,75);
        simePercent{3}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));   
        
        
        subplot(2,3,1);
        if ismember(i, [1 5 9 14]) && j == 1
           h = plot(dataPercent(j,1), simPercent{1}(j,:), symbols{i}); hold on
        else
            plot(dataPercent(j,1), simPercent{1}(j,:), symbols{i}); hold on
        end
        subplot(2,3,2);
        plot(dataPercent(j,2), simPercent{2}(j,:), symbols{i}); hold on
        subplot(2,3,3);
        plot(dataPercent(j,3), simPercent{3}(j,:),  symbols{i}); hold on
        subplot(2,3,4);
        plot(dataEPercent(j,1), simePercent{1}(j,:), symbols{i}); hold on
        subplot(2,3,5);
        plot(dataEPercent(j,2), simePercent{2}(j,:), symbols{i}); hold on
        subplot(2,3,6);
        plot(dataEPercent(j,3), simePercent{3}(j,:),  symbols{i}); hold on
    end
    hh(hcnt) = h;
    hcnt = hcnt + 1; 
end

%%
x = [25 50 75 25 50 75];
for i = 1:6
subplot(2,3,i)
lims = [0 3];
set(gca, 'XLim', lims, 'YLim', lims)
line(lims, lims, 'LineStyle', '-', 'Color', 'k')
xlabel('Observed RT (sec)')
ylabel('Predicted RT (sec)')
axis square
if i <= 3
    title(sprintf('Correct RT %2d %%', x(i)));
else
    title(sprintf('Error RT %2d %%', x(i)));
end
if i == 1
    legend(hh([1 5 9 14]), 'Upright Aligned', 'Upright Misaligned', 'Inverted Aligned', 'Inverted Misaligned');
end
end