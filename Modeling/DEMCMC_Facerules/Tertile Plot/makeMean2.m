clear all
clc
close all

subjects =  [101 105 107 109 202 204 206 210 301 302 303 304 306 401 402 403 404];
cr = [1 1 1 1 2 2 2 2 2];
er = [ 2 2 2 2 1 1 1 1 1];
percentiles = 25:25:75;
symbols = {' xk', ' xk', ' xk', ' xk', ' ok', ' ok', ' ok', ' ok', ' ^k', ' ^k', ' ^k', ' ^k', ' ^k', ' *k', ' *k', ' *k', ' *k'};
figure1 = figure; 
hcnt = 1; 
for i = 1:numel(subjects);
    load(sprintf('s%dplotData.mat', subjects(i)));
    getDataPercentiles = @(i,j)mean(data.rt(data.item == i & data.resp == j & data.rt < 10));
    
    % Extract 25:50:75 from data.
    dataPercent(1:4,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 1), 1:4, 'UniformOutput', false)');
    dataPercent(5:9,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 2), 5:9, 'UniformOutput', false)');
    
    dataEPercent(1:4,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 2), 1:4, 'UniformOutput', false)');
    dataEPercent(5:9,:) = cell2mat(arrayfun(@(i)getDataPercentiles(i, 1), 5:9, 'UniformOutput', false)');
    
    for j = 1:9
        getsim = @(j,k)(mean(sim.rt{j,k}(sim.resp{j,k} == cr(j) & sim.rt{j,k} < 10)));
        getErrorsim = @(j,k)(mean(sim.rt{j,k}(sim.resp{j,k} == er(j) & sim.rt{j,k} < 10)));
%         getsim = @(j,k)(mean(sim.rt{j,k}(sim.resp{j,k} == cr(j))));
        
        getSimPercentiles = @(k)getsim(j,k);
        simPercent{1}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1, 'UniformOutput', false));
            
        getSimEPercentiles = @(k)getErrorsim(j,k);
        simPercent{2}(j,:) = cell2mat(arrayfun(@(x)getSimEPercentiles(x), 1, 'UniformOutput', false));
        
%         getSimPercentiles = @(k)getsim(j,k,75);
%         simPercent{3}(j,:) = cell2mat(arrayfun(@(x)getSimPercentiles(x), 1:20, 'UniformOutput', false));
        
        
        subplot(1,2,1);
        if ismember(i, [1 5 9 14]) && j == 1
            h = plot(dataPercent(j,1), simPercent{1}(j,:), symbols{i}); hold on;
        else
            plot(dataPercent(j,1), simPercent{1}(j,:), symbols{i}); hold on
        end
        subplot(1,2,2);
%         if ~isn   an(dataEPercent(j,1))
        plot(dataEPercent(j,1), simPercent{2}(j,:), symbols{i}); hold on
%         end
%         subplot(1,3,3);
%         plot(dataPercent(j,3), simPercent{1}(j,:), ' xk'); hold on
    end
    hleg(hcnt) = h(1);
    hcnt = hcnt + 1;
end

%%
subplot(1,2,1)
set(gca, 'XLim', [.5 2.5], 'YLim', [.5 2.5])
line([.5 2.5], [.5 2.5], 'LineStyle', '-', 'Color', 'k')
xlabel('Observed RT (sec)')
ylabel('Predicted RT (sec)')
legend(hleg([1 5 9 14]), 'Upright Aligned', 'Upright Inverted', 'Inverted Aligned', 'Inverted Misaligned')
title('Correct RT')
subplot(1,2,2)
set(gca, 'XLim', [.5 2.5], 'YLim', [.5 2.5])
line([.5 2.5], [.5 2.5], 'LineStyle', '-', 'Color', 'k')
xlabel('Observed RT (sec)')
ylabel('Predicted RT (sec)')
title('Error RT')
% subplot(1,3,3)
% set(gca, 'XLim', [.5 2.5], 'YLim', [.5 2.5])
% line([.5 2.5], [.5 2.5], 'LineStyle', '-', 'Color', 'k')
% xlabel('Observed')
% ylabel('Predicted')